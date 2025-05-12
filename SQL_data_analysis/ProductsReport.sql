/*
===============================================================================
Products Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors

Highlights:
    1. Gathers essential fields such as Product Key, Product Name, Category, SubCategory, Brand and Cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Range.
    3. Aggregates product-level metrics:
	   - total orders
	   - total sales
	   - total quantity sold
	   - total customer (unique)
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order revenue
		- average monthly revenue
===============================================================================

-- =============================================================================
-- Create Report: dbo.report_products
-- =============================================================================
*/
DROP VIEW IF EXISTS report_products;
GO

CREATE VIEW report_products AS

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
	Products.Unit_Cost_USD,
	Products.Unit_Price_USD,
	(Products.Unit_Price_USD * Sales.Quantity) AS Total,
	Products.Product_Name,
	Products.Category,
	Products.Subcategory,
	Products.Brand
FROM Sales
LEFT JOIN Products
	ON Sales.ProductKey = Products.ProductKey
),
product_aggregation AS (
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT
	ProductKey,
	Product_Name,
	Category,
	Subcategory,
	Brand,
	Unit_Cost_USD,
	Unit_Price_USD,
	DATEDIFF(MONTH, MIN(Order_Date), MAX(Order_Date)) AS Lifespan,
	MAX(Order_Date) AS Last_Sale_Date,
	COUNT(DISTINCT Order_Number) AS Total_Orders,
	COUNT(DISTINCT CustomerKey) AS Total_Customers,
	SUM(Total) AS Total_Sales,
	SUM(Quantity) AS Total_Quantity,
	ROUND(AVG(CAST(Total AS FLOAT) / NULLIF(Quantity, 0)), 2) AS Avg_Selling_Price
FROM base_query
GROUP BY 
	ProductKey,
	Product_Name,
	Category,
	Subcategory,
	Brand,
	Unit_Cost_USD,
	Unit_Price_USD
)
-- Final query: Combines all products results into one output.
SELECT
	ProductKey,
	Product_Name,
	Category,
	Subcategory,
	Brand,
	Unit_Cost_USD,
	Unit_Price_USD,
	Last_Sale_Date,
	DATEDIFF(MONTH, Last_Sale_Date, (SELECT MAX(Order_Date) FROM Sales)) AS Recency_In_Months,
	CASE 
	    WHEN total_sales > 50000 THEN 'High-Performer'
	    WHEN total_sales >= 10000 THEN 'Mid-Range'
	    ELSE 'Low-Performer'
	END AS Product_Segment,
	Lifespan,
	Total_Orders,
	Total_Sales,
	Total_Quantity,
	Total_Customers,
	Avg_Selling_Price,
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
FROM product_aggregation