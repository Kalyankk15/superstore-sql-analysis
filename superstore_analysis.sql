-- 🗃️ Database & Table Setup
CREATE DATABASE IF NOT EXISTS superstore;
USE superstore;

CREATE TABLE Orders (
    Row_ID INT,
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(100),
    State VARCHAR(100),
    Postal_Code VARCHAR(20),
    Region VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(255),
    Sales DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(4,2),
    Profit DECIMAL(10,2),
    Shipping_Cost DECIMAL(10,2),
    Order_Priority VARCHAR(50)
);


-- 📊 Data Exploration
DESCRIBE Orders;

SELECT ROUND(SUM(Sales) / 1000000, 2) AS Total_Sales_in_Millions FROM Orders;
SELECT COUNT(DISTINCT Customer_ID) AS Unique_Customers FROM Orders;
SELECT COUNT(*) AS Total_Rows FROM Orders;
SELECT COUNT(DISTINCT Country) AS Countries FROM Orders;
SELECT COUNT(DISTINCT Category) AS Categories FROM Orders;
SELECT COUNT(DISTINCT Sub_Category) AS Sub_Categories FROM Orders;



-- 🧹 Data Cleaning
ALTER TABLE Orders
DROP COLUMN Row_ID,
DROP COLUMN Segment,
DROP COLUMN Postal_Code,
DROP COLUMN Market,
DROP COLUMN Shipping_Cost;


-- Check and Remove NULLs
SELECT * FROM Orders
WHERE Order_ID IS NULL OR Order_Date IS NULL OR Ship_Date IS NULL OR 
      Customer_ID IS NULL OR Product_Name IS NULL OR Region IS NULL OR 
      Sales IS NULL OR Profit IS NULL;

DELETE FROM Orders
WHERE Order_ID IS NULL OR Order_Date IS NULL OR Ship_Date IS NULL OR 
      Customer_ID IS NULL OR Product_Name IS NULL OR Region IS NULL OR 
      Sales IS NULL OR Profit IS NULL;



-- 📈 Data Analysis Queries

-- 1. Total profit by year
SELECT YEAR(Order_Date) AS Year, SUM(Profit) AS Total_Profit
FROM Orders
GROUP BY YEAR(Order_Date)
ORDER BY Year;


-- 2. Total profit by category
SELECT Category, SUM(Profit) AS Total_Profit
FROM Orders
GROUP BY Category
ORDER BY Total_Profit DESC;


-- 3. Top 3 profitable sub-categories per category
WITH categorycte AS (
    SELECT Category, Sub_Category, SUM(Profit) AS Total_Profit
    FROM Orders
    GROUP BY Category, Sub_Category
),
rankingcte AS (
    SELECT *, RANK() OVER(PARTITION BY Category ORDER BY Total_Profit DESC) AS rk
    FROM categorycte
)
SELECT Category, Sub_Category, Total_Profit
FROM rankingcte
WHERE rk < 4
ORDER BY Category, Total_Profit DESC;


-- 4. Profit by region
SELECT Region, SUM(Profit) AS Total_Profit
FROM Orders
GROUP BY Region
ORDER BY Total_Profit DESC;

-- 5. Top 5 regions with top 2 states by profit
WITH top_regions AS (
    SELECT Region, SUM(Profit) AS Total_Profit
    FROM Orders
    GROUP BY Region
    ORDER BY Total_Profit DESC
    LIMIT 5
),
state_profit AS (
    SELECT Region, State, SUM(Profit) AS Total_Profit
    FROM Orders
    WHERE Region IN (SELECT Region FROM top_regions)
    GROUP BY Region, State
),
ranked_states AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Total_Profit DESC) AS rk
    FROM state_profit
)
SELECT Region, State, Total_Profit
FROM ranked_states
WHERE rk <= 2
ORDER BY Region, Total_Profit DESC;


-- 6. Top 10 revenue-generating customers and their buying pattern
WITH top_customers AS (
    SELECT Customer_Name
    FROM Orders
    GROUP BY Customer_Name
    ORDER BY SUM(Sales) DESC
    LIMIT 10
)
SELECT Customer_Name, 
       COUNT(DISTINCT Order_ID) AS Total_Orders,
       ROUND(SUM(Sales) / COUNT(DISTINCT Order_ID), 2) AS Avg_Order_Value
FROM Orders
WHERE Customer_Name IN (SELECT Customer_Name FROM top_customers)
GROUP BY Customer_Name
ORDER BY Avg_Order_Value DESC;


-- 7. Shipping modes: usage and delivery time
SELECT Ship_Mode, 
       COUNT(*) AS Total_Orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS Order_Percentage,
       ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)), 2) AS Avg_Delivery_Days
FROM Orders
GROUP BY Ship_Mode
ORDER BY Total_Orders DESC;


-- 8. Order priority impact
SELECT Order_Priority, 
       COUNT(*) AS Total_Orders, 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS Priority_Percentage,
       ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)), 2) AS Avg_Delivery_Days,
       ROUND(AVG(Sales), 2) AS Avg_Sales_Per_Order,
       ROUND(AVG(Profit), 2) AS Avg_Profit_Per_Order
FROM Orders
GROUP BY Order_Priority
ORDER BY Priority_Percentage DESC;


-- 9. Order volume by year
SELECT YEAR(Order_Date) AS Year, COUNT(DISTINCT Order_ID) AS Orders_Count
FROM Orders
GROUP BY YEAR(Order_Date)
ORDER BY Year;


-- 10. Top 10 most profitable sub-categories with categories
WITH top_subcategories AS (
    SELECT Sub_Category, SUM(Profit) AS Total_Profit
    FROM Orders
    GROUP BY Sub_Category
    ORDER BY Total_Profit DESC
    LIMIT 10
)
SELECT o.Category, t.Sub_Category, t.Total_Profit
FROM top_subcategories t
JOIN (
    SELECT DISTINCT Sub_Category, Category
    FROM Orders
) o ON t.Sub_Category = o.Sub_Category
ORDER BY t.Total_Profit DESC;
