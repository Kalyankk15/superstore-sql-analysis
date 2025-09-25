# Retail Sales Analysis 🧠📊

### Project Overview 📚

The primary goal of this project is to extract actionable business insights through structured SQL queries. I explore patterns in sales, profits, customer behavior, order priorities, and shipping methods. This analysis demonstrates my ability to write efficient SQL, solve real business problems, and communicate findings clearly. By performing exploratory analysis, data cleaning, and business-oriented querying, this project offers a solid example of how SQL can be used to drive data-driven decision-making.

### Data Source 🗃️

- Source: [Superstore Excel File]
- Fields: `Order_ID`, `Order_Date`, `Ship_Date`, `Category`, `Sales`, `Profit`, `Region`, `Customer_ID`, `Ship_Mode`, `Order_Priority`, etc.
- Rows: ~50,000+

### Objectives 📌

- **Set up the database:** Create the database and table with necessary columns.
- **Data Cleaning:** Identify and remove any records with missing or null values.
- **Exploratory Data Analysis (EDA):** Perform basic exploratory data analysis to understand the dataset.
- **Business Analysis:** Use SQL to answer specific business questions and derive insights from the sales data.

### Project Structure 📂

### 1. Database Setup

- **Database creation:** The project starts by creating a database named `superstore`.
- **Table Creation:** A table named `Orders` is created to store the sales data and along with this necessary columns are also created.

```sql
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
```   

### 2. Data Exploration 

Before diving into analysis, initial exploration was conducted to understand the scope and structure of the dataset:

- The Orders table structure was reviewed using the DESCRIBE command to verify column types and schema readiness.
- Total sales across the entire dataset amounted showcasing a large volume of business activity.
- The dataset contains a diverse customer base with over many unique customers, spread across multiple countries and regions.
- There are ~50000+ total rows  in the dataset.
- Products are categorized into  high-level categories and  sub-categories, allowing for granular product-level analysis.

```sql
DESCRIBE Orders;

SELECT ROUND(SUM(Sales) / 1000000, 2) AS Total_Sales_in_Millions FROM Orders;
SELECT COUNT(DISTINCT Customer_ID) AS Unique_Customers FROM Orders;
SELECT COUNT(*) AS Total_Rows FROM Orders;
SELECT COUNT(DISTINCT Country) AS Countries FROM Orders;
SELECT COUNT(DISTINCT Category) AS Categories FROM Orders;
SELECT COUNT(DISTINCT Sub_Category) AS Sub_Categories FROM Orders;
```

### 3. Data Cleaning

Check for any null values in the dataset and delete records with missing data.

```sql
ALTER TABLE Orders
DROP COLUMN Row_ID,
DROP COLUMN Segment,
DROP COLUMN Postal_Code,
DROP COLUMN Market,
DROP COLUMN Shipping_Cost;


SELECT * FROM Orders
WHERE Order_ID IS NULL OR Order_Date IS NULL OR Ship_Date IS NULL OR 
      Customer_ID IS NULL OR Product_Name IS NULL OR Region IS NULL OR 
      Sales IS NULL OR Profit IS NULL;

DELETE FROM Orders
WHERE Order_ID IS NULL OR Order_Date IS NULL OR Ship_Date IS NULL OR 
      Customer_ID IS NULL OR Product_Name IS NULL OR Region IS NULL OR 
      Sales IS NULL OR Profit IS NULL;
```

### 4.Data Analysis & Findings
The following SQL queries were developed to answer specific business questions:

 **1. What is the total profit for different years?**

```sql
SELECT Category, SUM(Profit) AS Total_Profit
FROM Orders
GROUP BY Category
ORDER BY Total_Profit DESC;
```

 **2. What is the total profits of different categories?**

 ```sql
SELECT Category, SUM(Profit) AS Total_Profit
FROM Orders
GROUP BY Category
ORDER BY Total_Profit DESC;
```

 **3. Which product categories and sub-categories generate the highest and lowest profits?**

 ```sql
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
```

 **4. Which regions  are most profitable, and which are operating at a loss?**

