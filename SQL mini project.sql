show tables ;
desc customers ;
desc customers ;
desc exchange_rates;
desc products;
desc sales;
desc stores;

-- DESCRIPTIVE STATISTICS:
-- 1.
-- Total sales, average order quantity, total number of transactions
SELECT 
    COUNT(*) AS Total_Transactions,
    SUM(Quantity * p.`Unit Price USD`) AS Total_Sales_USD,
    AVG(Quantity * p.`Unit Price USD`) AS Avg_Order_Value_USD
FROM Sales s
JOIN Products p ON s.ProductKey = p.ProductKey;


-- 2.Orders per customer:
SELECT CustomerKey, COUNT(*) AS num_orders FROM sales GROUP BY CustomerKey;

-- DATA CLEANING FROM ALL TABLES
-- 1. NULL check:
SELECT count(*) from stores WHERE 'Open Date' IS NULL;

-- 2. Date format
SELECT 
  Name,
  DATE_FORMAT(Birthday, '%d/%m/%Y') AS Formatted_Birthday
FROM customers
ORDER BY Birthday; 

-- 3.Duplicate check (same OrderNumber + LineItem)
select'OrderNumber', 'LineItem', COUNT(*) FROM sales GROUP BY OrderNumber, LineItem HAVING COUNT(*) > 1;


-- 4. Fill up Missing values 
-- Step 1:
SELECT 
  `Order Number`, 
  `Line Item`, 
  `Order Date`, 
  `Delivery Date`
FROM sales
WHERE `Delivery Date` IS NULL;


-- Step 2: Update NULLs with calculated gap
SET SQL_SAFE_UPDATES = 0;
UPDATE sales
SET `Delivery Date` = DATE_ADD(`Order Date`, INTERVAL 3 DAY)
WHERE `Delivery Date` IS NULL
  AND `Order Date` IS NOT NULL;

-- Step3 :
SELECT 
  `Order Number`,
  `Line Item`,
  DATE_FORMAT(`Order Date`, '%d/%m/%Y') AS Formatted_Order_Date,
  DATE_FORMAT(`Delivery Date`, '%d/%m/%Y') AS Formatted_Delivery_Date
FROM sales
ORDER BY `Order Number`, `Line Item`;

-- formatting dates in table stores
SELECT DATE_FORMAT(`Open Date`, '%d/%m/%Y') AS formatted_open_date
FROM stores;


-- DATA ANALYSIS:
-- 1.Profit Margin Analysis- Understand product-level profitability and to check which product to to promote or discontinue
-- Profit per unit, total profit per product
SELECT 
  `Product Name`,
  `Unit Price USD`,
  `Unit Cost USD`,
  (`Unit Price USD` - `Unit Cost USD`) AS Unit_Profit,
  (`Unit Price USD` - `Unit Cost USD`) * SUM(s.Quantity) AS Total_Profit
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY s.ProductKey;

-- 2. International Sales Trends using exchange_rates
-- Objective: Analyze how currency fluctuations impact sales
-- Use Case: Suggest pricing strategies for global markets
-- Convert local sales quantity to USD equivalent
SELECT 
  s.`Order Number`,
  s.`Currency Code`,
  e.Exchange,
  s.Quantity * p.`Unit Price USD` / e.Exchange AS Approx_Converted_USD
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN exchange_rates e 
  ON s.`Order Date` = e.Date 
  AND s.`Currency Code` = e.Currency;
  
 -- 3.Monthly Sales Trend:
WITH MonthlySales AS (
    SELECT 
        DATE_FORMAT(s.`Order Date`, '%Y-%m') AS Month,
        SUM(s.Quantity * p.`Unit Price USD`) AS Sales_USD
    FROM Sales s
    JOIN Products p ON s.ProductKey = p.ProductKey
    GROUP BY DATE_FORMAT(s.`Order Date`, '%Y-%m')
)
SELECT * FROM MonthlySales ORDER BY Month;
  
  -- 4. Gender-Based Purchasing Patterns:
  -- Objective: Spot differences in buying behavior between genders
  -- Use Case: Personalized marketing.
  -- Average quantity purchased by gender
SELECT 
  c.Gender,
  COUNT(DISTINCT s.`Order Number`) AS Total_Orders,
  SUM(s.Quantity) AS Total_Quantity,
  AVG(s.Quantity) AS Avg_Items_Per_Order
FROM sales s
JOIN customers c ON s.CustomerKey = c.CustomerKey
GROUP BY c.Gender;

-- 5. Currency Conversion Example (Using Exchange_Rates)
SELECT 
    s.`Order Number`,
    SUM(s.Quantity * p.`Unit Price USD` / er.Exchange) AS Sales_Local_Currency
FROM Sales s
JOIN Products p ON s.ProductKey = p.ProductKey
JOIN Exchange_Rates er 
    ON er.Currency = s.`Currency Code` 
   AND er.Date = s.`Order Date`
