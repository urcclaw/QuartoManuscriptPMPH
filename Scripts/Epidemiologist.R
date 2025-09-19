# The Epidemiologist R Handbook

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
  lubridate,    # working with dates
  epikit,       # age_categories() function
  apyramid,     # age pyramids
  RColorBrewer, # color palettes
  formattable,  # fancy tables
  kableExtra,    # table formatting
  survival,     # survival analysis
  survminer,    # plotting survival curves
  flextable     # converting tables to pretty images
  )

# Import data
linelist <- import(here("./data/linelist_cleaned.xlsx"))
View(linelist) # view data

# Summarise data

linelist |> 
     select(age_years, gender, outcome, fever, temp, hospital) |>  # keep only the columns of interest
     tbl_summary() |>                          # default
     as_flex_table() |>
     autofit()

## Simple statistical tests
# Chi-squared test
linelist %>% 
     select(gender, outcome) %>%    # keep variables of interest
     tbl_summary(by = outcome) %>%  # produce summary table and specify grouping variable
     add_p()                        # specify what test to perform

# T-test
linelist %>% 
     select(age_years, outcome) %>%             # keep variables of interest
     tbl_summary(                               # produce summary table
          statistic = age_years ~ "{mean} ({sd})", # specify what statistics to show
          by = outcome) %>%                        # specify the grouping variable
     add_p(age_years ~ "t.test")                # specify what tests to perform

# Wilcoxon rank sum test
linelist %>% 
     select(age_years, outcome) %>%                       # keep variables of interest
     tbl_summary(                                         # produce summary table
          statistic = age_years ~ "{median} ({p25}, {p75})", # specify what statistic to show (this is default so could remove)
          by = outcome) %>%                                  # specify the grouping variable
     add_p(age_years ~ "wilcox.test")                     # specify what test to perform (default so could leave brackets empty)

# Kruskal-wallis test
linelist %>% 
     select(age_years, outcome) %>%                       # keep variables of interest
     tbl_summary(                                         # produce summary table
          statistic = age_years ~ "{median} ({p25}, {p75})", # specify what statistic to show (default, so could remove)
          by = outcome) %>%                                  # specify the grouping variable
     add_p(age_years ~ "kruskal.test")                    # specify what test to perform

# Correlations
correlation_tab <- linelist %>% 
     select(generation, age, ct_blood, days_onset_hosp, wt_kg, ht_cm) %>%   # keep numeric variables of interest
     correlate()      # create correlation table (using default pearson)

correlation_tab    # print

## remove duplicate entries (the table above is mirrored) 
correlation_tab <- correlation_tab %>% 
     shave()

## view correlation table 
correlation_tab
## plot correlations 
rplot(correlation_tab)


# Univariate and multivariable regression
# Import data
linelist <- import(here("./data/linelist_cleaned.xlsx"))
View(linelist) # view data

# Summarise data
linelist |> 
     select(age_years, gender, outcome, fever, temp, hospital) |>  # keep only the columns of interest
     tbl_summary() |>                          # default
     as_flex_table() |>
     autofit()

# Clean data
## define variables of interest 
explanatory_vars <- c("gender", "fever", "chills", "cough", "aches", "vomit")

## convert dichotomous variables to 0/1 
linelist <- linelist %>%  
     mutate(across(                                      
          .cols = all_of(c(explanatory_vars, "outcome")),  ## for each column listed and "outcome"
          .fns = ~case_when(                              
               . %in% c("m", "yes", "Death")   ~ 1,           ## recode male, yes and death to 1
               . %in% c("f", "no",  "Recover") ~ 0,           ## female, no and recover to 0
               TRUE                            ~ NA_real_)    ## otherwise set to missing
     )
     )

# Summarise data
linelist |> 
     select(age_years, gender, outcome, fever, temp, hospital) |>  # keep only the columns of interest
     tbl_summary() |>                          # default
     as_flex_table() |>
     autofit()

# Drop rows with missing values
## add in age_category to the explanatory vars 
explanatory_vars <- c(explanatory_vars, "age_cat")

## drop rows with missing information for variables of interest 
linelist <- linelist %>% 
     drop_na(any_of(c("outcome", explanatory_vars)))

# Summarise data
linelist |> 
     select(age_years, gender, outcome, fever, temp, hospital) |>  # keep only the columns of interest
     tbl_summary() |>                          # default
     as_flex_table() |>
     autofit()

# Univariate regression
univ_tab <- linelist %>% 
     dplyr::select(explanatory_vars, outcome) %>% ## select variables of interest
     
     tbl_uvregression(                         ## produce univariate table
          method = glm,                           ## define regression want to run (generalised linear model)
          y = outcome,                            ## define outcome variable
          method.args = list(family = binomial),  ## define what type of glm want to run (logistic)
          exponentiate = TRUE                     ## exponentiate to produce odds ratios (rather than log odds)
     )

