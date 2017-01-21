# Darknet Cannabis Quality

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)

agora.all <- fread("data/agora-04.csv", stringsAsFactors = T)
str(agora.all)
nrow(agora.all)
# 2322961

levels(agora.all$cat)

# exploratory heatmap ---------------------------------------------------------

# remove categories without children
agora.all <- subset(agora.all, agora.all$cat != "Electronics" & agora.all$cat != "Jewelry"
                  & agora.all$cat != "Listings" & agora.all$cat != "Other"
                  & agora.all$cat != "Chemicals")

agora.all$cat <- factor(agora.all$cat)

catmap01 <- ggplot(agora.all, aes(from, subcat, fill = cat)) +
  geom_tile(colour = "white", size = 1) + 
  theme_minimal(base_size = 12, base_family = "GillSans") +
  theme(plot.title = element_text(size = 10, margin = margin(0, 0, 20, 0))) + 
  theme(axis.text.x = element_text(size = 11.5, angle = 45, hjust = 1)) +
  theme(axis.text.y = element_text(size = 12.5, lineheight = 1)) +
  theme(plot.margin = unit(c(0, 0.25, 0, 0.25), "cm")) +
  labs(title = "Agora Marketplace: Category ~ Subcategory + Location (n = 2237562)",
       y = "", x = "", fill = "category")

catmap01 + scale_fill_manual(values = c("red3", "gold1", "deepskyblue4", "lightblue3", 
                                   "red1", "bisque1", "bisque3", "bisque4", 
                                   "darkorange3", "firebrick4"))

# cannabis subset -------------------------------------------------------------

levels(agora.all$subcat)

cannabis <- subset(agora.all, agora.all$subcat == "Cannabis")
cannabis <- as.data.frame(cannabis)
summary(cannabis)

rm(agora.all)

cannabis$p.chars <- NULL
cannabis$f.chars <- NULL

summary(cannabis$fb)
nrow(cannabis)
# 404080

# write.csv(cannabis, file = "data/cannabis-V1.csv", row.names = F)

# feedback as quality: logistic regression models -----------------------------

library(broom)

model02 <- glm(fb ~ Kind + Mids + brent.oil + wti.oil + p.words, 
               family = "binomial", data = cannabis)
summary(model02)

m2 <- tidy(model02)
m2$log.odds <- exp(m2$estimate)
m2

summary(cannabis$p.words)
ggplot(cannabis, aes(p.words)) + geom_bar()
cannabis[37055, ]


predData <- with(cannabis,
                 expand.grid(fb = c(5, -1),
                             p.words = mean(p.words),
                             brent.oil = mean(brent.oil),
                             wti.oil = mean(wti.oil),
                             Kind = mean(Kind),
                             Mids  = mean(Mids)))

cbind(predData, predict(model02, type = "response", 
                        se.fit = TRUE, interval = "confidence",
                        newdata = predData))


# calculate new feedback scores -----------------------------------------------

summary(cannabis$feedback)
cannabis$fives <- grepl("5/5", cannabis$feedback)

fivestars <- subset(cannabis, cannabis$fives == T)
summary(fivestars$feedback)


