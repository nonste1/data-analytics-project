 
 
 
 --LOAD OF DATA TO THE TEST DATABASE
 
 
 
/*
TRUNCATE TABLE [Sales].[SalesOrderHeader]
TRUNCATE TABLE [Sales].[Customer]
TRUNCATE TABLE [HumanResources].[Employee]
TRUNCATE TABLE [Person].[Person]
TRUNCATE TABLE [Sales].[SalesTerritory]
TRUNCATE TABLE [Sales].[Store]
TRUNCATE TABLE [Sales].[SalesOrderDetail]
TRUNCATE TABLE [Production].[Product]
TRUNCATE TABLE [Production].[ProductSubCategory]
TRUNCATE TABLE [Production].[ProductCategory]
GO

*/
-------- SalesOrderHeader
SET IDENTITY_INSERT Sales.SalesOrderHeader ON
GO
-- [TotalDue]
-- [SalesOrderNumber]

INSERT INTO [Sales].[SalesOrderHeader]
		   ([SalesOrderID]
		   ,[RevisionNumber]
           ,[OrderDate]
           ,[DueDate]
           ,[ShipDate]
           ,[Status]
           ,[OnlineOrderFlag]
           ,[PurchaseOrderNumber]
           ,[AccountNumber]
           ,[CustomerID]
           ,[SalesPersonID]
           ,[TerritoryID]
           ,[BillToAddressID]
           ,[ShipToAddressID]
           ,[ShipMethodID]
           ,[CreditCardID]
           ,[CreditCardApprovalCode]
           ,[CurrencyRateID]
           ,[SubTotal]
           ,[TaxAmt]
           ,[Freight]
           ,[Comment]
           ,[rowguid]
           ,[ModifiedDate])
SELECT TOP (1000)
	   [SalesOrderID]
	  ,[RevisionNumber]
      ,[OrderDate]
      ,[DueDate]
      ,[ShipDate]
      ,[Status]
      ,[OnlineOrderFlag]
      ,[PurchaseOrderNumber]
      ,[AccountNumber]
      ,[CustomerID]
      ,[SalesPersonID]
      ,[TerritoryID]
      ,[BillToAddressID]
      ,[ShipToAddressID]
      ,[ShipMethodID]
      ,[CreditCardID]
      ,[CreditCardApprovalCode]
      ,[CurrencyRateID]
      ,[SubTotal]
      ,[TaxAmt]
      ,[Freight]
      ,[Comment]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [AdventureWorks2019].[Sales].[SalesOrderHeader]
  WHERE (SalesOrderID%10)=7
  GO
  SET IDENTITY_INSERT Sales.SalesOrderHeader OFF
  GO

---- Sales.Customer
SET IDENTITY_INSERT Sales.Customer ON
GO