## view univariate results table 
univ_tab
## convert to flextable
univ_tab %>% 
     as_flex_table() %>%
     autofit()

# Multivariable regression
mv_reg <- glm(outcome ~ gender + fever + chills + cough + aches + vomit + age_cat, family = "binomial", data = linelist)

summary(mv_reg)

## choose a model using forward selection based on AIC
## you can also do "backward" or "both" by adjusting the direction
final_mv_reg <- mv_reg %>%
     step(direction = "forward", trace = FALSE)
summary(final_mv_reg)

# Combine with gtsummary
## show results table of final regression 
mv_tab <- tbl_regression(final_mv_reg, exponentiate = TRUE)
mv_tab
## convert to flextable
mv_tab %>%
     as_flex_table() %>%
     autofit()
## combine with univariate results 
tbl_merge(
     tbls = list(univ_tab, mv_tab),                          # combine
     tab_spanner = c("**Univariate**", "**Multivariable**")) # set header names
## convert to flextable
tbl_merge(
     tbls = list(univ_tab, mv_tab),                          # combine
     tab_spanner = c("**Univariate**", "**Multivariable**")) %>%
     as_flex_table() %>%
     autofit()
# Export final table as image
tbl_merge(
     tbls = list(univ_tab, mv_tab),                          # combine
     tab_spanner = c("**Univariate**", "**Multivariable**")) %>%
     as_flex_table() %>%
     autofit() %>%
     save_as_image(path = here("./results/regression_table.png"))
# Save final model
saveRDS(final_mv_reg, here("./results/final_mv_reg.rds"))
# Load final model
final_mv_reg <- readRDS(here("./results/final_mv_reg.rds"))


# Contact tracing
contacts <- import(here("data", "godata", "contacts_clean.rds")) %>% 
     mutate(age_class = forcats::fct_rev(age_class)) %>% 
     select(contact_id, contact_status, firstName, lastName, gender, age,
            age_class, occupation, date_of_reporting, date_of_data_entry,
            date_of_last_exposure = date_of_last_contact,
            date_of_followup_start, date_of_followup_end, risk_level, was_case, admin_2_name) %>% 
     mutate(admin_2_name = replace_na(admin_2_name, "Djembe"))

apyramid::age_pyramid(
     data = contacts,                                   # use contacts dataset
     age_group = "age_class",                           # categorical age column
     split_by = "gender") +                             # gender for halfs of pyramid
     labs(
          fill = "Gender",                                 # title of legend
          title = "Age/Sex Pyramid of COVID-19 contacts")+ # title of the plot
     theme_minimal()                                    # simple background

# Survival analysis
# Import data
# import linelist
linelist_case_data <- rio::import("./data/linelist_cleaned.rds")
View(linelist_case_data) # view data
# Data management and transformation
#create a new data called linelist_surv from the linelist_case_data

linelist_surv <-  linelist_case_data %>% 
     
     dplyr::filter(
          # remove observations with wrong or missing dates of onset or date of outcome
          date_outcome > date_onset) %>% 
     
     dplyr::mutate(
          # create the event var which is 1 if the patient died and 0 if he was right censored
          event = ifelse(is.na(outcome) | outcome == "Recover", 0, 1), 
          
          # create the var on the follow-up time in days
          futime = as.double(date_outcome - date_onset), 
          
          # create a new age category variable with only 3 strata levels
          age_cat_small = dplyr::case_when( 
               age_years < 5  ~ "0-4",
               age_years >= 5 & age_years < 20 ~ "5-19",
               age_years >= 20   ~ "20+"),
          
          # previous step created age_cat_small var as character.
          # now convert it to factor and specify the levels.
          # Note that the NA values remain NA's and are not put in a level "unknown" for example,
          # since in the next analyses they have to be removed.
          age_cat_small = fct_relevel(age_cat_small, "0-4", "5-19", "20+")
     )
# view the new linelist_surv data
View(linelist_surv)
summary(linelist_surv$futime)
# cross tabulate the new event var and the outcome var from which it was created
# to make sure the code did what it was intended to
linelist_surv %>% 
     tabyl(outcome, event)

linelist_surv %>% 
     tabyl(age_cat_small, age_cat)

linelist_surv %>% 
     select(case_id, age_cat_small, date_onset, date_outcome, outcome, event, futime) %>% 
     head(10)

linelist_surv %>% 
     tabyl(gender, age_cat_small, show_na = F) %>% 
     adorn_totals(where = "both") %>% 
     adorn_percentages() %>% 
     adorn_pct_formatting() %>% 
     adorn_ns(position = "front")

