DROP VIEW IF EXISTS customer_segmentation_rfm;
GO

CREATE VIEW customer_segmentation_rfm AS

WITH rfm_base AS(
	SELECT
		Sales.CustomerKey,
		MAX(Sales.Order_Date) AS Last_Purchase_Date,
		COUNT(DISTINCT Sales.Order_Number) AS Frequency,
		SUM(Sales.Quantity * Products.Unit_Price_USD) AS Monetary
	FROM Sales
	JOIN Customer ON Sales.CustomerKey = Customer.CustomerKey
	JOIN Products ON Sales.ProductKey = Products.ProductKey
	GROUP BY Sales.CustomerKey
), 
max_date AS(
	SELECT MAX(DISTINCT Sales.Order_Date) AS Max_Order_Date
	FROM Sales
),
rfm_calculated AS(
	SELECT
		*,
		DATEDIFF(DAY, Last_Purchase_Date, (SELECT Max_Order_Date FROM max_date)) AS Recency,
		NTILE(5) OVER (ORDER BY DATEDIFF(DAY, Last_Purchase_Date, (SELECT Max_Order_Date FROM max_date)) DESC) AS R_Score,
		NTILE(5) OVER (ORDER BY Frequency) AS F_Score,
		NTILE(5) OVER (ORDER BY Monetary) AS M_Score
	FROM rfm_base
),
rfm_segment AS (
	SELECT
		CustomerKey,
		Recency,
		Frequency,
		Monetary,
		R_Score,
		F_Score,
		M_Score,
		(CONCAT(CAST(R_score AS VARCHAR), CAST(F_score AS VARCHAR), CAST(M_score AS VARCHAR))) AS RFM_Score
	FROM RFM_Calculated
)
SELECT * FROM rfm_segment