INSERT INTO [Sales].[Customer]
           ([CustomerID]
		   ,[PersonID]
           ,[StoreID]
           ,[TerritoryID]
           ,[AccountNumber]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [CustomerID]
	  ,[PersonID]
      ,[StoreID]
      ,[TerritoryID]
      ,[AccountNumber]
      ,[rowguid]
      ,[ModifiedDate]
FROM [AdventureWorks2019].[Sales].[Customer]
WHERE CustomerID IN (
		SELECT DISTINCT CustomerID
		FROM Sales.SalesOrderHeader
)
SET IDENTITY_INSERT Sales.Customer OFF
GO

-- HumanResources.Employee
INSERT INTO [HumanResources].[Employee]
           ([BusinessEntityID]
           ,[NationalIDNumber]
           ,[LoginID]
           ,[OrganizationNode]
		   ,[OrganizationLevel]
           ,[JobTitle]
           ,[BirthDate]
           ,[MaritalStatus]
           ,[Gender]
           ,[HireDate]
           ,[SalariedFlag]
           ,[VacationHours]
           ,[SickLeaveHours]
           ,[CurrentFlag]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [BusinessEntityID]
      ,[NationalIDNumber]
      ,[LoginID]
      ,[OrganizationNode]
      ,[OrganizationLevel]
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
      ,[CurrentFlag]
      ,[rowguid]
      ,[ModifiedDate]
  FROM AdventureWorks2019.[HumanResources].[Employee]
  WHERE BusinessEntityID IN (
		SELECT DISTINCT SalesPersonID
		FROM Sales.SalesOrderHeader
  )

---- Person
INSERT INTO [Person].[Person]
           ([BusinessEntityID]
           ,[PersonType]
           ,[NameStyle]
           ,[Title]
           ,[FirstName]
           ,[MiddleName]
           ,[LastName]
           ,[Suffix]
           ,[EmailPromotion]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [BusinessEntityID]
      ,[PersonType]
      ,[NameStyle]
      ,[Title]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[Suffix]
      ,[EmailPromotion]
      ,[rowguid]
      ,[ModifiedDate]
  FROM AdventureWorks2019.[Person].[Person]
  WHERE BusinessEntityID IN (
		SELECT DISTINCT SalesPersonID
		FROM Sales.SalesOrderHeader
  ) OR BusinessEntityID IN (SELECT DISTINCT PersonID FROM Sales.Customer)

------- Sales.SalesTerritory
SET IDENTITY_INSERT [Sales].[SalesTerritory] ON
GO
INSERT INTO [Sales].[SalesTerritory]
           ([TerritoryID]
		   ,[Name]
           ,[CountryRegionCode]
           ,[Group]
           ,[SalesYTD]
           ,[SalesLastYear]
           ,[CostYTD]
           ,[CostLastYear]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [TerritoryID]
	  ,[Name]
      ,[CountryRegionCode]
      ,[Group]
      ,[SalesYTD]
      ,[SalesLastYear]
      ,[CostYTD]
      ,[CostLastYear]
      ,[rowguid]
      ,[ModifiedDate]
FROM AdventureWorks2019.[Sales].[SalesTerritory]
WHERE TerritoryID IN (
		SELECT DISTINCT TerritoryID
		FROM Sales.SalesOrderHeader
) OR TerritoryID IN (
		SELECT DISTINCT TerritoryID
		FROM Sales.Customer
)
SET IDENTITY_INSERT [Sales].[SalesTerritory] OFF
GO

----- Sales.Store
INSERT INTO [Sales].[Store]
           ([BusinessEntityID]
           ,[Name]
           ,[SalesPersonID]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [BusinessEntityID]
      ,[Name]
      ,[SalesPersonID]
      ,[rowguid]
      ,[ModifiedDate]
FROM AdventureWorks2019.[Sales].[Store]
WHERE BusinessEntityID IN (
	SELECT DISTINCT StoreID
	FROM Sales.Customer
)

--- Sales.SalesOrderDetail
SET IDENTITY_INSERT [Sales].[SalesOrderDetail] ON
GO
INSERT INTO [Sales].[SalesOrderDetail]
           ([SalesOrderID]
		   ,[SalesOrderDetailID]
           ,[CarrierTrackingNumber]
           ,[OrderQty]
           ,[ProductID]
           ,[SpecialOfferID]
           ,[UnitPrice]
           ,[UnitPriceDiscount]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [SalesOrderID]
	  ,[SalesOrderDetailID]
      ,[CarrierTrackingNumber]
      ,[OrderQty]
      ,[ProductID]
      ,[SpecialOfferID]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[rowguid]
      ,[ModifiedDate]
FROM AdventureWorks2019.[Sales].[SalesOrderDetail]
WHERE SalesOrderID IN (
	SELECT DISTINCT SalesOrderID
	FROM Sales.SalesOrderHeader
)
SET IDENTITY_INSERT [Sales].[SalesOrderDetail] OFF
GO

--------------- Production.Product
SET IDENTITY_INSERT [Production].[Product] ON
GO
INSERT INTO [Production].[Product]
           ([ProductID]
		   ,[Name]
           ,[ProductNumber]
           ,[MakeFlag]
           ,[FinishedGoodsFlag]
           ,[Color]
           ,[SafetyStockLevel]
           ,[ReorderPoint]
           ,[StandardCost]
           ,[ListPrice]
           ,[Size]
           ,[SizeUnitMeasureCode]
           ,[WeightUnitMeasureCode]
           ,[Weight]
           ,[DaysToManufacture]
           ,[ProductLine]
           ,[Class]
           ,[Style]
           ,[ProductSubcategoryID]
           ,[ProductModelID]
           ,[SellStartDate]
           ,[SellEndDate]
           ,[DiscontinuedDate]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [ProductID]
      ,[Name]
      ,[ProductNumber]
      ,[MakeFlag]
      ,[FinishedGoodsFlag]
      ,[Color]
      ,[SafetyStockLevel]
      ,[ReorderPoint]
      ,[StandardCost]
      ,[ListPrice]
      ,[Size]
      ,[SizeUnitMeasureCode]
      ,[WeightUnitMeasureCode]
      ,[Weight]
      ,[DaysToManufacture]
      ,[ProductLine]
      ,[Class]
      ,[Style]
      ,[ProductSubcategoryID]
      ,[ProductModelID]
      ,[SellStartDate]
      ,[SellEndDate]
      ,[DiscontinuedDate]
      ,[rowguid]
      ,[ModifiedDate]
FROM AdventureWorks2019.[Production].[Product]
WHERE ProductID IN (
	SELECT DISTINCT ProductID
	FROM Sales.SalesOrderDetail
)
SET IDENTITY_INSERT [Production].[Product] OFF
GO

------------- Production.ProductSubCategory
SET IDENTITY_INSERT [Production].[ProductSubCategory] ON
GO

INSERT INTO [Production].[ProductSubcategory]
           ([ProductSubCategoryID]
		   ,[ProductCategoryID]
           ,[Name]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [ProductSubcategoryID]
      ,[ProductCategoryID]
      ,[Name]
      ,[rowguid]
      ,[ModifiedDate]
FROM AdventureWorks2019.[Production].[ProductSubcategory]
WHERE ProductSubCategoryID IN (
	SELECT DISTINCT ProductSubcategoryID
	FROM Production.Product
)

SET IDENTITY_INSERT [Production].[ProductSubCategory] OFF
GO

---------------- Production.ProductCategory
SET IDENTITY_INSERT [Production].[ProductCategory] ON
GO
INSERT INTO [Production].[ProductCategory]
           ([ProductCategoryID]
		   ,[Name]
           ,[rowguid]
           ,[ModifiedDate])
SELECT [ProductCategoryID]
      ,[Name]
      ,[rowguid]
      ,[ModifiedDate]
FROM AdventureWorks2019.[Production].[ProductCategory]
WHERE ProductCategoryID IN (
	SELECT DISTINCT ProductCategoryID
	FROM Production.ProductSubCategory
)
SET IDENTITY_INSERT [Production].[ProductCategory] OFF
GO