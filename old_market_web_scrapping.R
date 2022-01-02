# Setup --------------------------------------------------------------------------------------------
library(data.table)
library(RSelenium)
library(tidyr)
library(rvest)

RAR <- readRDS("data/RAR.rds")

# Functions
loj <- function (X = NULL, Y = NULL, onCol = NULL) {
  if (truelength(X) == 0 | truelength(Y) == 0) 
    stop("setDT(X) and setDT(Y) first")
  n <- names(Y)
  X[Y, `:=`((n), mget(paste0("i.", n))), on = onCol]
}


# Extract information from cnft.io -----------------------------------------------------------------
cnft_url <- "https://cnft.io/marketplace?project=Boss%20Cat%20Rocket%20Club&sort=_id:-1&type=listing,offer"

# Rselenium connection
exCap <- list("moz:firefoxOptions" = list(args = list('--headless'))) # Hide browser --headless
rD <- rsDriver(browser = "firefox", port = as.integer(sample(4000:4700, 1)),
               verbose = FALSE, extraCapabilities = exCap)
remDr <- rD[["client"]]
remDr$setWindowSize(30000, 30000)
remDr$navigate(cnft_url)
Sys.sleep(350)
html <- remDr$getPageSource()[[1]]
remDr$close()

# Analyse html content with rvest
html <- read_html(html)

DT <- data.table(html_a = html_elements(html, "a.Card_Card__2Ruvq.Card_cardLight__31qhQ"))
DT[, link := paste0("https://cnft.io", html_attr(html_a, "href"))]
DT[, asset := html_text(html_elements(html_a, "div.Card_cardName__sfXen")), 1:nrow(DT)]
DT[, asset_number := gsub("Boss Cat Rocket Club #", "", asset)]
DT[, asset_number := as.numeric(asset_number)]
DT[, price := html_text(html_elements(html_a, "div.Card_price__1fnr-")), 1:nrow(DT)]
DT[, price := as.numeric(gsub(" ADA", "", price))]
DT[, sc := ifelse(length(html_elements(html_a, "img.Card_bolt__180yk")) == 0, "no", "yes"), 1:nrow(DT)]
DT[, market := "cnft.io"]
DT[, html_a := NULL]


# Extract information from jpg.store ---------------------------------------------------------------
jpg_url <- "https://www.jpg.store/collection/bosscatrocketclub?saleType=buy-now&sortBy=lowest-last-sale"

# Rselenium connection
exCap <- list("moz:firefoxOptions" = list(args = list('--headless'))) # Hide browser
rD <- rsDriver(browser = "firefox", port = as.integer(sample(4000:4700, 1)),
               verbose = FALSE, extraCapabilities = exCap)
remDr <- rD[["client"]]
remDr$setWindowSize(25000, 25000)
remDr$navigate(jpg_url)
Sys.sleep(30)
html <- remDr$getPageSource()[[1]]
remDr$close()

# Analyse html content with rvest
html <- read_html(html)
DT2 <- data.table(
  link = html_attr(html_elements(html, "a.animate-hover.flex.flex-column.position-relative.undefined"), "href"),
  asset = html_text(html_elements(html, "p.font-weight-500.black.font-size-18")),
  price = html_text(html_elements(html, "span.font-weight-900.font-size-28.font-family-roboto-slab.black"))
)

DT2[, link := paste0("https://www.jpg.store", link)]
DT2[, asset_number := gsub("Boss Cat Rocket Club #", "", asset)]
DT2[, asset_number := as.numeric(asset_number)]
DT2[price %like% "\\.", price := gsub("\\.", "", price)]
DT2[, price := gsub("k", "000", price)]
DT2[, price := as.numeric(price)]
DT2[, sc := "yes"]
DT2[, market := "jpg.store"]

# Merge info
DT <- rbindlist(list(DT, DT2), fill = TRUE)
DT <- DT[complete.cases(DT)]


# Rarity and ranking -------------------------------------------------------------------------------
setDT(DT); setDT(RAR)
loj(DT, RAR, "asset_number")

# DT[, index_rarity   := asset_rarity/price]
# DT[, index_rarity_z := asset_rarity/price]
# 
# DT[, index_rank     := (9999 - asset_rank)/price]
# DT[, index_rank_z   := scale(index_rank)]

