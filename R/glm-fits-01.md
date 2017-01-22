```{r}
glm(formula = fb ~ usd + cat + subcat + subsubcat, family = binomial, 
    data = w8train)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-2.0393  -1.0408  -0.6429   1.0909   2.3899  

Coefficients: (9 not defined because of singularities)
                                Estimate     Std. Error z value             Pr(>|z|)    
(Intercept)                -0.6931249418   0.1485221332  -4.667 0.000003059083067877 ***
usd                        -0.0000001233   0.0000001269  -0.972             0.331148    
catData                     0.9123448033   0.1993408166   4.577 0.000004721225993940 ***
catDrugs                   -1.1779808944   0.2439071210  -4.830 0.000001367877023106 ***
catForgeries               -2.0189998006   0.4006111978  -5.040 0.000000466021716533 ***
catInformation              0.9224217916   0.1591122480   5.797 0.000000006739017574 ***
catJewelry                 -1.8761950969   0.2298226185  -8.164 0.000000000000000325 *** 
catServices                -0.7019082067   0.1804588397  -3.890             0.000100 ***
catWeapons                 -1.1657549061   0.3440627412  -3.388             0.000704 ***
subcatAccounts              0.6467774634   0.1762956425   3.669             0.000244 ***
subcatBarbiturates          3.0497924205   0.6391186273   4.772 0.000001825212955518 ***
subcatBenzos                1.7337815904   0.2929060400   5.919 0.000000003234297347 ***
subcatCannabis              2.0780575367   0.2880914246   7.213 0.000000000000546570 ***
subcatClothing             -2.1034678501   0.2270055433  -9.266 < 0.0000000000000002 ***
subcatContainers           -1.3741503458   0.2993366674  -4.591 0.000004418644179975 ***
subcatDissociatives         1.4688802613   0.5970409880   2.460             0.013883 *  
subcatEcstasy               2.5466237870   0.5307398505   4.798 0.000001600559678265 *** 
subcatMelee                 1.4216767423   0.3505225318   4.056 0.000049946254726692 ***
subcatMoney                 1.1570075257   0.2208201646   5.240 0.000000160932168334 ***
subcatOpioids               3.2949764188   0.5296933491   6.221 0.000000000495460129 ***
subcatOther                 1.3488442082   0.2615019283   5.158 0.000000249513659088 ***
subcatParaphernalia        -1.1503849058   0.3491967226  -3.294             0.000986 ***
subcatPhysical documents    2.0354721541   0.4460299477   4.564 0.000005030002343362 ***
subcatPirated              -0.5493414044   0.1549854642  -3.544             0.000393 ***
subcatPrescription          1.0602073380   0.2902488627   3.653             0.000259 ***
subcatPsychedelics          2.0381639352   0.4993812234   4.081 0.000044769322745372 ***
subcatScans/Photos          2.4693360601   0.4429105003   5.575 0.000000024717690469 *** 
subcatSteroids              0.9650354274   0.2917416601   3.308             0.000940 ***
subcatStimulants            1.8321122738   0.3003826527   6.099 0.000000001065597881 ***
subcatWatches              -0.6846541450   0.1746973324  -3.919 0.000088884816086537 ***
subcatWeight loss           1.4607038224   0.3261531608   4.479 0.000007514034734002 ***
subsubcat5-MeO             -1.9697103766   0.4954673257  -3.975 0.000070243444362656 ***
subsubcatCocaine            0.3668940015   0.1191415498   3.079             0.002074 ** 
subsubcatCodeine           -3.2155382350   0.8845106272  -3.635             0.000278 ***
subsubcatConcentrates      -0.4021544352   0.0990341134  -4.061 0.000048911817783152 ***

subsubcatFentanyl          -1.8093402439   0.4984350692  -3.630             0.000283 ***
 
subsubcatSeeds             -1.3943866954   0.1511306038  -9.226 < 0.0000000000000002 ***
subsubcatSpeed                        NA             NA      NA                   NA    
subsubcatSpores                       NA             NA      NA                   NA    
subsubcatSynthetics        -1.9160546184   0.1442491517 -13.283 < 0.0000000000000002 ***
subsubcatWeed                         NA             NA      NA                   NA    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 40191  on 29628  degrees of freedom
Residual deviance: 37082  on 29549  degrees of freedom
AIC: 37242

Number of Fisher Scoring iterations: 10
```

