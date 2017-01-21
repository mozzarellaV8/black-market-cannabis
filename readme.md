# Black Market Cannabis Analysis

Logistic Regression Classification model to predict cannabis quality on darknet markets.


## Motivations

In times of political uncertainty, what can be learned from something that is inherently uncertain? 

As legalized/de-criminalized use of cannabis grows, darknet markets might serve as a proto-model of how marijuana e-commerce might be conducted. Conversely, as policies have begun to change under a new presidential administration, darknet markets might grow as a primary means for clients to acquire cannabis. 

Is it possible to make reasonable estimates on the quality of cannabis offered on darknet markets? 
How does darknet cannabis compare to other markets in terms of price? What other factors might influence quality? 

## On Darknet Markets

_What follows are broad, broad notes on how DNMs operate - a very _general_ discussion._

Darknet markets face issues that largely have been resolved in clearnet e-commerce - stability &  trust in products and payment processes. The trade-off is anonymity, which in turn provides freedom to sell products outside the law. 

Because of these issues, client feedback plays an important role in vendor reputability. A vendor without a history of good client feeback would generally appear as a risk to any potential client. With anonymity also comes the potential for scams - be it a vendor disappearing with payment without delivering, or vice-versa. To address this, different payment options emerged:

- FE, or finalize early - a client agrees to pay in advance for any product ordered. This method poses significant risk for the client, and generally can only be enforced by vendors with _very_ strong reputations - long transaction histories with total positive feedback.

- Escrow - where a third party arbiter (generally the market themselves) holds client payment in escrow until the product is delivered. Generally, this has been seen as the most 'trustworthy' method of doing business, where risk is spread to both client and vendor.


## Variables Provided

- date
- URL
- vendor
- product listing - resembling a Craigslist headline
- price in Bitcoin
- category, subcategory, and sub-subcategory of product
- origin location - where a vendor is shipping from
- shipping destinations - where a vendor is willing to ship to
- client feedback
- (vendor bio)
- (vendor verification) - binary - a vendor will either be registered, or will have the added bonus of being vouched for on another darknet market.


## Variables Derived

_...and looked up/added_

- price in USD
- daily BTC-USD exchange rate
- feedback score - ordinal values assigned, as feedback is left on a 0-5 scale. 

*variables derived: counts*

- number of words per product listing
- number of words per feedback field

*variables added: price indices*

The reason behind comparing cannabis prices to the High Times index is to see if price might be a factor in darknet transactions. Gold and oil prices were added to test the idea of cannabis as a commodity. 

- THMQ - High Times monthly survey of marijuana prices per ounce: overall index, Kind, Mids, Schwag
- corresponding price for ounce of gold
- corresponding price for barrel of WTI crude oil 
- price for barrel of Brent crude oil

- nuclear energy stock price index - via 3 US companies. 


*text features*

These are features to be derived from 3 possible textual fields: product listing, product description, client feedback, and vendor bio. The goal is to create a quantitative measure from textual features that might provide reasonable metrics for cannabis quality. 

- word count 
- word frequency
- sentiment scores

