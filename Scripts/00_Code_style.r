# Code style
#install.packages("pacman") # Uncomment if pacman is not installed
pacman::p_load(car, tidyverse, summarytools, rio, linelist) # load packages

library(epikit)

getwd() # check working directory

linelist <- read.csv("./data/linelist_raw.csv") # read in data
View(linelist) # view data

# Print summary statistics of column 'age' in the dataset 'linelist'
summary(linelist$age)

# Importing an Excel file with rio package
linelist <- import("./data/linelist_raw.xlsx")
View(linelist) # view data

linelist_NA <- import(
  "./data/linelist_raw.xlsx",  # No comma here
  which = "Sheet 1", 
  na = c("Missing", "", " ", "NA", "N/A", "unknown", "Unknown", "NULL", "99")
)

View(linelist_NA) # view data

# exporting data with rio package
export(linelist, "./data/my_linelist.xlsx") # will save to working directory
