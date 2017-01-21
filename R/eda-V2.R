# Darknet Cannabis Analysis
# EDA-V2

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)

cannabis <- fread("data/cannabis-V1.csv", stringsAsFactors = T)
cannabis <- as.data.frame(cannabis)
summary(cannabis)

# create ggplot themes --------------------------------------------------------

# modified minimal using GillSans and Times
pd.min <- theme_minimal(base_size = 14, base_family = "GillSans") +
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"),
        axis.title = element_text(family = "Times", face = "italic", size = 12),
        axis.title.x = element_text(margin = margin(15, 0, 0, 0)),
        axis.title.y = element_text(margin = margin(0, 10, 0, 0)))

# modified classic using Gill Sans and Times

pd.classic <- theme_classic(base_size = 14, base_family = "GillSans") +
  theme(plot.margin = unit(c(1, 1, 1, 1), "cm"),
        axis.title = element_text(family = "Times", face = "italic", size = 12),
        axis.title.x = element_text(margin = margin(10, 0, 0, 0)),
        axis.title.y = element_text(margin = margin(0, 10, 0, 0)))

# Parse product listings ------------------------------------------------------

# unique dataframe
cannabis.u <- unique(cannabis)
# this drops 30 observations

# what about unique by product listing?
cannabis.u <- cannabis[unique(cannabis$product), ]
# now we have 30547 observations

summary(cannabis.u)

# arrange chronologically
cannabis.u <- cannabis.u %>%
  arrange(date)

# does a vendor have more listings lead to more feedback?
# calculate number of listings per vendor + rel freq
cannabis.v <- cannabis.u %>%
  group_by(vendor) %>%
  summarise(n = n()) %>%
  mutate(freq.listings = n/sum(n)) %>%
  arrange(desc(n))
  
colnames(cannabis.v) <- c("vendor", "num.listings", "freq.listings")

# look at more 'active' vendors
cannabis.vp <- cannabis.v %>%
  filter(num.listings > 100)

# Plots: 'active' vendors ~ number of listings --------------------------------

summary(cannabis.vp$num.listings)

ggplot(cannabis.vp, aes(vendor, num.listings, color = num.listings)) +
  geom_point(size = 3.5) +
  scale_color_gradient2(low = "deepskyblue4", high = "firebrick3",
                        mid = "gray88", midpoint = 250) +
  pd.min +
  labs(title = "Vendor ~ Number of Unique Listings (n > 100)", 
       y = "number of listings", x = "", color = "") + 
  coord_flip()

# sorted by number of listings
ggplot(cannabis.vp, aes(reorder(vendor, num.listings), num.listings, color = num.listings)) +
  geom_point(size = 3.5) +
  scale_color_gradient2(low = "deepskyblue4", high = "firebrick3",
                        mid = "gray88", midpoint = 250) +
  pd.min +
  labs(title = "Vendor ~ Number of Unique Listings (n > 100)", 
       y = "number of listings", x = "", color = "") + 
  coord_flip()

# same plot, don't flip coordinates
ggplot(cannabis.vp, aes(vendor, num.listings, color = num.listings)) +
  geom_point(size = 3.5) +
  scale_color_gradient2(low = "deepskyblue", high = "firebrick3",
                        mid = "gray88", midpoint = 250) +
  labs(title = "Vendor ~ Number of Unique Listings (n > 100)", 
       y = "number of listings", x = "", color = "") +
  pd.min +
  theme(axis.text.x = element_text(angle = 45, size = 10,
                                   hjust = 1, vjust = 1))

# same plot, sorted by number of listings
ggplot(cannabis.vp, aes(reorder(vendor, num.listings), num.listings, 
                        color = num.listings)) +
  geom_point(size = 3.5) +
  scale_color_gradient2(low = "deepskyblue", high = "firebrick3",
                        mid = "gray88", midpoint = 250) +
  labs(title = "Vendor ~ Number of Unique Listings (n > 100)", 
       y = "number of listings", x = "", color = "") +
  pd.min +
  theme(axis.text.x = element_text(angle = 45, size = 10,
                                   hjust = 1, vjust = 1))

# merge back into cannabis dataframes
cannabis.u <- left_join(cannabis.u, cannabis.v, by = "vendor")
cannabis <- left_join(cannabis, cannabis.v, by = "vendor")


