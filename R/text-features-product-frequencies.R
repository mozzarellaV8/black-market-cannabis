# Darknet Cannabis Analysis
# Derivation of textual features: Product Listings
# Word Frequencies

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(tidytext)
library(stringr)
library(data.table)
library(scales)

### raw data import
cannabis <- fread("~/GitHub/bmc-data/cannabis-V2.csv", stringsAsFactors = T)
cannabis <- as.data.frame(cannabis)

### intermediate data: tokenized dataframe
### begin with code after line 114
p.tokens <- fread("~/GitHub/bmc-data/pTokensV2.csv")
p.tokens <- as.data.frame(p.tokens)

# this dataset contains 18 momths of listings from darknet market Agora
# will need to split this into training and test sets after feature engineering.

# ggplot theme ----------------------------------------------------------------

# define a custom theme for plotting
# modifies theme_minimal() with type set in Gill Sans
# and italic axis titles in Times
pd.theme <- theme_minimal(base_size = 12, base_family = "GillSans") +
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"),
        axis.title = element_text(family = "Times", face = "italic", size = 12),
        axis.title.x = element_text(margin = margin(20, 0, 0, 0)),
        axis.title.y = element_text(margin = margin(0, 20, 0, 0)))

pd.classic <- theme_classic(base_size = 14, base_family = "GillSans") +
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"),
        axis.title = element_text(family = "Times", face = "italic", size = 12))

# Preprocess: Product Listings ------------------------------------------------

# select variables and group by location
products <- cannabis %>%
  select(year, month, day, subsubcat, product, feedback, 
         from, to, usd, rate, vendor) %>%
  group_by(from) %>%
  mutate(linenumber = row_number()) %>%
  arrange(from)

# take a look at some values
products[, 7:12]

# rename variables
colnames(products) <- c("year", "month", "day", "type", "product", "feedback",
                        "origin", "destination", "price.usd", "rate",
                        "vendor", "linenumber")

# reorder columns with linenumber first
products <- products[, c(12, 1:11)]

# clean up variables
products$product <- as.character(products$product)
products$feedback <- as.character(products$feedback)
products$type <- factor(products$type)
products$vendor <- factor(products$vendor)

# Preprocess: Unnest Tokens ---------------------------------------------------

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

# a look at some oberservations
slice(p.tokens, 20000:20010)

# unite date & drop feedback variable
p.tokens <- p.tokens %>%
  unite(date, year, month, day, sep = "-") %>%
  select(-feedback)

p.tokens$date <- as.Date(p.tokens$date)

# Preprocess: Removing Stop Words ---------------------------------------------

# import stop words
data("stop_words")

stop_words
levels(as.factor(stop_words$lexicon))
# [1] "onix"     "SMART"    "snowball"

# remove stop words
p.tokens <- p.tokens %>% anti_join(stop_words)

nrow(p.tokens)
# 2349404 observations of 9 variables
# 236398 stopwords removed

# write.csv(p.tokens, file = "~/GitHub/bmc-data/pTokensV2.csv", row.names = F)

# Word Frequencies ------------------------------------------------------------
# counting and plotting

# Word Count & Plot (in one piped call)
p.tokens %>%
  count(word, sort = T) %>%
  filter(n > 5000) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = n)) +
    geom_bar(stat = "identity") +
    scale_y_discrete(limits = c(0, 5000, 20000, 40000, 60000, 65810),
                     labels = c(0, 5000, 20000, 40000, 60000, "65.8k")) +
    scale_fill_gradient2(low = "deepskyblue4",
                         mid = "gray96", 
                         high = muted("firebrick4"),
                         midpoint = 25000) +
    pd.theme + theme(axis.text.y = element_text(size = 10),
                     axis.title.y = element_text(margin = margin(0, 20, 0, 0))) +
    labs(title = "Word Frequencies: Product Listings",
         fill = "frequency(n)") +
    coord_flip()

# '1', the number, is by far the most common 'word'
# Maybe plot with '1' removed? 
# First get the word counts into the original dataframe.

# Word Count (assined to new dataframe)
p.count <- p.tokens %>%
  count(word, sort = T)

# bind counts
p.tokens <- p.tokens %>%
  left_join(p.count, by = "word")

nrow(p.tokens)
# 2349404 observations of 10 variables

# What words are associated with which prices?
summary(p.tokens$price.usd)
summary(p.tokens$n)

