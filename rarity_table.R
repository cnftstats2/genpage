# Setup --------------------------------------------------------------------------------------------
library(data.table)
library(parallel)
library(schmitz)
library(rvest)


# Attributes ---------------------------------------------------------------------------------------
traits <- c(
  "Fur_Bengal",
  "Fur_Burmese",
  "Fur_Calico",
  "Fur_Charcoal",
  "Fur_Cheetah",
  "Fur_Cream Tabby",
  "Fur_Cyborg",
  "Fur_Daredevil",
  "Fur_Dark Teal",
  "Fur_Diamond",
  "Fur_DMT Gold",
  "Fur_DMT Green",
  "Fur_Earth",
  "Fur_Fire Red",
  "Fur_Frankenstein",
  "Fur_Gold",
  "Fur_Gray Tabby",
  "Fur_Jungle",
  "Fur_Jungle Cat",
  "Fur_Leopard",
  "Fur_Light Gray",
  "Fur_Maltese",
  "Fur_Metallic Gold",
  "Fur_Mountain Cat",
  "Fur_Mutant",
  "Fur_Mystique",
  "Fur_Noise",
  "Fur_Obsidian",
  "Fur_OG Tabby",
  "Fur_Patched Tabby",
  "Fur_Persian",
  "Fur_Pharaoh",
  "Fur_Pink Panther",
  "Fur_Red",
  "Fur_Robot Patch",
  "Fur_Robot Stripe",
  "Fur_Russian Blue",
  "Fur_Shark",
  "Fur_Siamese",
  "Fur_Skull",
  "Fur_Tan",
  "Fur_Thunder Cat",
  "Fur_Tom Cat",
  "Fur_Trippy",
  "Fur_Trippy Zebra",
  "Fur_Trippy Zombie",
  "Fur_Tuxedo",
  "Fur_Shite Bengal",
  "Fur_Zombie",
  "Clothes_Admirals Coat",
  "Clothes_Bandanna",
  "Clothes_BCRC Army",
  "Clothes_BCRC Sleeveless",
  "Clothes_BCRC Sweater",
  "Clothes_Biker Jacket",
  "Clothes_Blue Magic Crewneck",
  "Clothes_Caveman Necklace",
  "Clothes_Caveman Pelt",
  "Clothes_Cheetah Coat",
  "Clothes_Claw T",
  "Clothes_Dapper Don",
  "Clothes_Dino Striped T",
  "Clothes_Egyptian Mummy",
  "Clothes_Fur Coat",
  "Clothes_Fur Hood Coat",
  "Clothes_Gold Necklace",
  "Clothes_Graphic Sweater",
  "Clothes_Gray Suit",
  "Clothes_Hawaiian",
  "Clothes_Headphone",
  "Clothes_Hip-Hop",
  "Clothes_Jacquard Polo",
  "Clothes_Japanese Bodysuit",
  "Clothes_Joker",
  "Clothes_Kimono",
  "Clothes_Lab Coat",
  "Clothes_Leather Punk Jacket",
  "Clothes_Lumberjack Shirt",
  "Clothes_Mafioso White Suit",
  "Clothes_Marty McFly",
  "Clothes_Mechanic",
  "Clothes_Ora Ora Suit",
  "Clothes_Pastor",
  "Clothes_Pilot",
  "Clothes_Pinstripe Suit",
  "Clothes_Prison Jumpsuit",
  "Clothes_Rambo Vest",
  "Clothes_Service",
  "Clothes_Sherlock Holmes",
  "Clothes_Skull Crewneck",
  "Clothes_Street Soldier",
  "Clothes_Tango",
  "Clothes_Toga",
  "Clothes_Tracksuit",
  "Clothes_Tuxedo",
  "Clothes_Tweed Suit",
  "Clothes_Yakuza Kimono",
  "Mouth_Bloody Knife",
  "Mouth_Bubble Gum",
  "Mouth_Catnip",
  "Mouth_Cigar",
  "Mouth_Cigarette",
  "Mouth_Dagger",
  "Mouth_Dead Fish",
  "Mouth_Diamond Grillz",
  "Mouth_Fish Bone",
  "Mouth_Frown",
  "Mouth_Gold Dagger",
  "Mouth_Gold Grillz",
  "Mouth_Grinning",
  "Mouth_Kazoo",
  "Mouth_Lollipop",
  "Mouth_Party Horn",
  "Mouth_Pipe",
  "Mouth_Pizza",
  "Mouth_Rat",
  "Mouth_Standard",
  "Mouth_Threads",
  "Mouth_Tongue Out",
  "Mouth_Tongue Out Left",
  "Eyes_3D",
  "Eyes_Angry",
  "Eyes_Aviator",
  "Eyes_Aviator Yellow",
  "Eyes_Blue Beams",
  "Eyes_Chilled Blue",
  "Eyes_Chilled Pink",
  "Eyes_Chilled Trippy",
  "Eyes_Chilled Yellow Green",
  "Eyes_Cyborg Laser",
  "Eyes_Cyclops",
  "Eyes_Eye Patch",
  "Eyes_Glaring",
  "Eyes_Glowing",
  "Eyes_Goggle 3D",
  "Eyes_Goggle Gold",
  "Eyes_Hollow",
  "Eyes_Hollow Cardano",
  "Eyes_Meh",
  "Eyes_Mystique",
  "Eyes_Possessed",
  "Eyes_Red Beams",
  "Eyes_Scratched",
  "Eyes_Serious Gray",
  "Eyes_Serious Red",
  "Eyes_Suspicious",
  "Eyes_Trippy Beams",
  "Eyes_Villain Scars",
  "Hat_Army Hat",
  "Hat_Army Hat Camo",
  "Hat_Bald",
  "Hat_Bandanna",
  "Hat_Baseball Cap",
  "Hat_BCRC Flipped Brim",
  "Hat_BCRC Hat Black",
  "Hat_BCRC Hat Red",
  "Hat_BCRC Helmet",
  "Hat_Blue Halo",
  "Hat_Blue Horn",
  "Hat_Bowler",
  "Hat_Brushup Aniki",
  "Hat_Brushup Yakuza",
  "Hat_Bunny",
  "Hat_Captain's Hat",
  "Hat_Cowboy Hat",
  "Hat_Faux Mohawk",
  "Hat_Fedora",
  "Hat_Halo",
  "Hat_Kabukicho",
  "Hat_King's Crown",
  "Hat_Laurel Wreath",
  "Hat_Mariner's Cap",
  "Hat_Mohawk",
  "Hat_Party Hat",
  "Hat_Pink Hair",
  "Hat_Police Hat",
  "Hat_Police Helmet",
  "Hat_Pompadour",
  "Hat_Ponytail",
  "Hat_Prussian Helmet",
  "Hat_Red Horn",
  "Hat_Samurai",
  "Hat_Santa Hat",
  "Hat_Shogun",
  "Hat_Spinner Hat",
  "Hat_Stuntman Helmet",
  "Hat_Tie-Dye Headband",
  "Hat_Trippy Captain's Hat",
  "Hat_Trucker Hat",
  "Hat_Vietnam Era Helmet",
  "Hat_WWII Pilot Helmet",
  "Earring_Bling Gold",
  "Earring_Diamond Stud",
  "Earring_Gold Cross",
  "Earring_Gold Hoop",
  "Earring_Gold Stud",
  "Earring_Shinny Stud",
  "Earring_Silver Hoop",
  "Earring_Silver Stud",
  "Background_Aqua",
  "Background_Blue",
  "Background_Charcoal",
  "Background_Cream",
  "Background_Earth",
  "Background_Gray",
  "Background_Green",
  "Background_Jungle",
  "Background_Khaki",
  "Background_Navy",
  "Background_Purple",
  "Background_Red",
  "Background_Sunset",
  "Background_Teal Blue"
)


