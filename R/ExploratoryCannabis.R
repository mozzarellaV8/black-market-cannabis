# Exploratory Cannabis

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)

cannabis <- fread("data/cannabis-V1.csv", stringsAsFactors = T)
cannabis <- as.data.frame(cannabis)

# feedback distribution
summary(cannabis$fb)

nrow(cannabis)

options(scipen = 999)

# relative feedback score frequency
cannabis %>%
  group_by(fb) %>%
  summarise(n = n()) %>%
  mutate(freq = n/sum(n))

# Logistic Regression Models --------------------------------------------------

library(broom)

# ~ price + number of words in feedback
model01 <- glm(fb ~ price + f.words, family = binomial, data = cannabis)
tidy(model01)

# ~ price, price of gold, High Times price indices, 
# price of Oil, number of words in product listing
model02 <- glm(fb ~ usd + gold.oz + Index + Kind + Mids + Schwag + 
                 brent.oil + wti.oil + p.words, family = "binomial", data = cannabis)
tidy(model02)
summary(model02)

# store regression output
m02_output <- tidy(model02)
summary(m02_output)

# exponentiate coefficients
exp(m02_output$estimate)

m02.out <- coef(summary(model02))
m02.out[, "Estimate"] <- exp(coef(model02))
m02.out














