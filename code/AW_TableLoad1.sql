
--			LOAD DATA INTO THE STAGE DIMENSIONS

--		CUSTOMER DIMENSION
USE [DataWareHouseAW]
GO
TRUNCATE TABLE stage.DimCUSTOMER

--	PEOPLE
INSERT INTO stage.DimCUSTOMER
           (Customer_ID
           ,FirstName
           ,LastName,
		   CType)

SELECT 
	C.CustomerID,
	P.FirstName,
	P.LastName,
	'IN'
	
	FROM AdventureWorks2019.Sales.Customer C, AdventureWorks2019.Person.Person P
	WHERE C.PersonID = P.BusinessEntityID AND C.StoreID IS NULL
GO

--	STORES
INSERT INTO stage.DimCUSTOMER
           (Customer_ID
           ,FullName
		   ,CType)

SELECT 
	C.CustomerID,
	S.Name,
	'ST'

	FROM AdventureWorks2019.Sales.Customer C, AdventureWorks2019.Sales.Store S
	WHERE C.StoreID = S.BusinessEntityID
GO

--		PRODUCT DIMENSION
TRUNCATE TABLE stage.DimPRODUCT
INSERT INTO stage.DimPRODUCT
           (Product_ID
           ,PName
           ,Category)
SELECT 
			P.ProductID,
			P.Name,
			PC.Name

FROM AdventureWorks2019.Production.Product P, AdventureWorks2019.Production.ProductSubCategory PSC, AdventureWorks2019.Production.ProductCategory PC
WHERE P.ProductSubcategoryID = PSC.ProductSubcategoryID AND PSC.ProductcategoryID = PC.ProductcategoryID
GO

--		EMPLOYEE DIMENSION
TRUNCATE TABLE stage.DimEMPLOYEE
INSERT INTO stage.DimEMPLOYEE
           (Employee_ID
		   ,FirstName
		   ,LastName
           ,BirthDate
           ,Gender
		   ,Title)
SELECT 
	E.BusinessEntityID,
	P.FirstName,
	P.LastName,
	E.BirthDate,
	E.Gender,
	E.JobTitle

FROM  AdventureWorks2019.HumanResources.Employee E, AdventureWorks2019.Person.Person P
WHERE E.BusinessEntityID = P.BusinessEntityID
GO

--		TERRITORY DIMENSION
TRUNCATE TABLE stage.DimTERRITORY
INSERT INTO stage.DimTERRITORY
           (Territory_ID
		   ,TName
           ,CountryCode
           ,Region)
SELECT 
	TerritoryID,
	Name,
	CountryRegionCode,
	[Group]
FROM AdventureWorks2019.Sales.SalesTerritory
GO


--			UPDATE STAGE DIMENSIONS

UPDATE stage.DimCUSTOMER
SET FullName = CONCAT(FirstName, ' ' , LastName)
WHERE Ctype='IN'


--			UPDATE EMPLOYEE DIMENSIONS

UPDATE stage.DimEMPLOYEE
SET FullName = CONCAT(FirstName, ' ', LastName),
	Age = DATEDIFF(hour, BirthDate, GETDATE())/8766

--			LOAD STAGE DIMENSIONS INTO EDW

--		CUSTOMER DIMENSION

INSERT INTO edw.DimCUSTOMER
           (Customer_ID
           ,FullName
		   ,CType)
SELECT 
	Customer_ID
    ,FullName
	,CType
FROM stage.DimCUSTOMER
GO

--		PRODUCT DIMENSION


INSERT INTO edw.DimPRODUCT
           (Product_ID
           ,PName
           ,Category)
SELECT 
	Product_ID
    ,PName
    ,Category
FROM stage.DimPRODUCT
GO

--		EMPLOYEE DIMENSION
INSERT INTO edw.DimEMPLOYEE
           (Employee_ID
		   ,FullName
		   ,Age
           ,Gender
		   ,Title)
SELECT 
	Employee_ID
	,FullName
    ,Age
    ,Gender
	,Title
FROM stage.DimEMPLOYEE
GO

--		TERRITORY DIMENSION

INSERT INTO edw.DimTERRITORY
           (Territory_ID
		   ,TName
           ,CountryCode
           ,Region)
SELECT 
	Territory_ID
	,TName
    ,CountryCode
    ,Region
FROM stage.DimTERRITORY
GO


--			LOAD STAGE FACT TABLE

USE [DataWareHouseAW]
GO
TRUNCATE TABLE stage.FactSALES
INSERT INTO stage.FactSALES
           (Customer_ID
           ,Product_ID
           ,Employee_ID
           ,Territory_ID
           ,OrderDate
		   ,Order_ID
           ,Discount
		   ,Quantity
		   ,Total)
SELECT 
			SH.CustomerID,
			SD.ProductID,
			SH.SalesPersonID,
			SH.TerritoryID,
			SH.OrderDate,
			SH.SalesOrderID,
			SD.UnitPriceDiscount/SD.UnitPrice*100 as Discount,
			SD.OrderQty,
			SD.LineTotal
FROM AdventureWorks2019.Sales.SalesOrderDetail SD, AdventureWorks2019.Sales.SalesOrderHeader SH
WHERE SD.SalesOrderID = SH.SalesOrderID
GO

--		DATA CLEANSING

UPDATE stage.FactSALES
SET Employee_ID = -1 
WHERE Employee_ID IS NULL

INSERT INTO edw.DimEMPLOYEE
           (Employee_ID
		   ,FullName
		   ,Age
           ,Gender
		   ,Title)
VALUES (-1, 'ONLINE', -1, 'O', 'Unknown')

--		KEY LOOKUP

UPDATE stage.FactSALES
SET C_ID = (
	SELECT C_ID
	FROM edw.DimCUSTOMER
	WHERE stage.FactSALES.Customer_ID = edw.DimCUSTOMER.Customer_ID
)


UPDATE stage.FactSALES
SET P_ID = (
	SELECT P_ID
	FROM edw.DimPRODUCT
	WHERE stage.FactSALES.Product_ID = edw.DimPRODUCT.Product_ID
)

UPDATE stage.FactSALES
SET E_ID = (
	SELECT E_ID
	FROM edw.DimEMPLOYEE
	WHERE stage.FactSALES.Employee_ID = edw.DimEMPLOYEE.Employee_ID
)

UPDATE stage.FactSALES
SET T_ID = (
	SELECT T_ID
	FROM edw.DimTERRITORY
	WHERE stage.FactSALES.Territory_ID = edw.DimTERRITORY.Territory_ID
)

UPDATE stage.FactSALES
SET D_ID = (
	SELECT D_ID
	FROM edw.DimDATE
	WHERE stage.FactSALES.OrderDate = edw.DimDATE.[Date]
)

--			INSERT FACT TABLE FROM STAGE TO EDW
INSERT INTO edw.FactSALES
           (C_ID
           ,P_ID
           ,E_ID
           ,T_ID
           ,D_ID
		   ,Order_ID
           ,Discount
		   ,Quantity
		   ,Total)
SELECT C_ID
      ,P_ID
      ,E_ID
      ,T_ID
      ,D_ID
	  ,Order_ID
      ,Discount
	  ,Quantity
	  ,Total
  FROM stage.FactSALES

GO

