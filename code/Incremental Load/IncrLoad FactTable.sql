/* FACT TABLE*/

USE [DataWareHouseAW3]
GO

/*		get LastLoadDate		*/
DECLARE @LastLoadDate datetime
SET @LastLoadDate = (SELECT [Date]
      FROM edw.DimDate
      WHERE D_ID in (
            SELECT MAX(LastLoadDate)
            FROM ETL.LogUpdate
            WHERE [Table]='FactSALES'
      )
)
/*The stage fact table is truncated and the content completely reloaded*/

TRUNCATE TABLE [stage].[FactSALES]
INSERT INTO [stage].[FactSALES]
           ([Customer_ID]
           ,[Product_ID]
           ,[Employee_ID]
           ,[Territory_ID]
           ,[OrderDate]
           ,[Order_ID]
           ,[Discount]
           ,[Quantity]
           ,[Total])
	SELECT 
      	SH.CustomerID,
      	SD.ProductID,
      	SH.SalesPersonID,
      	SH.TerritoryID,
      	SH.OrderDate,
            SH.SalesOrderID,
            SD.UnitPriceDiscount / SD.UnitPrice * 100 as [Discount],
      	SD.OrderQty,
      	SD.LineTotal
      FROM [TestAW].[Sales].SalesOrderHeader SH, [TestAW].[Sales].SalesOrderDetail SD
      WHERE SD.SalesOrderID = SH.SalesOrderID  AND SH.OrderDate > (@LastLoadDate) 
	  ---facts that took place after the last update
	  
GO

--		DATA CLEANING

UPDATE stage.FactSALES
SET Employee_ID = -1 
WHERE Employee_ID IS NULL
GO

--      KEY LOOKUP USING JUST CURRENTLY ACTIVE ROWS
UPDATE stage.FactSALES
	SET stage.FactSALES.P_ID = edw.DimPRODUCT.P_ID
	FROM edw.DimPRODUCT, stage.FactSALES
	WHERE stage.FactSALES.Product_ID = edw.DimPRODUCT.Product_ID  AND edw.DimPRODUCT.ValidTo = 99991231

UPDATE stage.FactSALES
	SET stage.FactSALES.E_ID = edw.DimEMPLOYEE.E_ID
	FROM edw.DimEMPLOYEE, stage.FactSALES
	WHERE stage.FactSALES.Employee_ID = edw.DimEMPLOYEE.Employee_ID AND edw.DimEMPLOYEE.ValidTo = 99991231

UPDATE stage.FactSALES
	SET stage.FactSALES.T_ID = edw.DimTERRITORY.T_ID
	FROM edw.DimTERRITORY, stage.FactSALES
	WHERE stage.FactSALES.Territory_ID = edw.DimTERRITORY.Territory_ID AND edw.DimTERRITORY.ValidTo = 99991231


UPDATE stage.FactSALES
	SET stage.FactSALES.D_ID = edw.DimDATE.D_ID
	FROM edw.DimDATE, stage.FactSALES
	WHERE stage.FactSALES.OrderDate = edw.DimDATE.[Date]

UPDATE stage.FactSALES
	SET stage.FactSALES.C_ID = edw.DimCUSTOMER.C_ID
	FROM edw.DimCUSTOMER, stage.FactSALES
	WHERE stage.FactSALES.Customer_ID = edw.DimCUSTOMER.Customer_ID AND edw.DimCUSTOMER.ValidTo = 99991231




--TRUNCATE TABLE [edw].[FactSALES]
INSERT INTO [edw].[FactSALES]
           ([C_ID]
           ,[P_ID]
           ,[E_ID]
           ,[T_ID]
           ,[D_ID]
           ,[Order_ID]
           ,[Discount]
           ,[Quantity]
           ,[Total])
SELECT [C_ID]
      ,[P_ID]
      ,[E_ID]
      ,[T_ID]
      ,[D_ID]
      ,[Order_ID]
      ,[Discount]
      ,[Quantity]
      ,[Total]
  FROM [stage].[FactSALES]

use DataWareHouseAW3
DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)
insert into ETL.LogUpdate("Table", "LastLoadDate") values ('FactSALES', @NewLoadDate)
GO