# Basics of survival analysis
# Building a surv-type object
# Use Suv() syntax for right-censored data
survobj <- Surv(time = linelist_surv$futime,
                event = linelist_surv$event)
# view the survobj object
survobj

linelist_surv %>% 
     select(case_id, date_onset, date_outcome, futime, outcome, event) %>% 
     head(10)
#print the 50 first elements of the vector to see how it presents
head(survobj, 10)

# fit the KM estimates using a formula where the Surv object "survobj" is the response variable.
# "~ 1" signifies that we run the model for the overall survival  
linelistsurv_fit <-  survival::survfit(survobj ~ 1)

#print its summary for more details
summary(linelistsurv_fit)

# Plotting Kaplan-Meir curves
plot(linelistsurv_fit, 
     xlab = "Days of follow-up",    # x-axis label
     ylab="Survival Probability",   # y-axis label
     main= "Overall survival curve" # figure title
)

# original plot
plot(
     linelistsurv_fit,
     xlab = "Days of follow-up",       
     ylab = "Survival Probability",       
     mark.time = TRUE,              # mark events on the curve: a "+" is printed at every event
     conf.int = FALSE,              # do not plot the confidence interval
     main = "Overall survival curve and cumulative mortality"
)

# draw an additional curve to the previous plot
lines(
     linelistsurv_fit,
     lty = 3,             # use different line type for clarity
     fun = "event",       # draw the cumulative events instead of the survival 
     mark.time = FALSE,
     conf.int = FALSE
)

# add a legend to the plot
legend(
     "topright",                               # position of legend
     legend = c("Survival", "Cum. Mortality"), # legend text 
     lty = c(1, 3),                            # line types to use in the legend
     cex = .85,                                # parametes that defines size of legend text
     bty = "n"                                 # no box type to be drawn for the legend
)

# Comparison of survival curves
# Log rank test
# create the new survfit object based on gender
linelistsurv_fit_sex <-  survfit(Surv(futime, event) ~ gender, data = linelist_surv)

# set colors
col_sex <- c("lightgreen", "darkgreen")

# create plot
plot(
     linelistsurv_fit_sex,
     col = col_sex,
     xlab = "Days of follow-up",
     ylab = "Survival Probability")

# add legend
legend(
     "topright",
     legend = c("Female","Male"),
     col = col_sex,
     lty = 1,
     cex = .9,
     bty = "n")

# add p-value of log-rank test to the plot
survminer::ggsurvplot(
     linelistsurv_fit_sex, 
     data = linelist_surv,          # again specify the data used to fit linelistsurv_fit_sex 
     conf.int = FALSE,              # do not show confidence interval of KM estimates
     surv.scale = "percent",        # present probabilities in the y axis in %
     break.time.by = 10,            # present the time axis with an increment of 10 days
     xlab = "Follow-up days",
     ylab = "Survival Probability",
     pval = T,                      # print p-value of Log-rank test 
     pval.coord = c(40,.91),        # print p-value at these plot coordinates
     risk.table = T,                # print the risk table at bottom 
     legend.title = "Gender",       # legend characteristics
     legend.labs = c("Female","Male"),
     font.legend = 10, 
     palette = "Dark2",             # specify color palette 
     surv.median.line = "hv",       # draw horizontal and vertical lines to the median survivals
     ggtheme = theme_light()        # simplify plot background
)

# create the new survfit object based on source of infection
linelistsurv_fit_source <-  survfit(
     Surv(futime, event) ~ source,
     data = linelist_surv
)

# plot
ggsurvplot( 
     linelistsurv_fit_source,
     data = linelist_surv,
     size = 1, linetype = "strata",   # line types
     conf.int = T,
     surv.scale = "percent",  
     break.time.by = 10, 
     xlab = "Follow-up days",
     ylab= "Survival Probability",
     pval = T,
     pval.coord = c(40,.91),
     risk.table = T,
     legend.title = "Source of \ninfection",
     legend.labs = c("Funeral", "Other"),
     font.legend = 10,
     palette = c("#E7B800","#3E606F"),
     surv.median.line = "hv", 
     ggtheme = theme_light()
)

# Cox proportional hazards model
#fitting the cox model
linelistsurv_cox_sexage <-  survival::coxph(
     Surv(futime, event) ~ gender + age_cat_small, 
     data = linelist_surv
)


#printing the model fitted
linelistsurv_cox_sexage

#fit the model
linelistsurv_cox <-  coxph(
     Surv(futime, event) ~ gender + age_years+ source + days_onset_hosp,
     data = linelist_surv
)


#test the proportional hazard model
linelistsurv_ph_test <- cox.zph(linelistsurv_cox)
linelistsurv_ph_test
#plot the schoenfeld residuals
survminer::ggcoxzph(linelistsurv_ph_test)


