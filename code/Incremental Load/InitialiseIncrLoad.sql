USE [DataWareHouseAW3] ----------
GO

/* Handling changes */

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'etl')
BEGIN
  EXEC('CREATE SCHEMA [etl]');
END;
GO

/*creates log table*/
DROP TABLE IF EXISTS etl.LogUpdate;
CREATE TABLE etl."LogUpdate"(
	"Table" nvarchar(50) NULL,
	"LastLoadDate" int NULL   
)
GO
/*inserts last updates in the log table*/
INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('DimCUSTOMER',20140630)
INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('DimPRODUCT',20140630)
INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('DimTERRITORY',20140630)
INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('DimEMPLOYEE',20140630)
INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('FactSale',20140630)
GO
/*add new columns to dimensions*/
alter table edw.DimCUSTOMER
add ValidFrom int, ValidTo int

alter table edw.DimEMPLOYEE
add ValidFrom int, ValidTo int

alter table edw.DimPRODUCT
add ValidFrom int, ValidTo int

alter table edw.DimTERRITORY
add ValidFrom int, ValidTo int
GO


/*update new fields*/
update edw.DimCUSTOMER
set ValidFrom = 20110531, ValidTo = 99991231

update edw.DimEMPLOYEE
set ValidFrom = 20110531, ValidTo = 99991231

update edw.DimPRODUCT
set ValidFrom = 20110531, ValidTo = 99991231

update edw.DimTERRITORY
set ValidFrom = 20110531, ValidTo = 99991231

GO