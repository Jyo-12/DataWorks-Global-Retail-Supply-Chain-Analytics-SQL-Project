# DataWorks-Global-Retail-Supply-Chain-Analytics-SQL-Project
This repository contains a comprehensive SQL-based end-to-end analysis of a global retail dataset. The project focuses on data cleaning, ETL (Extract, Transform, Load) processes, and complex analytical queries to drive business intelligence across sales, customers, products, and store performance.

# Project Structure
The analysis is divided into three core phases:

Schema Exploration & Validation: Understanding the relational structure of customers, products, sales, stores, and exchange_rates.

Data Cleaning & Preprocessing: Handling null values, standardizing date formats, and performing duplicate checks.

Business Intelligence & Analytics: Executing complex joins and window functions to extract 20+ actionable business insights.

# Key Analytical Features
1. Sales & Revenue Intelligence
KPI Tracking: Calculation of Total Transactions, Total Sales (USD), and Average Order Value (AOV).

Profitability Analysis: Calculated unit profit margins to identify high-performing products vs. those candidates for discontinuation.

Currency Impact: Integrated exchange_rates to analyze how currency fluctuations impact global pricing and revenue.

2. Customer & Behavioral Insights
Gender-Based Trends: Analysis of purchasing power and frequency across demographics to support personalized marketing.

Customer Loyalty: Segmented "Power Users" who have made multiple purchases within specific product categories.

Regional Performance: Identified top-selling products by continent and revenue contribution per country.

3. Operational & Supply Chain Metrics
Delivery Performance: Implemented a trend analysis using LAG() window functions to track whether delivery times are improving or worsening month-over-month.

Inventory Categorization: Classified products into Fast Moving, Slow Moving, and Average based on sales velocity.

Store Efficiency: Calculated "Store Conversion Efficiency" by measuring units sold per square meter of retail space.

4. Channel Comparison (Online vs. In-Store)
Comprehensive analysis of AOV differences between digital and physical storefronts.

Used PERCENT_RANK() to identify the top 10% of high-value orders per channel.


## Technical Highlights (SQL)
Window Functions: Utilized LAG(), PERCENT_RANK(), and OVER(PARTITION BY...) for advanced trend analysis.

CTEs (Common Table Expressions): Leveraged WITH clauses to organize multi-step calculations for readability and performance.

Data Transformation: Standardized inconsistent date formats and automated the filling of missing delivery dates using DATE_ADD intervals.

## Sample Insights Generated
Top 10 Customers: Ranked by total lifetime spend (USD).

Seasonal Trends: Monthly revenue and order volume tracking to identify peak sales periods.

Store Metrics: Analysis of "Late Deliveries" (orders exceeding a 5-day delivery window) to flag logistical bottlenecks.

Comprehensive analysis of AOV differences between digital and physical storefronts.

Used PERCENT_RANK() to identify the top 10% of high-value orders per channel.