# Rarity -------------------------------------------------------------------------------------------
general_rarity_url <- "https://bosscatrocketclub.com/cats/boss-cat-rocket-club-%s/"

links <- sprintf(general_rarity_url, 1:9999)
links <- links[!(links %like% "3097|7210|9535|8114")] # rarity/rank not available

cl <- makeCluster(11)
x <- clusterEvalQ(cl, {
  library(data.table)
  library(schmitz)
  library(rvest)
})
RAR <- parSapply(cl, X = links, simplify = FALSE, FUN = function(link) {
  # Read link
  html_link <- read_html(link)
  
  # Asset number
  asset_number <- gsub("https://bosscatrocketclub.com/cats/boss-cat-rocket-club-|/", "", link)
  
  # Table
  HT <- html_element(html_link, "table")
  HT <- html_table(HT)
  HT <- data.table(variables = HT$X1, value = HT$X2)
  
  # Info
  asset_rarity     <- HT[variables == "Rarity Score", value]
  asset_rank       <- HT[variables == "Rank", value]
  asset_traits_num <- HT[variables == "Traits", value]
  
  # Traits
  HT[, traits := paste0("—", variables, "_", value)]
  HT[, traits := gsub(" \\(.*", "", traits)]
  asset_traits <- HT[variables %ni% c("Rarity Score", "Rank", "Traits"), paste0(traits, collapse = "")]
  asset_traits <- paste0(asset_traits, "—")
  
  # To data.table
  data.table(asset_number, asset_rarity, asset_rank, asset_traits_num, asset_traits)
})
stopCluster(cl)