# Feedback --------------------------------------------------------------------

# relative feedback score frequency
fb.freq <- cannabis %>%
  group_by(fb) %>%
  summarise(n = n()) %>%
  mutate(freq = n/sum(n))

colnames(fb.freq) <- c("fb", "num.fb.score", "fb.relfreq")

cannabis <- left_join(cannabis, fb.freq, by = "fb")
cannabis.u <- left_join(cannabis.u, fb.freq, by = "fb")

# write.csv(cannabis, file = "data/cannabis-V2.csv", row.names = F)
# write.csv(cannabis.u, file = "data/cannabis-u-V2.csv", row.names = F)



# Origin Location -------------------------------------------------------------

summary(cannabis.u$from)

# filter out locations with zero listings
origin <- cannabis %>%
  group_by(from) %>%
  summarise(n = n()) %>%
  mutate(from.freq = n/sum(n)) %>%
  filter(n > 0) %>%
  arrange(desc(n))

colnames(origin) <- c("from", "from.count", "from.freq")
origin$from <- factor(origin$from)

# interesting but incomplete
# origin by vendor-number of listings
ggplot(cannabis, aes(from, num.listings)) +
  geom_boxplot() +
  pd.min +
  coord_flip()

summary(cannabis$from)
summary(origin$from.count)
#     Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#       1       5     488    8247    2854  161000

# factor removes zeroes
cannabis$from <- factor(cannabis$from)

# Plots: Origin location counts -----------------------------------------------

# barplot from cannabis/full dataframe
ggplot(cannabis, aes(from, fill = ..count..)) +
  geom_bar() +
  scale_fill_gradient2(low = "deepskyblue4", high = "firebrick3",
                       mid = "gray88", midpoint = 8247) +
  labs(title = "Number of Listings ~ Origin Location", 
       y = "number of listings", fill = "") +
  pd.classic +
  coord_flip()

# USA dominates this. Remove US and plot.
# filter out USA
cannabis.world <- cannabis %>%
  filter(from != "USA")

summary(cannabis.world)
# 404080 obs to 243042 obs

# plot without USA
ggplot(cannabis.world, aes(from, fill = ..count..)) +
  geom_bar() +
  scale_fill_gradient2(low = "deepskyblue4", high = "firebrick3",
                       mid = "gray88", midpoint = 8247) +
  labs(title = "Number of Listings ~ Origin Location (without United States)", 
       y = "number of listings", fill = "") +
  pd.classic +
  coord_flip()

# plot with USA - sorted
ggplot(origin, aes(reorder(from, from.count), from.count, 
                   color = from.count)) +
  geom_point(size = 3) +
  scale_color_gradient2(low = "deepskyblue4", high = "firebrick3",
                       mid = "gray88", midpoint = 8247) +
  labs(title = "Number of Listings ~ Origin Location", 
       y = "number of listings", x = "from", color = "") +
  pd.classic +
  coord_flip()

# filter out USA
origin.world <- origin %>% filter(from != "USA")

# plot without USA - sorted
ggplot(origin.world, aes(reorder(from, from.count), from.count, 
                   color = from.count)) +
  geom_point(size = 3) +
  scale_color_gradient2(low = "deepskyblue4", high = "firebrick3",
                        mid = "gray88", midpoint = 8247) +
  labs(title = "Number of Listings ~ Origin Location (without United States)", 
       y = "number of listings", x = "from", color = "") +
  pd.classic +
  coord_flip()

# There's a clear split over/under 10,000 listings. 
# Filter under 10,000 and see how that distributes

origins10k <- origin %>% filter(from.count < 10000)

# set gradient midpoint to mean
summary(origins10k$from.count)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 1.0     3.0    79.5   871.2  1061.0  5173.0

# plot under 10k, sorted
ggplot(origins10k, aes(reorder(from, from.count), from.count, 
                         color = from.count)) +
  geom_point(size = 3) +
  scale_color_gradient2(low = "deepskyblue4", high = "firebrick3",
                        mid = "gray88", midpoint = 871.2) +
  labs(title = "Number of Listings ~ Origin Location (less than 10,000 listings)", 
       y = "number of listings", x = "from", color = "") +
  pd.classic +
  coord_flip()

# Another seeming stratification: above 1k, 2k-4k, 4k-10k
# still can't see how under 1k is distributed