GROUP BY s.`Order Number`;


-- 6. Category-Wise Customer Loyalty
-- Goal: Count how many customers bought more than once in each category.
SELECT 
  p.`Category`,
  s.CustomerKey,
  COUNT(DISTINCT s.`Order Number`) AS Orders_Count
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN customers c ON s.CustomerKey = c.CustomerKey
GROUP BY p.`Category`, s.CustomerKey
HAVING Orders_Count > 1
ORDER BY Orders_Count DESC;

-- 7. Top-Selling Products by Continent
-- Goal: What’s the top product in each continent?
SELECT 
  cu.Continent,
  p.`Product Name`,
  SUM(s.Quantity) AS Total_Units_Sold
FROM sales s
JOIN customers cu ON s.CustomerKey = cu.CustomerKey
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY cu.Continent, p.`Product Name`
ORDER BY cu.Continent, Total_Units_Sold DESC;

-- 8 .Store Conversion Efficiency
-- Goal: Units sold per square meter
SELECT 
  st.StoreKey,
  st.State,
  ROUND(SUM(s.Quantity) / st.`Square Meters`, 2) AS Units_Per_Square_Meter
FROM sales s
JOIN stores st ON s.StoreKey = st.StoreKey
GROUP BY st.StoreKey, st.State
ORDER BY Units_Per_Square_Meter DESC;

-- 9. Currency Impact on Product Choice
-- Goal: What’s the average unit price of items bought in each currency?
SELECT 
  s.`Currency Code`,
  ROUND(AVG(p.`Unit Price USD`), 2) AS Avg_Unit_Price
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY s.`Currency Code`
ORDER BY Avg_Unit_Price DESC;

-- 10. What types of products does the company sell, and where are customers located?
SELECT 
  p.Category,
  p.Subcategory,
  cu.Country,
  cu.State,
  COUNT(*) AS Total_Orders
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN customers cu ON s.CustomerKey = cu.CustomerKey
GROUP BY p.Category, p.Subcategory, cu.Country, cu.State
ORDER BY Total_Orders DESC;

-- 11. Are there any seasonal patterns or trends for order volume or revenue?
SELECT 
  YEAR(`Order Date`) AS Year,
  MONTH(`Order Date`) AS Month,
  COUNT(DISTINCT `Order Number`) AS Total_Orders,
  SUM(p.`Unit Price USD` * s.Quantity) AS Total_Revenue
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY Year, Month
ORDER BY Year, Month;

-- 12. How long is the average delivery time in days? Has that changed over time?(using advanced SQL commands)
-- Step 1: Calculate Monthly Delivery Time
WITH monthly_delivery AS (
    SELECT 
        DATE_FORMAT(`Order Date`, '%Y-%m') AS Order_Month,
        ROUND(AVG(DATEDIFF(`Delivery Date`, `Order Date`)), 2) AS Avg_Delivery_Days
    FROM sales
    WHERE `Delivery Date` IS NOT NULL
    GROUP BY DATE_FORMAT(`Order Date`, '%Y-%m')
),

-- Step 2: Add Trend Comparison Using LAG
delivery_trend AS (
    SELECT 
        Order_Month,
        Avg_Delivery_Days,
        LAG(Avg_Delivery_Days) OVER (ORDER BY Order_Month) AS Prev_Month_Days,
        ROUND(
            Avg_Delivery_Days - LAG(Avg_Delivery_Days) OVER (ORDER BY Order_Month), 2
        ) AS Change_From_Previous
    FROM monthly_delivery
)

-- Step 3: Add Status Flags (Improved, Worsened, No Change)
SELECT 
    Order_Month,
    Avg_Delivery_Days,
    Prev_Month_Days,
    Change_From_Previous,
    CASE 
        WHEN Change_From_Previous < 0 THEN 'Improved '
        WHEN Change_From_Previous > 0 THEN 'Worsened '
        ELSE 'No Change '
    END AS Trend_Status
FROM delivery_trend
ORDER BY Order_Month;

-- 13. “Is there a difference in AOV for online vs. in-store sales?”

WITH order_values AS (
    SELECT 
        s.`Order Number`,
        CASE 
            WHEN s.StoreKey IS NULL OR s.StoreKey = 0 THEN 'Online'
            ELSE 'In-Store'
        END AS OrderChannel,
        SUM(p.`Unit Price USD` * s.Quantity) AS Order_Value
    FROM sales s
    JOIN products p ON s.ProductKey = p.ProductKey
    GROUP BY s.`Order Number`, OrderChannel
),

channel_stats AS (
    SELECT 
        OrderChannel,
        ROUND(AVG(Order_Value), 2) AS Avg_Order_Value,
        ROUND(MIN(Order_Value), 2) AS Min_Value,
        ROUND(MAX(Order_Value), 2) AS Max_Value,
        COUNT(*) AS Total_Orders
    FROM order_values
    GROUP BY OrderChannel
),