# Merge info
RAR <- rbindlist(RAR)

# Fix missing assets -------------------------------------------------------------------------------
# .RAR_1 <- data.table(asset_number = 9535,
#                      asset_rarity = 36.75 + 9.90 + 8.04 + 18.25 + 2.35 + 10.98 + 10.4,
#                      asset_rank = NA,
#                      asset_traits_num = 7,
#                      asset_traits_dirty = paste0("—Background_Earth", 
#                                                  "—Fur_Mystique",
#                                                  "—Clothes_Bandanna",
#                                                  "—Mouth_Lollipop",
#                                                  "—Eyes_Aviator Yellow",
#                                                  "—Hat_Santa Hat",
#                                                  "—Earring_Shinny Stud",
#                                                  "—"))



# Clean and traits ---------------------------------------------------------------------------------
RAR[, asset_number     := as.numeric(asset_number)]
RAR[, asset_rarity     := as.numeric(asset_rarity)]
RAR[, asset_rank       := gsub("\\#", "", asset_rank) %>% as.numeric]
RAR[, asset_traits_num := gsub(" \\(.*", "", asset_traits_num) %>% as.numeric]

# Traits
RAR[, (traits) := NA] # add a column for each trait

for (trait in traits) {
  .pattern <- paste0("—", trait, "—")
  RAR[, (trait) := ifelse(asset_traits %like% .pattern, 1, 0)]
}

setnames(RAR, "asset_traits", "asset_traits_dirty")

RAR[, asset_traits := asset_traits_dirty]


RAR <- RAR[order(asset_rank)]

RAR[, asset_traits := gsub("_", ":", asset_traits)]
RAR[, asset_traits := gsub("—", " — ", asset_traits)]
RAR[, asset_traits := gsub("^ —|— $", "", asset_traits)]

oldNames <- names(RAR)[names(RAR) %like% "Background_|Earring_|Hat_|Eyes_|Mouth_|Clothes_|Fur_"]
newNames <- tolower(gsub(" |'", "_", .oldNames))
setnames(RAR, oldNames, newNames)


# Write --------------------------------------------------------------------------------------------
saveRDS(RAR, file = "data/RAR.rds")
saveRDS(traits, file = "data/traits.rds")
