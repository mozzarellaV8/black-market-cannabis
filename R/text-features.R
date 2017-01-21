# Darknet Cannabis Analysis
# Derivation of textual features

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(tidytext)
library(data.table)

cannabis <- fread("data/cannabis-V2.csv", stringsAsFactors = T)
cannabis <- as.data.frame(cannabis)

# this dataset contains 18 momths of listings from darknet market Agora
# will need to split this into training and test sets after feature engineering.

# Product Listings ------------------------------------------------------------
# following tidytext

products <- cannabis %>%
  select(year, month, day, subsubcat, product, feedback, 
         from, to, usd, rate, vendor) %>%
  group_by(from) %>%
  mutate(linenumber = row_number()) %>%
  ungroup()

products[, 6:12]
colnames(products) <- c("year", "month", "day", "type", "product", "feedback",
                        "origin", "destination", "price.usd", "rate",
                        "vendor", "linenumber")

products <- products[, c(12, 1:11)]

# clean up variables
products$product <- as.character(products$product)
products$feedback <- as.character(products$feedback)
products$type <- factor(products$type)
products$vendor <- factor(products$vendor)

# unnest tokens: product listing ----------------------------------------------
# one token-per-row format
p.tokens <- products %>%
  unnest_tokens(word, product)

nrow(p.tokens)
# 2585802 observations of 12 variables

p.tokens
# # A tibble: 2,585,802 × 12
#     linenumber   year  month    day       type                       feedback origin    destination price.usd   rate     vendor    word
# <int>   <fctr> <fctr> <fctr>     <fctr>                                 <chr>  <fctr>       <fctr>     <dbl>  <dbl>     <fctr>   <chr>
#  1           1   2014     01     01       Hash Feedbacks: No feedbacks found.     EU     Wolrdwide     214.24 770.44  DreamTeam     10g
#  2           1   2014     01     01       Hash Feedbacks: No feedbacks found.     EU     Wolrdwide     214.24 770.44  DreamTeam   first
#  3           1   2014     01     01       Hash Feedbacks: No feedbacks found.     EU     Wolrdwide     214.24 770.44  DreamTeam quality

slice(p.tokens, 20000:20010)

# Most common words -----------------------------------------------------------





