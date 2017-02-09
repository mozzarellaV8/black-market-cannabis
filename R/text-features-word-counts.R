# Agra Marketplace Analysis
# Exploratory: Product & Feedback Variables

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(data.table)
library(tidytext)
library(qdap)
library(ggplot2)
library(broom)

cannabis <- fread("~/GitHub/bmc-data/cannabis-V2.csv", stringsAsFactors = T)
cannabis <- as.data.frame(cannabis)
str(cannabis)

# ggplot theme ----------------------------------------------------------------

# define a custom theme for plotting
# modifies theme_minimal() with type set in Gill Sans
# and italic axis titles in Times
pd.theme <- theme_minimal(base_size = 12, base_family = "GillSans") +
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"),
        axis.title = element_text(family = "Times", face = "italic", size = 12),
        axis.title.x = element_text(margin = margin(20, 0, 0, 0)),
        axis.title.y = element_text(margin = margin(0, 20, 0, 0)))

pd.classic <- theme_classic(base_size = 12, base_family = "GillSans") +
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"),
        axis.title = element_text(family = "Times", face = "italic", size = 12),
        axis.title.x = element_text(margin = margin(20, 0, 0, 0)),
        axis.title.y = element_text(margin = margin(0, 20, 0, 0)))

# Cannabis: Feedback or Not? --------------------------------------------------

# Cannabis: Has Feedback/Doesn't Have Feedback
# cannabis$fb.yn <- ifelse(cannabis$fb == -1, 0, 1)
# summary(cannabis$fb.yn)

# write.csv(cannabis, file = "~/GitHub/bmc-data/cannabis-V2.csv", row.names = F)

# logistic function for plotting
binomial_smooth <- function(...) {
  geom_smooth(method = "glm", 
              method.args = list(family = "binomial"))
}

# filter prices under 20000 and plot w/ logistic line
cannabis %>%
  filter(usd < 20000) %>%
  ggplot(aes(usd, fb.yn)) + 
  geom_point(position = position_jitter(width = 0.3, height = 0.06), 
             alpha = 0.25, shape = 21, size = 1.5) +
  binomial_smooth() +
  scale_y_discrete(limits = c(0, 1)) +
  pd.theme

# filter prices under 5000
cannabis %>%
  filter(usd < 5000) %>%
  ggplot(aes(usd, fb.yn)) + 
  geom_point(position = position_jitter(width = 0.3, height = 0.10), 
             alpha = 0.1, shape = 21, size = 1.5) +
  binomial_smooth() +
  scale_y_discrete(limits = c(0, 1)) +
  pd.theme +
  labs(title = "Presence of Feedback ~ Price in USD (< $5,000)",
       y = "feedback", x = "price in USD")

# filter prices under 800
cannabis %>%
  filter(usd < 800) %>%
  ggplot(aes(usd, fb.yn)) + 
  geom_point(position = position_jitter(width = 0.3, height = 0.1), 
             alpha = 0.1, shape = 21, size = 2) +
  stat_smooth(method = "gam") +
  scale_y_discrete(limits = c(0, 1)) +
  pd.theme +
  labs(title = "Presence of Feedback ~ Price in USD (< $800)",
       y = "feedback", x = "price in USD")

# plot ordinal
ggplot(mj1k, aes(usd, fb, fill = fb)) +
  geom_point(alpha = 0.4, size = 3, shape = 21,
             position = position_jitter(width = 0.3, height = 0.25))

# interesting: 5 and -1 all across, but what of 0-4? 
# how far do they reach in the USD axis?

library(broom)

# subset prices under 1000 in 2014
mj1k <-  cannabis %>%
  filter(usd < 1000 & year == "2014")

fb.usd01 <- glm(fb.yn ~ usd + from + rate, mj1k, family = "binomial")
summary(fb.usd01)
fb.01.coef <- tidy(fb.usd01)


library(randomForest)
library(caret)





# summaries -------------------------------------------------------------------

summary(cannabis$p.words)
summary(cannabis$f.words)

# product listings: word count distribution
ggplot(cannabis, aes(p.words)) +
  geom_histogram(binwidth = 1, fill = "white", color = "black") +
  labs(title = "Product Listings: Word Count Distribution", 
       x = "number of words") +
  pd.classic

# product listings: word count distribution by location
# filter top 8
by.country <- cannabis %>%
  group_by(from) %>%
  count(from, sort = T)

#           from      n
#         <fctr>  <int>
# 1          USA 161038
# 2      Germany  36834
# 3           UK  32859
# 4       Canada  29957
# 5  Netherlands  26707
# 6        China  25034
# 7    Australia  21350
# 8      No Info  17761
# 9           EU  17693
# 10  Undeclared   5173

