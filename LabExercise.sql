-- ***Task 1 - ***


-- Step 1: Set AdventureWorks as the current database
USE AdventureWorks;
GO

-- Step 2: Create a table for denormalizing

CREATE TABLE Sales.ProductList
(
	ProductID int NOT NULL,
	ProductName nvarchar(50) NOT NULL,
	ProductNumber nvarchar(25) NOT NULL,
	Color nvarchar(15) NULL,
	ProductCategoryID int NOT NULL,
	Supplier nvarchar(30) NULL,
	SupplierPostCode nvarchar(10) NULL,
	DateCreated datetime DEFAULT GETDATE() NOT NULL
);
GO

INSERT INTO Sales.ProductList (ProductID, ProductName, ProductNumber, Color, ProductCategoryID, Supplier, SupplierPostCode)
SELECT p.ProductID, p.[Name], p.ProductNumber, p.Color, p.ProductSubcategoryID, 
		CASE c.ProductCategoryID
			WHEN 1 THEN 'Bike Warehouse'
			WHEN 2 THEN 'AW Parts & Components'
			WHEN 3 THEN 'Riding High Apparel'
			WHEN 4 THEN 'The Bike Chain'
		END AS Supplier, 
		CASE c.ProductCategoryID
			WHEN 1 THEN 'AB9 0JU'
			WHEN 2 THEN 'NG7 9HT'
			WHEN 3 THEN 'SW12 4GB'
			WHEN 4 THEN '00-0001'
		END AS SupplierPostCode	
FROM	Production.Product AS p
INNER	JOIN Production.ProductCategory AS c ON p.ProductSubcategoryID = c.ProductCategoryID;
GO

SELECT * 
	FROM sales.productList


-- Step 3: Alter the table to confirm to third normal form

CREATE TABLE Sales.Supplier
(
	SupplierID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Supplier nvarchar(30) NOT NULL,
	SupplierPostCode nvarchar(10) NULL
);
GO

INSERT INTO Sales.Supplier (Supplier, SupplierPostCode)
VALUES ('Bike Warehouse','AB9 0JU'), ('AW Parts & Components','NG7 9HT'), ('Riding High Apparel', 'SW12 4GB'), ('The Bike Chain', '00-0001');
GO

SELECT * 
	FROM Sales.Supplier

-- Step 4: Drop and recreate the ProductList table

DROP TABLE Sales.ProductList

CREATE TABLE Sales.ProductList
(
	ProductID int NOT NULL,
	ProductName nvarchar(50) NOT NULL,
	ProductNumber nvarchar(25) NOT NULL,
	Color nvarchar(15) NULL,
	ProductCategoryID int FOREIGN KEY REFERENCES Production.ProductCategory (ProductCategoryID) NOT NULL,
	SupplierID int FOREIGN KEY REFERENCES Sales.Supplier (SupplierID) NOT NULL,
	DateCreated datetime DEFAULT GETDATE() NOT NULL,

);
GO

-- Step 5: Populate the new ProductList table

INSERT INTO Sales.ProductList (ProductID, ProductName, ProductNumber, Color, ProductCategoryID, SupplierID)
SELECT p.ProductID, p.[Name], p.ProductNumber, p.Color, p.ProductSubcategoryID, 
		CASE c.ProductCategoryID
			WHEN 1 THEN 1
			WHEN 2 THEN 2
			WHEN 3 THEN 3
			WHEN 4 THEN 4
		END AS SupplierID 
FROM	Production.Product AS p
INNER	JOIN Production.ProductCategory AS c ON p.ProductSubcategoryID = c.ProductCategoryID;
GO

SELECT * 
	FROM sales.ProductList



-- ***Task 2 - creating schema***


CREATE SCHEMA HumanResources
AUTHORIZATION dbo;
GO


-- Step : Create a table using the new schema

CREATE TABLE HumanResources.Employee
(
	EmployeeID int IDENTITY(1,1) PRIMARY KEY,
	EmployeeInsuranceCode nvarchar(15) NOT NULL,
	FirstName nvarchar(15) NOT NULL,
	MiddleInitial char(1) NULL,
	LastName nvarchar(25) NOT NULL,
	Email nvarchar(30) NOT NULL
);
GO


-- Step : Drop the schema

DROP SCHEMA HumanResources;
GO


-- Step 5: Drop the table and then the schema

DROP TABLE HumanResources.Employee;
GO

DROP SCHEMA HumanResources;
GO




-- ***Task 3 - creating tables***