```sql
SELECT Region, SUM(Profit) AS Total_Profit
FROM Orders
GROUP BY Region
ORDER BY Total_Profit DESC;
```

 **5. Which regions and state generate highest profits?**

```sql
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
```

 **6. Who are the top 10 revenue-generating customers, and what patterns exist in their buying behavior?**

```sql
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
```

 **7. Which shipping modes are most commonly used, and how do they impact cost and delivery timelines?**

```sql
SELECT Ship_Mode, 
       COUNT(*) AS Total_Orders,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS Order_Percentage,
       ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)), 2) AS Avg_Delivery_Days
FROM Orders
GROUP BY Ship_Mode
ORDER BY Total_Orders DESC;
```

 **8. How does order priority affect delivery speed and profitability?**

```sql
SELECT Order_Priority, 
       COUNT(*) AS Total_Orders, 
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Orders), 2) AS Priority_Percentage,
       ROUND(AVG(DATEDIFF(Ship_Date, Order_Date)), 2) AS Avg_Delivery_Days,
       ROUND(AVG(Sales), 2) AS Avg_Sales_Per_Order,
       ROUND(AVG(Profit), 2) AS Avg_Profit_Per_Order
FROM Orders
GROUP BY Order_Priority
ORDER BY Priority_Percentage DESC;
```

 **9. How does order volume vary by year?**

 ```sql
SELECT YEAR(Order_Date) AS Year, COUNT(DISTINCT Order_ID) AS Orders_Count
FROM Orders
GROUP BY YEAR(Order_Date)
ORDER BY Year;
```

 **10. What are the top 10 most profitable sub-categories?**

 ```sql
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
```


### Key Insights 💡
**1. Technology is the Most Profitable Category**
- The Technology category consistently delivers the highest total profit across all years, suggesting it is a core revenue driver. Strategic focus on this category can further enhance profitability.

**2. Critical Priority Orders Have the Fastest Delivery**
- Orders marked as "Critical" have the shortest average delivery time (~1.8 days) and also generate the highest profit per order. This validates the operational efficiency for high-priority shipments.

**3.Standard Class is the Most Used Shipping Mode**
- Over 50% of orders are shipped using the Standard Class mode. While it's the most common, it has a longer delivery time compared to other modes — indicating a trade-off between cost-efficiency and speed.

**4. February is a Consistently Underperforming Month**
- Sales and order volume tend to dip in February across multiple years, suggesting a seasonal slowdown. This insight can guide promotional strategies to boost demand during that period.

**5. Top Customers Have Higher Average Order Value**
- The top 10 customers not only contribute significantly to total revenue, but they also have a higher average order value. These customers are ideal targets for loyalty programs and personalized marketing.


## 📈 Power BI Dashboard
To complement the SQL analysis, I built an **interactive Power BI dashboard** for visualization and storytelling.
<img width="1597" height="870" alt="Screenshot 2025-09-21 221627" src="https://github.com/user-attachments/assets/9f31d323-bc76-41cb-9702-fe7aa7f54a85" />

This dashboard allows interactive exploration, making it easier to connect SQL insights to business decisions.


### Dashboard Features:
- **KPI Cards**: Total Sales, Total Profit, Total Orders, Unique Customers
- **Line Chart**: Sales & Profit trends over time (Year-Month)
- **Category & Sub-Category Bar Charts**: Top and bottom performers
- **Map Hierarchy**: Drilldown from Region → State → City for sales and profit
- **Shipping & Priority Analysis**: Orders by ship mode, delivery speed by priority
- **Filters (Slicers)**: Year, Category


### Recommendations ✅

- Reevaluate Low-Profit Sub-Categories.
- Prioritize High-Value Customers for Retention.
- Use Data-Driven Order Priority Policies.

###  Conclusion 🧾
This project demonstrates how SQL can be used to explore, clean, and analyze business data to uncover meaningful insights. Through structured queries and data exploration of the Superstore dataset, we identified key drivers of profit, seasonal trends in sales, and operational patterns in shipping and customer behavior. By combining data analysis with business reasoning, the project delivers actionable insights that can help improve profitability, customer targeting, and operational efficiency. 