So the model above did ok, barely better than baseline but both pretty lackluster. Time to tighten up the variables a bit more.
Maybe will start simpler this time - with just `cat` and `usd`.

Discretize USD into 10 categories by cluster, after removing placeholding outliers.
[    0,  351) [  351, 1075) [ 1075, 2121) [ 2121, 3586) 
        30512          4988          1904          1090 
[ 3586, 5728) [ 5728, 9382) [ 9382,16978) [16978,30630) 
          478           285           138            39 
[30630,56677) [56677,84634] 
           26            13 


There are some long outputs:

```{R}
Call:
glm(formula = fb ~ dollars + from + cat, family = "binomial", 
    data = w8train)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-2.3748  -1.0193  -0.5246   1.0724   2.6153  

Coefficients:
                        Estimate Std. Error z value             Pr(>|z|)    
(Intercept)             -1.00998    0.08754 -11.538 < 0.0000000000000002 ***
dollars[  351, 1075)    -0.63224    0.04125 -15.329 < 0.0000000000000002 ***
dollars[ 1075, 2121)    -1.04734    0.06915 -15.146 < 0.0000000000000002 ***
dollars[ 2121, 3586)    -1.22045    0.09852 -12.388 < 0.0000000000000002 ***
dollars[ 3586, 5728)    -1.69083    0.17519  -9.651 < 0.0000000000000002 ***
dollars[ 5728, 9382)    -2.10505    0.25099  -8.387 < 0.0000000000000002 ***
dollars[ 9382,16978)    -1.26340    0.26028  -4.854  0.00000120954562093 ***
dollars[16978,30630)    -2.20321    0.73968  -2.979             0.002896 ** 
dollars[30630,56677)    -0.79477    0.53233  -1.493             0.135440    
dollars[56677,84634]    -0.34862    0.64466  -0.541             0.588653

fromArgentina            1.15437    0.31174   3.703             0.000213 ***
fromAustralia            0.50523    0.07733   6.534  0.00000000006419607 ***
fromAustria             -0.50443    0.30923  -1.631             0.102837    
fromBelgium              0.77583    0.17207   4.509  0.00000651977735016 ***
fromBrazil             -12.54767  229.62848  -0.055             0.956423    
fromCanada               0.22401    0.08090   2.769             0.005622 ** 
fromChina               -1.26332    0.08353 -15.125 < 0.0000000000000002 ***
fromChristmas Island   -11.32723  187.49089  -0.060             0.951825    
fromColombia           -11.91543  324.74370  -0.037             0.970731    
fromCzech Republic       0.72305    0.31417   2.301             0.021363 *  
fromDenmark              0.54530    0.19667   2.773             0.005560 ** 
fromDominican Republic -12.54767  324.74370  -0.039             0.969178    
fromEU                  -0.53259    0.07683  -6.932  0.00000000000415571 ***
fromFrance               0.35586    0.18796   1.893             0.058321 .  
fromGermany              0.37941    0.07951   4.772  0.00000182413154573 ***
fromHong Kong            0.20909    0.13387   1.562             0.118325    
fromIndia               -0.80352    0.14070  -5.711  0.00000001125029388 ***
fromIreland              0.08479    0.34569   0.245             0.806239    
fromItaly               -0.07537    0.22679  -0.332             0.739627    
fromJapan              -12.77318  229.62848  -0.056             0.955640    
fromLatvia              -0.38707    0.91473  -0.423             0.672182    
fromNetherlands         -0.02606    0.07276  -0.358             0.720165    
fromNew Zealand         -0.72328    0.68440  -1.057             0.290603    
fromNo Info             -0.40472    0.05209  -7.769  0.00000000000000791 ***
fromNorway              -0.40466    0.31793  -1.273             0.203092    
fromPakistan           -12.05677   87.90480  -0.137             0.890907    
fromPhilippines         -2.67207    1.03224  -2.589             0.009636 ** 
fromPoland               0.70525    0.21428   3.291             0.000998 ***
fromScandinavia        -11.91543  229.62848  -0.052             0.958616    
fromSingapore           12.58446  229.62848   0.055             0.956295    
fromSouth Africa         0.98986    0.26060   3.798             0.000146 ***
fromSpain                0.35078    0.37461   0.936             0.349072    
fromSwaziland           12.54523  187.49087   0.067             0.946652    
fromSweden              -0.36670    0.15219  -2.409             0.015975 *  
fromSwitzerland          0.07284    0.25583   0.285             0.775872    
fromThailand             1.52619    0.39741   3.840             0.000123 ***
fromUK                   0.03824    0.07351   0.520             0.602953    
fromUSA                  0.27050    0.06000   4.508  0.00000654589054040 ***
fromUndeclared           2.77666    0.39995   6.943  0.00000000000385197 ***
fromWorldwide           -1.03640    0.09831 -10.542 < 0.0000000000000002 ***

catData                  1.21710    0.09623  12.648 < 0.0000000000000002 ***
catDrug paraphernalia   -0.28012    0.14082  -1.989             0.046679 *  
catDrugs                 0.99159    0.07989  12.412 < 0.0000000000000002 ***
catElectronics           0.18077    0.14491   1.247             0.212229    
catForgeries             0.79319    0.11398   6.959  0.00000000000342732 ***
catInformation           1.49063    0.08714  17.106 < 0.0000000000000002 ***
catJewelry              -0.76072    0.19266  -3.949  0.00007863416863982 ***
catListings              2.77881    1.09538   2.537             0.011186 *  
catOther                 0.51616    0.12646   4.081  0.00004475060049577 ***
catServices              1.03081    0.09877  10.437 < 0.0000000000000002 ***
catTobacco              -0.13637    0.12836  -1.062             0.288055    
catWeapons               0.70504    0.13579   5.192  0.00000020778900548 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 40163  on 29604  degrees of freedom
Residual deviance: 36136  on 29543  degrees of freedom
AIC: 36260
```

