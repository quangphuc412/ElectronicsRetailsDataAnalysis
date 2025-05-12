/*
===============================================================================
Sales Report
===============================================================================
Purpose:
    - This report consolidates key sales metrics and behaviors

Highlights:
    1. Gathers essential fields such as sales details infomation by month.
    2. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
    4. Calculates valuable KPIs:
		- average order value
===============================================================================
*/

-- =============================================================================
-- Create Report: dbo.report_sales
-- =============================================================================
DROP VIEW IF EXISTS report_sales;
GO

CREATE VIEW report_sales AS

WITH base_query AS(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
SELECT
	Sales.Order_Number,
	Sales.Order_Date,
	Sales.CustomerKey,
	Sales.StoreKey,
	Sales.ProductKey,
	Sales.Quantity,
	Products.Unit_Cost_USD,
	Products.Unit_Price_USD,
	MONTH(Sales.Order_Date) AS Month,
	YEAR(Sales.Order_Date) AS Year,
	(Products.Unit_Cost_USD * Sales.Quantity) AS Total_Costs,
	(Products.Unit_Price_USD * Sales.Quantity) AS Total_Sales
FROM Sales 
LEFT JOIN Products
	ON Sales.ProductKey = Products.ProductKey
),
sales_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT
	Month,
	Year,
	COUNT(DISTINCT Order_Number) AS Total_Orders,
	ROUND(SUM(Total_Costs), 2) AS Total_Costs,
	ROUND(SUM(Total_Sales), 2) AS Total_Sales,
	SUM(Quantity) AS Total_Quantity,
	COUNT(DISTINCT ProductKey) AS Total_Products,
	COUNT(DISTINCT CustomerKey) AS Total_Customers
FROM base_query
GROUP BY 
	Month,
	Year
)
SELECT
	*,
	-- Compuate average total price per one order value
	ROUND(Total_Sales / Total_Orders, 2) AS Avg_Order_Value
FROM sales_aggregation