p.tokens %>%
  select(unique(word), unique(n), price.usd) %>%
  filter(n > 5000, price.usd < 1000) %>%
  mutate(word = reorder(word, n)) %>%
  
  ggplot(aes(word, n, fill = price.usd)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "lightblue1",
                      high = "firebrick3") +
  pd.theme + theme(axis.text.y = element_text(size = 10),
                   axis.title.y = element_text(margin = margin(0, 20, 0, 0))) +
  labs(title = "Word Frequencies: Product Listings (n > 5000, price < 1000 USD)",
       fill = "price in USD") +
  coord_flip()

# with color mapped to price, its shown that there's sporadic high price items
# but a barplot at this distance isn't clear enough to draw firm conclusions.

# Word Frequencies by Location ------------------------------------------------
# from an exploratory plot, the top 8 countries with the most listings were:
# USA, Germany, UK, Canada, Netherlands, China, Australia, and No Info

p.tokens$origin <- factor(p.tokens$origin)
levels(p.tokens$origin)


# Word Frequencies by Location: Manual Computation ----------------------------
p.usa <- p.tokens %>% 
  filter(origin == "USA") %>%
  arrange(linenumber)

nrow(p.usa)                 # 1032965
nrow(p.usa)/nrow(p.tokens)  # 0.4396711
# the United States comprises ~44% of cannabis listings by word

p.germany <- filter(p.tokens, origin == "Germany")
nrow(p.germany)                 # 219088
nrow(p.germany)/nrow(p.tokens)  # 0.09325259
# the second most, Germany, comprises just over 9% 

p.uk <- filter(p.tokens, origin == "UK")
nrow(p.uk)                      # 188585
nrow(p.uk)/nrow(p.tokens)       # 0.08026929

p.canada <- filter(p.tokens, origin == "Canada")
nrow(p.canada)                  # 196367
nrow(p.canada)/nrow(p.tokens)   # 0.08358162

p.netherlands <- filter(p.tokens, origin == "Netherlands")
nrow(p.netherlands)                 # 131951
nrow(p.netherlands)/nrow(p.tokens)  # 0.05616361

p.china <- filter(p.tokens, origin == "China")
nrow(p.china)                   # 94740
nrow(p.china)/nrow(p.tokens)    # 0.04032512

p.aus <- filter(p.tokens, origin == "Australia")
nrow(p.aus)                     # 104170
nrow(p.aus)/nrow(p.tokens)      # 0.0443389

p.noinfo <- p.tokens %>%
  filter(origin == "No Info") %>%
  arrange(linenumber)

nrow(p.noinfo)                  # 97370
nrow(p.noinfo)/nrow(p.tokens)   # 0.04144455

# USA: 44%, Germany: 9.3%, Canada: 8.4%, UK: 8.0%
# Netherlands: 5.6%, Aus: 4.4%, China: 4.0%, No Info: 4.1%

# Top Word Frequencies by Country ---------------------------------------------
p.usa %>%
  count(word, sort = T)
#      word    nn
#     <chr> <int>
# 1       1 49158
# 2      oz 20628
# 3   grams 19519
# 4    kush 16943
# 5   grade 15739
# 6     thc 15179
# 7     top 15078
# 8   shelf 14658
# 9  indoor 14517
# 10   free 14266

p.germany %>%
  count(word, sort = T)
#        word     n
#       <chr> <int>
# 1      free 11041
# 2  shipping 10961
# 3      haze 10559
# 4        fe  7698
# 5      hash  7145
# 6   quality  5375
# 7  discount  5193
# 8  required  5002
# 9        gr  4706
# 10       5g  4704

p.china %>%
  count(word, sort = T)

p.tokens %>%
  filter(origin == "Canada") %>%
  count(word, sort = T)

# Interesting to being seeing the most common words by location.
# Just a quick glance shows USA names products more frequently, 
# while Germany has more words related to the transaction process. 

# Note: all this could be done with far less code by simply filtering,
# instead of creating new variables for each location.

# filter for USA
p.tokens %>%
  filter(origin == "USA") %>%
  count(word, sort = T)

# Germany
p.tokens %>%
  filter(origin == "Germany") %>%
  count(word, sort = T)
  
# Calculate Frequencies by Location: Tidy Version -----------------------------

# bind top 8 countries
# this could be a simple select call from the master df,
# but a bit roundabout from following tidytext tutorial.
p.8 <- bind_rows(
  mutate(p.usa, origin == "USA"),
  mutate(p.germany, origin == "Germany"),
  mutate(p.uk, origin == "UK"),
  mutate(p.canada, origin == "Canada"),
  mutate(p.netherlands, origin == "Netherlands"),
  mutate(p.china, origin == "China"),
  mutate(p.aus, origin == "Australia"),
  mutate(p.noinfo, origin == "No Info")
)

