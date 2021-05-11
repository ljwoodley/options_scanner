# function: scrape_options_data
# input: https://www.cboe.com/us/options/market_statistics/symbol_data/?mkt=cone
# output: a dataframe containing the parsed HTML table
scrape_options_data <- function(url) {
  cboe_options <- read_html(url) %>%
    html_nodes("table") %>%
    html_table(fill = TRUE) %>%
    data.frame()
  
  return(cboe_options)
}

# function: get_clean_cboe_options
# input: the dataset returned from scrape_options_data()
# output: a dataframe containing all options contracts expiring on the nearest Friday
get_clean_cboe_options <- function(cboe_options) {
  clean_cboe_options <- cboe_options %>%
    rename_all(tolower) %>%
    mutate(
      ticker = word(option, 1),
      exp_month = word(option, 2),
      exp_day = parse_number(word(option, 3)),
      call_put = tolower(word(option, 5)),
      volume = parse_number(volume)
    ) %>%
    filter(exp_month == month(upcoming_friday, label = TRUE) &
             exp_day == day(upcoming_friday)) %>%
    select(option,
           ticker, 
           exp_month, 
           exp_day, 
           volume, 
           last_price = last.price, 
           call_put)
  
  return(clean_cboe_options)
}


# function: get_top_tickers_by_volume
# input: the dataset returned from get_clean_cboe_options()
# output: a dataframe containing the top 10 tickers with the highest volume
get_top_tickers_by_volume <- function(clean_cboe_options) {
  top_tickers_by_volume <- clean_cboe_options %>%
    group_by(ticker, call_put) %>%
    summarise(volume = sum(volume)) %>%
    ungroup() %>%
    pivot_wider(
      names_from = call_put,
      values_from = volume,
      values_fill = 0
    ) %>%
    mutate(volume = call + put,
           perc_calls = round((call / volume), 2) * 100) %>%
    arrange(desc(volume)) %>%
    filter(volume > 1000 & perc_calls < 100) %>%
    head(10)
  
  return(top_tickers_by_volume)
}

# function: get_option_contracts
# inputs: the datasets returned from get_get_clean_cboe_options() &
#   get_top_tickers_by_volume()
# output: a dataframe containing the contracts with the most potential for profit
#   based on the given criteria
get_option_contracts <- function(clean_cboe_options, top_tickers_by_volume) {
  call_contracts <- clean_cboe_options %>%
    filter(call_put == "call") %>%
    inner_join(top_tickers_by_volume %>%
                 filter(perc_calls > 74) %>%
                 select(ticker),
               by = "ticker") %>%
    group_by(ticker) %>%
    top_n(1, wt = volume) %>%
    ungroup() %>%
    select(option, initial_price = last_price)
  
  put_contracts <- clean_cboe_options %>%
    filter(call_put == "put") %>%
    inner_join(top_tickers_by_volume %>%
                 filter(perc_calls < 25) %>%
                 select(ticker),
               by = "ticker") %>%
    group_by(ticker) %>%
    top_n(1, wt = volume) %>%
    ungroup() %>%
    select(option, initial_price = last_price)
  
  option_contracts <- call_contracts %>%
    bind_rows(put_contracts)
  
  return(option_contracts)
}