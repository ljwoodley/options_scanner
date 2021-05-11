library(rvest)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(lubridate)
library(here)
source("R/functions.R")

upcoming_friday <- ceiling_date(today(),
                                unit = "week",
                                week_start = getOption("lubridate.week.start", 5))

cboe_options <- scrape_options_data(
  url = "https://www.cboe.com/us/options/market_statistics/symbol_data/?mkt=cone" 
)

clean_cboe_options <- get_clean_cboe_options(cboe_options)

top_tickers_by_volume <- get_top_tickers_by_volume(clean_cboe_options)

if(nrow(top_tickers_by_volume) == 0) {
  if(!interactive()) q()
}

option_contracts <- get_option_contracts(clean_cboe_options, top_tickers_by_volume)

filename <- paste0("option_contracts_", today(), ".csv")
filepath <- here("output", filename)
write_csv(option_contracts, filepath)


