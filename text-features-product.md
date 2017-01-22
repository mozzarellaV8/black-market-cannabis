# Text Features

## Product Listings

To derive text variables, let's take a look at the Agora dataset, subsetted to only listings for Cannabis.

```{r}
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
```

## Word Frequencies by Location

```{r}
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
```

What are the relative frequencies of words from each location? 

- USA: 44%
- Germany: 9.3% 
- Canada: 8.4%
- UK: 8.0%
- Netherlands: 5.6% 
- Aus: 4.4%
- China: 4.0%
- No Info: 4.1%

Interesting to see what the most frequently occuring words are by country: 

```{r}
p.usa %>%
  count(word, sort = T)
#      word     n
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
```

A comparison of the United States and Germany shows that the US has more parts of speech that describe the product, while Germany has more that describe the transaction process. 

```{r}
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
```

Meanwhile China has words describing quantities:

```{r}
p.china %>%
  count(word, sort = T)

     word     n
    <chr> <int>
1      5f  6291
2      ab  5785
3    2201  3956
4      22  3494
5      pb  3494
6  pinaca  3258
7    100g  3173
8    500g  3155
9     144  2807
10     ur  2554
```

Netherlands appears to be a mix of cannabis descriptors and 'free shipping':

```{r}

p.tokens %>%
  filter(origin == "Netherlands") %>%
  count(word, sort = T)

       word     n
      <chr> <int>
1      free  4891
2  shipping  4840
3      haze  4549
4      gram  3777
5      hash  3238
6   quality  3117
7   amnesia  2828
8    indoor  2590
9        gr  2528
10    white  2303
# ... with 595 more rows
```

Canada also seems interested most in cannabis descriptors, and slightly less so with quantitites:

```{R}

p.tokens %>%
  filter(origin == "Canada") %>%
  count(word, sort = T)

      word     n
     <chr> <int>
1     kush 11893
2      aaa  6642
3    grams  5941
4        1  4995
5      bho  4189
6    grade  3481
7       oz  3361
8   purple  2972
9  shatter  2951
10  purged  2693
```



## Correlations between Word Frequencies and Location

Suspiciously, when subsetted by country, there is always a perfect correlation.

```{r}
cor.test(data = frequency.8[frequency.8$origin == "USA", ], ~ pct + n)
# 	Pearson's product-moment correlation

data:  pct and n
t = Inf, df = 3609, p-value < 0.00000000000000022
alternative hypothesis: true correlation is not equal to 0
95 percent confidence interval:
  1 1
sample estimates:
  cor 
1 
```

While the overall correlation between relative frequency and count sits at just above 64%:

```{r}
Pearson's product-moment correlation

data:  pct and n
t = 83.82, df = 9926, p-value < 0.00000000000000022
alternative hypothesis: true correlation is not equal to 0
95 percent confidence interval:
 0.6321185 0.6551585
sample estimates:
      cor 
0.6437844 
```

