library(rvest)
library(dplyr)
library(readr)
library(tidyr)
library(stringr)
library(lubridate)
library(here)
source("R/functions.R")

filename <- paste0("option_contracts_", today(), ".csv")
filepath <- here("output", filename)

if (!file.exists(filepath)) {
  if (!interactive())
    q()
} else {
  option_contracts <- read_csv(filepath)
}

cboe_options <- scrape_options_data(
  url = "https://www.cboe.com/us/options/market_statistics/symbol_data/?mkt=cone"
)

close_price <- option_contracts %>%
  left_join(cboe_options %>%
              rename_all(tolower) %>%
              select(option, close_price = last.price),
            by = "option") %>% 
  mutate_at(vars("initial_price", "close_price"), as.numeric) %>% 
  mutate(gain_loss = round(close_price - initial_price, 2))

write_csv(close_price, filepath)