CREATE TABLE SalesLT.Courier
( 
	CourierID int NOT NULL,
	CourierCode char(3) NOT NULL,
	CourierName nvarchar(50) NOT NULL,
	PRIMARY KEY (CourierID, CourierCode)
);
GO

CREATE TABLE dbo.WebLog
(
	WebLogID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	LogTime datetime NOT NULL DEFAULT GETDATE(),
	UserName sysname NOT NULL,
	URL nvarchar(4000) NOT NULL,
	ErrorSeverity int NULL,
	ErrorState int NULL,
	ErrorProcedure nvarchar(126) NULL,
	ErrorLine int NULL,
	ErrorMessage nvarchar(4000) NOT NULL
);
GO


-- Step : Alter the SalesLT.Courier table

ALTER TABLE SalesLT.Courier
ADD Telephone varchar(15) NULL, Email varchar(25) NULL;
GO

ALTER TABLE SalesLT.Courier
DROP COLUMN Email;


-- Step : Drop the tables

DROP TABLE SalesLT.Courier;
GO
DROP TABLE dbo.WebLog;
GO


-- ***Task 4 - temporary tables***



-- Step 1: Create a local temporary table

USE AdventureWorks;
GO

CREATE TABLE #ProductList
(
	ProductID int NULL,
	ProductCode varchar(15) NULL,
	ProductName varchar(35) NULL

);

INSERT INTO #ProductList (ProductID, ProductCode, ProductName)
SELECT ProductID, ProductNumber, Name FROM Production.Product;

SELECT	* 
FROM	#ProductList

-- Step 3: Create a global temporary table

CREATE TABLE ##ProductList
(
	ProductID int NULL,
	ProductCode varchar(15) NULL,
	ProductName varchar(35) NULL

);

INSERT INTO ##ProductList (ProductID, ProductCode, ProductName)
SELECT ProductID, ProductNumber, Name FROM Production.Product;

SELECT	* 
FROM	##ProductList




-- Step 5: Drop the two temporary tables

DROP TABLE #ProductList;
DROP TABLE ##ProductList;


USE AdventureWorks;
GO

SELECT	* 
FROM	#ProductList


-- Step : Select and execute the following query 

SELECT	* 
FROM	##ProductList





-- ***Task 5 - Computed Columns***


CREATE TABLE SalesLT.SalesOrderDates
(
    SalesOrderID int NOT NULL,
    SalesOrderNumber nvarchar(30) NOT NULL,
    OrderDate date NOT NULL,
    YearOfOrder AS DATEPART(year, OrderDate) PERSISTED,
	ShipDate date NOT NULL,
    YearShipped AS DATEPART(year, ShipDate) PERSISTED
);
GO


-- Step : Populate the table with data

INSERT	INTO SalesLT.SalesOrderDates (SalesOrderID, SalesOrderNumber, OrderDate, ShipDate)
SELECT	SalesOrderID, SalesOrderNumber, OrderDate, ShipDate 
FROM	SalesLT.SalesOrderHeader;
GO


-- Step : Return the results from the SalesLT.SalesOrderDates table

SELECT	*
FROM	SalesLT.SalesOrderDates;
GO


-- Step 5: Update a row in the SalesLT.SalesOrderDates table
UPDATE	SalesLT.SalesOrderDates
SET		OrderDate = '2015-10-01'
WHERE	SalesOrderID = 71774;
GO
SELECT	*
FROM	SalesLT.SalesOrderDates;
GO


-- Step 6: Create a table with a computed column that is not persisted
CREATE TABLE SalesLT.TotalSales
(
    ProductID int NOT NULL,
    ProductName nvarchar(50) NOT NULL,
	UnitPrice money NOT NULL,
	UnitsSold smallint NULL, 
	TotalSales AS (UnitsSold * UnitPrice)
);
GO


-- Step 7: Populate the table with data
INSERT INTO SalesLT.TotalSales (ProductID, ProductName, UnitPrice, UnitsSold)
SELECT	s.ProductID, p.Name AS ProductName, SUM(s.UnitPrice) AS UnitPrice, SUM(OrderQty) AS UnitsSold
FROM	SalesLT.SalesOrderDetail AS s
INNER	JOIN SalesLT.Product AS p ON s.ProductID = p.ProductID
GROUP	BY s.ProductID, p.Name;
GO


-- Step 8 - Return the results from the SalesLT.TotalSales table
SELECT	* 
FROM	SalesLT.TotalSales;
GO



