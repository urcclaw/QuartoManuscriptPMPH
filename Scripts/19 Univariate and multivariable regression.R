# 19  Univariate and multivariable regression

# Ensures the package "pacman" is installed
if (!require("pacman")) install.packages("pacman")

# Packages available from CRAN
##############################
pacman::p_load(
  rio,          # File import
  here,         # File locator
  tidyverse,    # data management + ggplot2 graphics, 
  stringr,      # manipulate text strings 
  purrr,        # loop over objects in a tidy way
  gtsummary,    # summary statistics and tests 
  broom,        # tidy up results from regressions
  lmtest,       # likelihood-ratio tests
  parameters,  # alternative to tidy up results from regressions
  skimr,        # get overview of data
  rstatix,      # summary statistics and statistical tests
  janitor,      # adding totals and percents to tables
  scales,       # easily convert proportions to percents
  corrr,        # correlation analayis for numeric variables
  easystats,    #
  flextable     # converting tables to pretty images
  )

library(gtsummary)
library(flextable)   # 👈 THIS IS REQUIRED!

# Import data
linelist <- import(here("./data/linelist_cleaned.xlsx"))
View(linelist) # view data

# Summarise data

trial |>
     select(trt, age, grade) |>
     tbl_summary(by = trt) |>
     add_p() |>
     as_flex_table()


linelist %>% 
     select(age_years, gender, outcome, fever, temp, hospital) %>%  # keep only the columns of interest
     tbl_summary() |>                          # default
     as_flex_table() |>
     autofit()