DT[, rank_range := fcase(asset_rank %between% c(1, 100), "1-100",
                         asset_rank %between% c(101, 250), "101-250",
                         asset_rank %between% c(251, 500), "251-500",
                         asset_rank %between% c(501, 750), "501-750",
                         asset_rank %between% c(751, 1000), "751-1000",
                         asset_rank %between% c(1001, 1500), "1001-1500",
                         asset_rank %between% c(1501, 2000), "1501-2000",
                         asset_rank %between% c(2001, 3000), "2001-3000",
                         asset_rank %between% c(3001, 4000), "3001-4000",
                         asset_rank %between% c(4001, 5000), "4001-5000",
                         asset_rank %between% c(5001, 6000), "5001-6000",
                         asset_rank %between% c(6001, 7000), "6001-7000",
                         asset_rank %between% c(7001, 8000), "7001-8000",
                         asset_rank %between% c(8001, 9000), "8001-9000",
                         asset_rank %between% c(9001, 9999), "9001-9999") %>% 
     factor(levels = c("1-100",
                       "101-250",
                       "251-500",
                       "501-750",
                       "751-1000",
                       "1001-1500",
                       "1501-2000",
                       "2001-3000",
                       "3001-4000",
                       "4001-5000",
                       "5001-6000",
                       "6001-7000",
                       "7001-8000",
                       "8001-9000",
                       "9001-9999"))]

DT[, rarity_range := fcase(asset_rarity %between% c(70, 90), "70-90",
                           asset_rarity %between% c(90.001, 110), "90-110",
                           asset_rarity %between% c(110.001, 130), "110-130",
                           asset_rarity %between% c(130.001, 150), "130-150",
                           asset_rarity %between% c(150.001, 170), "150-170",
                           asset_rarity %between% c(170.001, 190), "170-190",
                           asset_rarity %between% c(190.001, 210), "190-210",
                           asset_rarity %between% c(210.001, 230), "210-230",
                           asset_rarity %between% c(230.001, 250), "230-250",
                           asset_rarity %between% c(250.001, 270), "250-270",
                           asset_rarity %between% c(270.001, 280), "270-280",
                           asset_rarity %between% c(280.001, 290), "280-290",
                           asset_rarity %between% c(290.001, 300), "290-300",
                           asset_rarity %between% c(300.001, 310), "300-310",
                           asset_rarity %between% c(310.001, 320), "310-320") %>% 
     factor(levels = c("70-90",
                       "90-110",
                       "110-130",
                       "130-150",
                       "150-170",
                       "170-190",
                       "190-210",
                       "210-230",
                       "230-250",
                       "250-270",
                       "270-280",
                       "280-290",
                       "290-300",
                       "300-310",
                       "310-320"))]



# Large format -------------------------------------------------------------------------------------
.cols <- names(DT)[names(DT) %like% "background_|earring_|hat_|eyes_|mouth_|clothes_|fur_"]
DTL <- data.table(gather(DT, raw_trait, has_trait, all_of(.cols)))
DTL <- DTL[has_trait == 1]

DTL[, trait_category := strsplit(raw_trait, "_")[[1]][1], 1:nrow(DTL)]
DTL[, trait          := strsplit(raw_trait, "_")[[1]][2], 1:nrow(DTL)]


# Save ---------------------------------------------------------------------------------------------
saveRDS(DT, file = "data/DT.rds")
saveRDS(DTL, file = "data/DTL.rds")


# Task schedule ------------------------------------------------------------------------------------
# taskscheduleR::taskscheduler_create(taskname = "BCRC_check",
#                                     rscript = normalizePath(list.files(pattern = "main.R")),
#                                     schedule = "MINUTE", modifier = 7)

## Delete task
# taskscheduleR::taskscheduler_delete(taskname = "BCRC_check")


# Notification -------------------------------------------------------------------------------------
# DT_latest <- fread("data/DT_latest.csv")
# is_super_rare <- any(DT$index_rank_z > 3) # check is there very good deal
# is_new <- DT_latest[1, asset] != DT[1, asset] # Check if asset is new
# 
# if(is_super_rare & is_new) {
#   beepr::beep(2)
#   DT[1, browseURL(link)]
#   fwrite(DT, "data/DT_latest.csv")
# }
# https://towardsdatascience.com/effective-notification-mechanisms-in-r-82db9cb8816