the8 <- by.country[1:8, 1]
the8$from <- factor(the8$from)

top8 <- cannabis %>%
  filter(from %in% the8$from)

top8$from <- factor(top8$from)



# Word Counts -----------------------------------------------------------------

a$fwd <- discretize(a$f.words, method = "interval", categories = 22)
a$fwd <- NULL

a$fwd <- ifelse(a$f.words <= 25, 25, 
                ifelse(a$f.words > 25 & a$f.words <= 50, 50, 
                       ifelse(a$f.words > 50 & a$f.words <= 75, 75,
                              ifelse(a$f.words > 75 & a$f.words <= 100, 100,
         ifelse(a$f.words > 100 & a$f.words <= 125, 125, 
                ifelse(a$f.words > 125 & a$f.words <= 150, 150,
                       ifelse(a$f.words > 150 & a$f.words <= 175, 175,
                              ifelse(a$f.words > 175 & a$f.words <= 200, 200,
         ifelse(a$f.words > 200 & a$f.words <= 225, 225, 
                ifelse(a$f.words > 225 & a$f.words <= 250, 250,
                       ifelse(a$f.words > 250 & a$f.words <= 275, 275,
                              ifelse(a$f.words > 275 & a$f.words <= 300, 300,
         ifelse(a$f.words > 300 & a$f.words <= 325, 325,
                ifelse(a$f.words > 325 & a$f.words <= 350, 350,
                       ifelse(a$f.words > 350 & a$f.words <= 375, 375,
                              ifelse(a$f.words > 375 & a$f.words <= 400, 400,
         ifelse(a$f.words > 400 & a$f.words <= 425, 425,
                ifelse(a$f.words > 425 & a$f.words <= 450, 450,
                       ifelse(a$f.words > 450 & a$f.words <= 475, 475,
                              ifelse(a$f.words > 475 & a$f.words <= 500, 500,
         ifelse(a$f.words > 500 & a$f.words <= 525, 525,
                ifelse(a$f.words > 525 & a$f.words <= 550, 550, NA))))))))))))))))))))))



# word count over time --------------------------------------------------------

# prep
dates <- seq(as.Date("2014-01-01"), as.Date("2015-07-01"), by = "month")
dw <- seq(as.Date("2014-01-01"), as.Date("2015-07-01"), by = "week")

summary(a$f.words)
hist(a$f.words)

# horizontal 
p.fw01 <- ggplot(a, aes(f.words, reorder(all.c))) + 
  geom_tile(aes(f.words, reorder(all.c), fill = f.words),  
            color = "white", na.rm = T) +
  scale_fill_gradient2(low = " deepskyblue4", mid = "bisque2",
                       high = "firebrick3", midpoint = 275) +
  scale_x_continuous(breaks = seq(0, 600, 25)) +
  theme_minimal(base_size = 14, base_family = "GillSans") +
  
  theme(
    plot.margin = unit(c(0.25, 0.25, 0.25, 0.25), "cm"), 
    axis.text.y = element_text(size = 8, lineheight = 1.2, hjust = 1),
    axis.text.x = element_text(size = 12.75),
    axis.title.x = element_text(family = "Times New Roman", 
                                face = "italic", margin = margin(20, 0, 0, 0)),
    legend.text = element_text(size = 8),
    legend.position = "bottom",
    legend.key = element_blank()) +
  
  labs(title = "Categories by Feedback (word count)",
       x = "number of words", y = "", fill = "")

p.fw01

# horizontal 2
p.fw02 <- ggplot(a, aes(fwd, reorder(all.c))) + 
  geom_tile(aes(fwd, reorder(all.c), fill = fwd),  
            color = "white", na.rm = T) +
  scale_fill_gradient2(low = " deepskyblue4", mid = "bisque2",
                       high = "firebrick3", midpoint = 270) +
  scale_x_continuous(breaks = seq(0, 600, 25)) +
  theme_minimal(base_size = 11, base_family = "GillSans") +
  
  theme(
    plot.margin = unit(c(0.25, 0.25, 0.25, 0.25), "cm"), 
    axis.text.y = element_text(size = 8.25, lineheight = 1.2, hjust = 1),
    axis.text.x = element_text(size = 10),
    axis.title.x = element_text(family = "Times New Roman", 
                                face = "italic", margin = margin(20, 0, 0, 0)),
    legend.text = element_text(size = 8)) +
  
  labs(title = "Categories by Feedback (~ number of words)",
       x = "number of words", y = "", fill = "")

p.fw02