usa.pct <- p.tokens %>%
  filter(origin == "USA") %>%
  count(word) %>%
  transmute(word, USA = n / sum(n)) %>%
  arrange(desc(USA))
  

# Word Frequencies: Top 8 Countries by Listing Count --------------------------

# frequency as percentage for top 8 countries
frequency.8 <- p.8 %>%
  count(origin, word) %>%
  mutate(pct = n / sum(n)) %>%
  arrange(desc(pct))

frequency.8$origin <- factor(frequency.8$origin)
nrow(frequency.8) # 9928

ggplot(frequency.8, aes(x = n, y = pct, color = pct)) +
  geom_text(aes(label = word), check_overlap = T, vjust = 1.5) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
  scale_color_gradient(limits = c(0, 1), 
                       low = "steelblue4", 
                       high = "gray92") +
  scale_x_log10(labels = waiver()) +
  scale_y_log10(labels = percent_format()) +
  facet_wrap(~ origin, ncol = 2) +
  pd.theme +
  theme(legend.position = "none",
        strip.background = element_rect(fill = "gray96",
                                        color = "black")) +
  labs(title = "Product Listings: Word Frequency ~ Origin", 
       x = "word frequency", y = "")

# Word Frequencies: subset of Top 8 with n > 1000 -----------------------------
ff8 <- frequency.8 %>%
  filter(n > 1000)

nrow(ff8) # 410

ggplot(ff8, aes(x = n, y = pct, color = pct)) +
  geom_text(aes(label = word), check_overlap = T, vjust = 1.5) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
  scale_color_gradient(limits = c(0, 1), 
                       low = "steelblue4", 
                       high = "gray92") +
  scale_x_log10(labels = waiver()) +
  scale_y_log10(labels = percent_format()) +
  facet_wrap(~ origin, ncol = 2) +
  pd.theme +
  theme(legend.position = "none",
        panel.border = element_rect(color = "gray82", fill = NA, 
                                    size = 0.25),
        strip.background = element_rect(fill = "gray96",
                                        color = "black")) +
  labs(title = "Product Listings: Word Frequency ~ Origin (n > 1000)", 
       x = "word frequency", y = "")

# Word Frequencies: Top 4 Countries by Listing Count --------------------------
f4 <- frequency.8 %>%
  filter(origin == "USA" | origin == "UK" | 
           origin == "Germany" | origin == "Canada")

ggplot(f4, aes(x = n, y = pct, color = pct)) +
  geom_text(aes(label = word), check_overlap = T, vjust = 1.5) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
  scale_color_gradient(limits = c(0, 1), 
                       low = "steelblue4", 
                       high = "gray92") +
  scale_x_log10(labels = waiver()) +
  scale_y_log10(labels = percent_format()) +
  facet_wrap(~ origin, ncol = 1) +
  pd.theme +
  theme(legend.position = "none",
        panel.border = element_rect(color = "gray82", fill = NA, 
                                    size = 0.25),
        strip.background = element_rect(fill = "gray96",
                                        color = "black")) +
  labs(title = "Product Listings: Word Frequency ~ Origin", 
       x = "word frequency", y = "")

# Word Frequencies: subset of Top 4 with n > 1000 -----------------------------
ff4 <- f4 %>% filter(n > 1000)

ggplot(ff4, aes(x = n, y = pct, color = pct)) +
  geom_text(aes(label = word), check_overlap = T, vjust = 1.5) +
  geom_jitter(alpha = 0.1, size = 2.5, width = 0.3, height = 0.3) +
  scale_color_gradient(limits = c(0, 1), 
                       low = "steelblue4", 
                       high = "gray92") +
  scale_x_log10(labels = waiver()) +
  scale_y_log10(labels = percent_format()) +
  facet_wrap(~ origin, ncol = 1) +
  pd.theme +
  theme(legend.position = "none",
        panel.border = element_rect(color = "gray82", fill = NA, 
                                    size = 0.25),
        strip.background = element_rect(fill = "gray96",
                                        color = "black")) +
  labs(title = "Product Listings: Word Frequency ~ Origin (n > 1000)", 
       x = "word frequency", y = "")

# Correlation between Words and Origins ---------------------------------------

cor.test(data = frequency.8[frequency.8$origin == "USA", ], ~ pct + n)
cor.test(data = frequency.8[frequency.8$origin == "China", ], ~ pct + n)
cor.test(data = frequency.8, ~ pct + n)

