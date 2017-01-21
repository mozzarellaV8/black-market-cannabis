# Darknet Cannabis Analysis
# Product and Description import

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(tidytext)
library(data.table)

getwd()
pdir <- "~/GitHub/ag-pd/"
setwd(pdir)

# create list of csv files to read in
pd.list <- list.files(pdir, pattern = ".csv", recursive = T, all.files = T)

# initialize dataframe to store
agora.pd <- data.frame()

# read in each csv and bind
for (i in 1:length(pd.list)) {
  
  temp <- fread(pd.list[i])
  temp <- as.data.frame(temp)
  
  agora.pd <- rbind(temp, agora.pd)
  
}

# TODO: needs cleanse of `from` variable
# can be pulled from previous scripts
# consider leaving 'fake' names - i.e. Does having an official location help sales? 

setwd("~/Documents/darknet-cannabis-quality")
write.csv(agora.pd, file = "data/darknet-description-V1.csv", row.names = F)