interesting things that are reported as significant:

- listings up to $16978. $ 16798-$90000 not so significant.
- but really, under $10,000 is stronger by many powers of 10 (11 powers of 10)

- Argentina, Australia, Belgium, China, EU, Germany, India, No INfo, Poland, South Africa, Thailand, USA, Undeclared, Worldwide
- Denmark is only 2!

- Data, Drugs, Forgeries, Information, Jewelry, Other, Services, Weapons.

Now if I'm not mistaken, these are significant predictors for either having great feedback or being totally ignored. 
So it can go both ways.

``` {R}
# naive baseline:
table(w8train$fb)
#    -1     5 
# 17346 12259
17346/nrow(w8train) # 0.5859145
12259/nrow(w8train) # 0.4140855

w8train <- as.data.frame(w8train)
w8test <- as.data.frame(w8test)

predict.test <- predict(mod2, type = "response", newdata = w8test)
table(w8test$fb, predict.test > 0.5)
#      FALSE TRUE
#  -1  3927 1855
#  5   1565 2521

acc <- (3927+2521)/nrow(w8test)   # 0.6534252
base <- (3927+1855)/nrow(w8test)  # 0.5859343
sense <- 1855/(1855+1565)         # 0.5423977
spec <- 3927/(3927+1855)          # 0.6791768
error <- (1565+1855)/nrow(w8test) # 0.3465748
fn <- 1565/(2521+1565)            # 0.3830152
fp <- 1855/(3927+1855)            # 0.3208232
```

So 2/3: 1/3 seems to be prevalent ratio...not the most condfident here. over 75% would be nice.
But also; I'm using all categorical predictors so this should be an ANOVA instead.