origins1k <- origin %>% filter(from.count < 1000)
summary(origins1k$from.count)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    1.0     3.0     9.0   177.3   200.0   926.0 

ggplot(origins1k, aes(reorder(from, from.count), from.count, 
                       color = from.count)) +
  geom_point(size = 3) +
  scale_color_gradient2(low = "deepskyblue4", high = "firebrick3",
                        mid = "gray88", midpoint = 177.3) +
  labs(title = "Number of Listings ~ Origin Location (less than 1,000 listings)", 
       y = "number of listings", x = "from", color = "") +
  pd.classic +
  coord_flip()


# What kind of Cannabis products are out there? -------------------------------

# Sub-subcategories 
levels(cannabis$subsubcat)

ggplot(cannabis, aes(subsubcat, fill = ..count..)) +
  geom_bar()

cannabis.100 <- cannabis.u %>% filter(num.listings > 100)
# 16762 listings of 33 variables

cannabis.100 <- cannabis.100 %>%
  select(subsubcat, year, month, day, vendor, product, price, usd, rate, gold.oz, 
         fb, feedback, from, to, p.words, f.words, brent.oil, wti.oil,
         num.listings, freq.listings, num.fb.score, fb.relfreq)

cannabis.100$subsubcat <- factor(cannabis.100$subsubcat)
cannabis.100$vendor <- factor(cannabis.100$vendor)
cannabis.100$from <- factor(cannabis.100$from)

levels(cannabis.100$subsubcat)
levels(cannabis.100$from)
levels(cannabis.100$vendor)

cannabis.100 <- na.omit(cannabis.100)

# type by location
ggplot(cannabis.100, aes(from, fill = ..count..)) +
  geom_bar() +
  scale_fill_gradient2(low = "deepskyblue4", high = "firebrick3",
                       mid = "gray88", midpoint = 2000) +
  facet_wrap( ~ subsubcat, nrow = 3) +
  labs(title = "Cannabis Type ~ Location (n > 100)") +
  pd.classic +
  coord_flip()

# type by location, USA removed
cannabis.100.world <- cannabis.100 %>% filter(from != "USA")

ggplot(cannabis.100.world, aes(from, fill = ..count..)) +
  geom_bar() +
  scale_fill_gradient2(low = "deepskyblue4", high = "firebrick3",
                       mid = "gray88", midpoint = 1000) +
  facet_wrap( ~ subsubcat, nrow = 3) +
  labs(title = "Cannabis Type ~ Location (n > 100, USA removed)") +
  pd.classic +
  coord_flip()

summary(cannabis.100$usd)
# 14k is the max for real listings

cannabis.100 <- filter(cannabis.100, usd < 14000)
cannabis.users <- filter(cannabis.100, usd < 600)

# subset price under 600; plot by type
ggplot(cannabis.users, aes(usd)) +
  geom_histogram(binwidth = 10, fill = "white", color = "black") +
  facet_wrap( ~ subsubcat, nrow = 3) +
  labs(title = "Price ~ Type (n > 100)", x = "price in USD") +
  pd.classic

# boxplot prices (under 600)
ggplot(cannabis.users, aes(subsubcat, usd)) +
  geom_boxplot(outlier.size = 1.5, outlier.shape = 19, 
               outlier.alpha = 0.5, notch = T) +
  stat_summary(fun.y = "mean", geom = "point", shape = 23, 
               size = 4, fill = "gray88") +
  labs(title = "Price ~ Type (USD < 600)", x = "cannabis type",
       y = "price in USD") +
  pd.min

# boxplot prices (all)
ggplot(cannabis.100, aes(subsubcat, usd)) +
  geom_boxplot(outlier.size = 1.5, outlier.shape = 19, 
               outlier.alpha = 0.5, notch = T) +
  stat_summary(fun.y = "mean", geom = "point", shape = 23, 
               size = 4, fill = "gray88") +
  labs(title = "Price ~ Type (USD < 600)", x = "cannabis type",
       y = "price in USD") +
  pd.min

ggplot(cannabis.users, aes(subsubcat, usd)) +
  geom_dotplot(binaxis = "y", stackdir = "center", binwidth = 2) +
  labs(title = "Price ~ Type (USD < 600)", x = "cannabis type",
       y = "price in USD") +
  pd.min

