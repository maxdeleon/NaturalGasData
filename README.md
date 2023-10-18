# NaturalGasData

## Natural Gas Data Retrieval and Visualization

### Overview
This script was created to retrieve natural gas data from the U.S. Energy Information Administration (EIA) and visualize it using the `fpp3`, `fredr`, `eia`, and `readr` libraries in R. The code downloads data from EIA and generates visualizations to analyze various aspects of natural gas supply, demand, prices, and trading.

### Data Retrieval
The script utilizes the `readxl` package to read data from the EIA Excel files. It then filters the data to the specified date range and combines it into a comprehensive `tsibble` dataset for analysis and visualization.

### Data Visualization
The code includes functions for fast data summarization (`fastColSum`) and plotting (`fastplot`), allowing for efficient analysis and visualization of the natural gas data. The script generates line plots for supply, demand, trade, and price data, providing insights into the trends and patterns of the natural gas market.

### Output
The script saves the combined dataset as a CSV file ("NaturalGasDataset.csv") and also provides an interactive view of the dataset using the `view()` function.

### Contact Information
For any questions or concerns regarding the code or data, please reach out to the script author, Maximo Xavier de Leon.
