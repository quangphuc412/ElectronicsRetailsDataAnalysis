-- Explore Dataset --
-----------------------------------------------------
------------ Explore customers table ----------------

-- Customers table --
SELECT TOP 50 * 
FROM Customer

-- Number of rows in the customer table --
SELECT COUNT(*) AS NumberOfCustomers 
FROM Customer

-- Number of people by Gender --
SELECT
	Gender,
	COUNT(*) AS NumberOfPeople
FROM Customer
GROUP BY Gender
ORDER BY Gender DESC

-- Compute total number of people by gender with their corresponding proportions with CTE --
WITH group_by_gender AS (
	SELECT
		Gender,
		COUNT(*) AS NumberOfPeople
	FROM Customer
	GROUP BY Gender
)
SELECT
	Gender,
	NumberOfPeople,
	ROUND((CAST(NumberOfPeople AS FLOAT) / (SELECT SUM(NumberOfPeople) FROM group_by_gender)), 3) AS Proportion
FROM group_by_gender

-- Compute total number of people by country with their corresponding proportions with CTE --
WITH group_by_country AS (
	SELECT 
		Country,
		COUNT(*) AS  NumberOfPeople
	FROM Customer
	GROUP BY Country
)
SELECT
	Country,
	NumberOfPeople,
	ROUND((CAST(NumberOfPeople AS FLOAT) / (SELECT SUM(NumberOfPeople) FROM group_by_country)), 3) AS Proportion
FROM group_by_country
ORDER BY Proportion DESC

-- Compute total number of people by continent with their corresponding proportions with CTE --
WITH group_by_continent AS (
	SELECT 
		Continent,
		COUNT(*) AS  NumberOfPeople
	FROM Customer
	GROUP BY Continent
)
SELECT
	Continent,
	NumberOfPeople,
	ROUND((CAST(NumberOfPeople AS FLOAT) / (SELECT SUM(NumberOfPeople) FROM group_by_continent)), 3) AS Proportion
FROM group_by_continent
ORDER BY Proportion DESC

-- Compute the number of customers by State in the USA --
SELECT
	State, 
	COUNT(*) AS NumberOfPeople
FROM Customer
WHERE Country = 'United States'
GROUP BY State
ORDER BY NumberOfPeople DESC

-- 


----------------------------------------------------
---------- Explore exchange_rates table ------------

-- See the table content --
SELECT TOP 50 * 
FROM Exchange_Rates

----------------------------------------------------
-------------- Explore products table --------------

-- Snaphshot of the products table --
SELECT TOP 50 * 
FROM Products

-- Display the number of products in the table --
SELECT 
	COUNT(*) AS NumberOfProducts 
FROM Products

-- Display the number of products in the table by brand --
SELECT 
	Brand,
	COUNT(*) AS NumberOfProducts
FROM Products
GROUP BY Brand
ORDER BY NumberOfProducts DESC

-- Display the number of products in the table by category --
SELECT 
	Category,
	COUNT(*) AS NumberOfProducts
FROM Products
GROUP BY Category
ORDER BY NumberOfProducts DESC

-- Display the number of products in the table by category with their respective proportions, having a proportion > 0.1 --
WITH group_by_category AS (
	SELECT 
		Category,
		COUNT(*) AS NumberOfProducts
	FROM Products
	GROUP BY Category
)
SELECT
	Category,
	NumberOfProducts,
	ROUND((CAST(NumberOfProducts AS FLOAT) / (SELECT SUM(NumberOfProducts) FROM group_by_category)), 3) AS Proportion
FROM group_by_category
WHERE 
	ROUND((CAST(NumberOfProducts AS FLOAT) / (SELECT SUM(NumberOfProducts) FROM group_by_category)), 3) > 0.1
ORDER BY NumberOfProducts DESC

-- Display the number of products in the table by subcategory where the category is home appliances --
SELECT 
	Subcategory
	, COUNT(*) AS NumberOfProducts
FROM products
WHERE Category = 'Home Appliances'
GROUP BY Subcategory
ORDER BY NumberOfProducts DESC

----------------------------------------------------
----------------- Explore stores -------------------

-- Snapshot of the stores table --
SELECT * 
FROM Stores

-- Number of stores by country --
SELECT 
	Country,
	COUNT(DISTINCT StoreKey) AS NumberOfStores
FROM Stores
GROUP BY Country
ORDER BY NumberOfStores DESC

-- Number of stores by state in the US --
SELECT 
	State,
	COUNT(DISTINCT StoreKey) AS NumberOfStores 
FROM Stores
WHERE Country = 'United States'
GROUP BY State
ORDER BY NumberOfStores DESC


----------------------------------------------------
------------------ Explore sales -------------------

-- Snapshot of the sales table --
SELECT TOP 50 * 
FROM Sales

-- Count of the number of records --
SELECT
	COUNT(*) AS NumberOfRecords 
FROM Sales

-- Count of the number of distinct orders--
SELECT 
	COUNT(DISTINCT Order_Number) AS NumberOfDistinctOrders 
FROM Sales

-- Count of the number of orders by store --
SELECT
	Sales.StoreKey,
	Stores.Country,
	COUNT(DISTINCT Sales.Order_Number) AS NumberOfDistinctOrders
FROM Sales
JOIN Stores 
	ON Sales.StoreKey = Stores.StoreKey
GROUP BY 
	Sales.StoreKey,
	Stores.Country
ORDER BY NumberOfDistinctOrders DESC

-- Quantity sold by store --
SELECT TOP 10
	StoreKey,
	SUM(Quantity) AS SumQuantity
FROM Sales
GROUP BY StoreKey
ORDER BY SumQuantity DESC

-- Distinct number of customer keys by store --
SELECT TOP 10
	StoreKey,
	COUNT(DISTINCT CustomerKey) AS NbCustomerKeys
FROM Sales
GROUP BY StoreKey
ORDER BY NbCustomerKeys DESC