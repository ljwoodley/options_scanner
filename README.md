# Options Scanner

### About

This project was created as a way for me to discover high volume options contracts within the first hour of market open. It scrapes data from the [Chicago Board Options Exchange](https://www.cboe.com/us/options/market_statistics/symbol_data/?mkt=cone) to find potential profitable options based on some basic filters. This is a rudimentary scanner that only identifies weekly options as I'm mainly interested in the price movement of contracts within the week that it was found.

The criteria for finding contracts is simple. First, the volume for a given ticker must be greater than 1000. Of those high volume tickers the percentage of calls must be greater than 74% or less than 25%.

Volume is important as high options volume combined with an increasing price in the underlying stock can be an indication that traders think the stock price will go up. Alternatively, high volume while the underlying stock is decreasing could mean that traders think the stock will decrease in price. Additionally, if the volume is low on a contract it may be difficult to buy or sell the contract at a fair price due to low liquidity.

### Schedule & Scripts

Two scripts are run via GitHub Actions:

-   `R/get_contracts.R` - gets the tickers that meet the selected criteria within the first hour of market open. Runs Monday-Friday at 1430 UTC

-   `R/get_close_price.R` - gets the closing price for the contracts identified in `R/get_contracts.R`. Runs Monday-Friday at 2230 UTC

### Output

All output is stored in the `output` folder with the name `option_contracts_<date>_.csv`. The fields in the csv file are:

-   `option` - identifies the contract to purchase

-   `initial_price` - gives the approximate price of the contract at the time `R/get_contracts.R` was run

-   `close_price` - gives the approximate price of the contract after market close

-   `gain_loss` - indicates the gain or loss on the contract
