/*
===============================================================================
Customers Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as customer_id, age, country and transaction details.
	2. Segments customers into categories (VIP, Regular, New).
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================

-- =============================================================================
-- Create Report: dbo.report_customers
-- =============================================================================
*/
DROP VIEW IF EXISTS report_customers;
GO

CREATE VIEW report_customers AS

WITH base_query AS(
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
SELECT
	Sales.Order_Number,
	Sales.Order_Date,
	Sales.CustomerKey,
	DATEDIFF(YEAR, Customer.Birthday, (SELECT DISTINCT MAX(Order_Date) FROM Sales)) AS Age,
	Customer.Gender,
	Customer.Country,
	Customer.State,
	Sales.ProductKey,
	Sales.Quantity,
	Products.Unit_Price_USD,
	(Products.Unit_Price_USD * Sales.Quantity) AS Total
FROM Sales
LEFT JOIN Customer
	ON Sales.CustomerKey = Customer.CustomerKey
LEFT JOIN Products
	ON Sales.ProductKey = Products.ProductKey
),
customer_aggregation AS (
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
SELECT
	CustomerKey,
	Country,
	State,
	Gender,
	Age,
	COUNT(DISTINCT Order_Number) AS Total_Orders,
	SUM(Total) AS Total_Sales,
	SUM(Quantity) AS Total_Quantity,
	COUNT(DISTINCT ProductKey) AS Total_Products,
	MIN(Order_Date) AS First_Order_Date,
	MAX(Order_Date) AS Last_Order_Date,
	DATEDIFF(MONTH, MIN(Order_Date), MAX(Order_Date)) AS Lifespan
FROM base_query
GROUP BY 
	CustomerKey,
	Country,
	State,
	Gender,
	Age
)
SELECT
	CustomerKey,
	Country,
	State,
	Gender,
	Age,
	CASE 
	    WHEN lifespan >= 24 AND total_sales > 15000 THEN 'Supper VIP'
		WHEN lifespan >= 12 AND total_sales > 10000 THEN 'VIP'
	    WHEN lifespan >= 12 AND total_sales <= 10000 THEN 'Regular'
	    ELSE 'New'
	END AS Customer_Segment,
	First_Order_Date,
	Last_Order_Date,
	DATEDIFF(DAY, Last_Order_Date, (SELECT MAX(Order_Date) FROM Sales)) AS Recency,
	Lifespan,
	Total_Orders,
	Total_Sales,
	Total_Quantity,
	Total_Products,
	-- Compuate average order value (AOV)
	CASE WHEN total_sales = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS Avg_Order_Value,
	-- Compuate average monthly spend
	CASE WHEN lifespan = 0 THEN total_sales
	     ELSE total_sales / lifespan
	END AS Avg_Monthly_Spend
FROM customer_aggregation