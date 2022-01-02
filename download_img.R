# Setup --------------------------------------------------------------------------------------------
library(parallel)
library(magick)


# Download all original images ---------------------------------------------------------------------
cl <- makeCluster(11)
DT_raw <- parSapply(cl, X = 1:9999, simplify = FALSE, FUN = function(i) {
  url <- 'https://bosscatrocketclub.com/media/bcrc%s.jpg'
  url <- sprintf(url, i)
  download.file(url, paste0("img_original/BCRC", i, ".jpg"), mode = "wb")
})
stopCluster(cl)


# Edit and save images -----------------------------------------------------------------------------
cl <- makeCluster(11)
DT_raw <- parSapply(cl, X = 1:9999, simplify = FALSE, FUN = function(i) {
  pic <- magick::image_read(sprintf("img_original/BCRC%s.jpg", i))
  pic <- magick::image_convert(pic, "png")
  pic <- magick::image_scale(pic, "50") # 50x50px
  magick::image_write(pic, path = sprintf("img/BCRC%s.png", i))
})
stopCluster(cl)