percentile_orders AS (
    SELECT 
        OrderChannel,
        `Order Number`,
        Order_Value,
        ROUND(PERCENT_RANK() OVER (PARTITION BY OrderChannel ORDER BY Order_Value), 2) AS Order_Value_Rank
    FROM order_values
)

SELECT 
    c.OrderChannel,
    c.Avg_Order_Value,
    c.Min_Value,
    c.Max_Value,
    c.Total_Orders,
    COUNT(CASE WHEN p.Order_Value_Rank >= 0.90 THEN 1 END) AS Top_10pct_HighValue_Orders,
    ROUND(100.0 * COUNT(CASE WHEN p.Order_Value_Rank >= 0.90 THEN 1 END) / c.Total_Orders, 2) AS Top_10pct_Percentage
FROM channel_stats c
JOIN percentile_orders p ON c.OrderChannel = p.OrderChannel
GROUP BY c.OrderChannel, c.Avg_Order_Value, c.Min_Value, c.Max_Value, c.Total_Orders ;

-- 14. Top 10 Products by Total Quantity Sold:
SELECT 
  p.`Product Name`,
  SUM(s.Quantity) AS Total_Quantity_Sold
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY p.`Product Name`
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;

-- 15. top 10 products by revenue per channel (Online vs In-Store simulation included):
WITH sales_with_channel AS (
    SELECT 
        s.*,
        CASE 
            WHEN s.StoreKey IS NULL OR s.StoreKey = 0 THEN 'Online'
            ELSE 'In-Store'
        END AS OrderChannel
    FROM sales s
)

SELECT 
    OrderChannel,
    p.`Product Name`,
    ROUND(SUM(p.`Unit Price USD` * s.Quantity), 2) AS Total_Revenue
FROM sales_with_channel s
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY OrderChannel, p.`Product Name`
ORDER BY OrderChannel, Total_Revenue DESC
LIMIT 10;

-- 16. Top 10 Customers by Total Spend:
SELECT 
    c.Name AS Customer_Name,
    SUM(s.Quantity * p.`Unit Price USD`) AS Total_Spend_USD
FROM Sales s
JOIN Customers c ON s.CustomerKey = c.CustomerKey
JOIN Products p ON s.ProductKey = p.ProductKey
GROUP BY c.CustomerKey, c.Name
ORDER BY Total_Spend_USD DESC
LIMIT 10;

-- 17 Store Performance by Region

SELECT 
  st.Country,
  st.State,
  COUNT(DISTINCT s.`Order Number`) AS Orders,
  SUM(s.Quantity) AS Total_Sales
FROM sales s
JOIN stores st ON s.StoreKey = st.StoreKey
GROUP BY st.Country, st.State
ORDER BY Total_Sales DESC;


-- 18. Inventory Planning: Fast vs Slow Moving Products

SELECT 
  p.`Product Name`,
  SUM(s.Quantity) AS Total_Sold,
  CASE 
    WHEN SUM(s.Quantity) > 300 THEN 'Fast Moving'
    WHEN SUM(s.Quantity) < 100 THEN 'Slow Moving'
    ELSE 'Average'
  END AS Product_Movement_Category
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY s.ProductKey
ORDER BY Total_Sold;

-- 19.Summary Count of Product Movement Categories

SELECT Product_Movement_Category, COUNT(*) AS Product_Count
FROM (
  SELECT 
    p.`Product Name`,
    SUM(s.Quantity) AS Total_Sold,
    CASE 
      WHEN SUM(s.Quantity) > 300 THEN 'Fast Moving'
      WHEN SUM(s.Quantity) < 100 THEN 'Slow Moving'
      ELSE 'Average'
    END AS Product_Movement_Category
  FROM sales s
  JOIN products p ON s.ProductKey = p.ProductKey
  GROUP BY s.ProductKey
) AS categorized
GROUP BY Product_Movement_Category;

-- 20. Delivery Performance Analysis
SELECT 
  COUNT(*) AS Late_Deliveries
FROM sales
WHERE DATEDIFF(`Delivery Date`, `Order Date`) > 5;

-- 21 Revenue Contribution by Country

SELECT 
  st.Country,
  SUM(s.Quantity * p.`Unit Price USD`) AS Revenue
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
JOIN stores st ON s.StoreKey = st.StoreKey
GROUP BY st.Country
ORDER BY Revenue DESC;

-- 22 Sales Performance by Product Color:

SELECT 
  p.Color,
  SUM(s.Quantity) AS Total_Sold
FROM sales s
JOIN products p ON s.ProductKey = p.ProductKey
GROUP BY p.Color
ORDER BY Total_Sold DESC;










  



