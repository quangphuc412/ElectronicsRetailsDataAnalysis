/*
===============================================================================
Stores Report
===============================================================================
Purpose:
    - This report consolidates key store metrics and behaviors

Highlights:
    1. Gathers essential fields such as Store Key, Country, State, Store_Age(Months).
	2. Segments store by revenue to identify High-Revenue, Mid-Revenue, or Low-Revenue.
    3. Aggregates store-level metrics:
	   - total orders
	   - total sales
	   - total quantity sold
	   - total customer (unique)
	   - total product (unique)
	   - lifespan (in months)
    4. Calculates valuable KPIs:
		- average order revenue
		- average monthly revenue
===============================================================================

-- =============================================================================
-- Create Report: dbo.report_stores
-- =============================================================================
*/
DROP VIEW IF EXISTS report_stores;
GO

CREATE VIEW report_stores AS

WITH base_query AS(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
SELECT
	Sales.Order_Number,
	Sales.Order_Date,
	Sales.CustomerKey,
	Sales.ProductKey,
	Sales.Quantity,
	(Products.Unit_Price_USD * Sales.Quantity) AS Total,
	Sales.StoreKey,
	Stores.Country,
	Stores.State,
	Stores.Open_Date,
	CASE
		WHEN Stores.Country = 'Online' THEN 0
		ELSE DATEDIFF(YEAR, Stores.Open_Date, (SELECT MAX(Order_Date) FROM Sales))
	END AS Store_Age
FROM Sales
LEFT JOIN Products
	ON Sales.ProductKey = Products.ProductKey
LEFT JOIN Stores
	ON Sales.StoreKey = Stores.StoreKey
),
store_aggregation AS (
/*---------------------------------------------------------------------------
2) Store Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT
	StoreKey,
	Country,
	State,
	Open_Date,
	Store_Age,
	DATEDIFF(MONTH, MIN(Order_Date), MAX(Order_Date)) AS Lifespan,
	COUNT(DISTINCT Order_Number) AS Total_Orders,
	COUNT(DISTINCT CustomerKey) AS Total_Customers,
	COUNT(DISTINCT ProductKey) AS Total_Products,
	SUM(Total) AS Total_Sales,
	SUM(Quantity) AS Total_Quantity
FROM base_query
GROUP BY 
	StoreKey,
	Country,
	State,
	Open_Date,
	Store_Age
)
-- Final query: Combines all stores results into one output.
SELECT
	StoreKey,
	Country,
	State,
	Open_Date,
	Store_Age,
	Total_Sales,
	CASE 
	    WHEN Total_Sales > 1000000 THEN 'High-Revenue'
	    WHEN Total_Sales >= 100000 THEN 'Mid-Revenue'
	    ELSE 'Low-Revenue'
	END AS Store_Segment,
	Lifespan,
	Total_Orders,
	Total_Quantity,
	Total_Customers,
	Total_Products,
	-- Average Order Revenue
	CASE
		WHEN Total_Orders = 0 THEN 0
		ELSE Total_Sales / Total_Orders
	END AS Avg_Order_Revenue,
	-- Average Monthly Revenue
	CASE
		WHEN Lifespan = 0 THEN 0
		ELSE Total_Sales / Lifespan
	END AS Avg_Monthly_Revenue
FROM store_aggregation