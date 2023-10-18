#### Created by Maximo Xavier de Leon
# This file gets natural gas data from the EIA
library(fpp3)
library(fredr)
library(eia)
library(readr)



tmp <- tempfile(fileext = ".xls") 
# Download data from EIA and store in tmp
#"https://www.eia.gov/dnav/ng/xls/NG_SUM_LSUM_DCU_NUS_M.xls"
download.file(url = "https://www.eia.gov/dnav/ng/xls/NG_SUM_LSUM_DCU_NUS_M.xls", 
              destfile = tmp, mode = "wb")

# specify the year month range we care about
index_range = "2010 Jan" ~ "2022 Dec"
# iterate through the sheets (2 -> 6)
for (i in 2:6) {
  # if this is the first iteration then define the ngata tsibble using the first sheet
  if (i == 2){
    ngdata <- readxl::read_excel(tmp, sheet = i , skip = 2) %>%
      mutate(Date = yearmonth(Date)) %>% 
      as_tsibble(index = Date) %>% 
      filter_index(index_range)
  }
  # if this is anything afterwards then we want to read in the new sheet and left join its repsective tsibble to the ngdata tsibble
  else{
    temp_tsibble <- readxl::read_excel(tmp, sheet = i , skip = 2) %>%
      mutate(Date = yearmonth(Date)) %>% 
      as_tsibble(index = Date) %>% 
      filter_index(index_range)
    ngdata <- ngdata %>% left_join(temp_tsibble, by = "Date") 
  }
}

##### Pull monthly Henry Hub and NYMEX price data from the EIA

download.file(url = "https://www.eia.gov/dnav/ng/xls/NG_PRI_FUT_S1_M.xls", 
              destfile = tmp, mode = "wb")
for (i in 2:3) {
  temp_tsibble <- readxl::read_excel(tmp, sheet = i , skip = 2) %>%
    mutate(Date = yearmonth(Date)) %>% 
    as_tsibble(index = Date) %>% 
    filter_index(index_range)
  ngdata <- ngdata %>% left_join(temp_tsibble, by = "Date")
}

ngdata <- ngdata %>% 
  select(!`U.S. Natural Gas Gross Withdrawals from Gas Wells (MMcf)`:`U.S. Natural Gas Vented and Flared (MMcf)`)  %>% 
  select(!c("U.S. Natural Gas Wellhead Price (Dollars per Thousand Cubic Feet)",
           "Price of U.S. Natural Gas LNG Imports (Dollars per Thousand Cubic Feet)"))

column.data <- ngdata %>% colnames() %>% as_tibble()

# select the price data
ngdata.price <- ngdata %>% 
  select(`Henry Hub Natural Gas Spot Price (Dollars per Million Btu)`:`Natural Gas Futures Contract 4 (Dollars per Million Btu)` |
           `Price of U.S. Natural Gas Imports (Dollars per Thousand Cubic Feet)`:`United States Natural Gas Industrial Price (Dollars per Thousand Cubic Feet)`) %>% 
  as_tsibble(index = Date)

# supply data
ngdata.supply <- ngdata %>% select(`U.S. Natural Gas Gross Withdrawals (MMcf)`:`U.S. Dry Natural Gas Production (MMcf)`) %>% 
  as_tsibble(index = Date)

# demand data
ngdata.demand <- ngdata %>% select(`U.S. Natural Gas Total Consumption (MMcf)`:`U.S. Natural Gas Deliveries to Electric Power Consumers (MMcf)`) %>% 
  as_tsibble(index = Date)

# demand data
ngdata.trade <- ngdata %>% select(`U.S. Natural Gas Imports (MMcf)`:`Liquefied U.S. Natural Gas Exports (MMcf)`) %>% 
  as_tsibble(index = Date)



fastColSum <- function(tsbl,cols_to_sum=c()){
  if(length(cols_to_sum) == 0) {
    tsbl %>%
      summarise(across(everything(), sum))
  }
  else{
    tsbl %>%
      select(all_of(cols_to_sum)) %>%
      summarise(across(everything(), sum))
  }
}

## one line solution to generating plot
fastplot <- function(tsbl) {
  tsbl.long <- pivot_longer(tsbl, cols = -Date, names_to = "variable", values_to = "value")
  # Create a facetted plot for each column
  ggplot(tsbl.long, aes(x = Date, y = value)) +
    geom_line() + 
    facet_wrap(~ variable, scales = "free_y", nrow = nrow(tsbl.long)) +
    theme_bw()
}


ngdata.supply %>% fastplot()
ngdata.demand %>% fastplot()
ngdata.trade %>% fastplot()
ngdata.price %>% fastplot()


dataset <- bind_cols(ngdata.price,ngdata.supply,ngdata.demand,ngdata.trade)


dataset |> view()


write_csv(dataset, "NaturalGasDataset.csv")

