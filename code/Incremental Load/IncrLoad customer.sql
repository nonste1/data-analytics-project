USE [DataWareHouseAW] ----------
GO

/* Handling changes */

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'etl')
BEGIN
  EXEC('CREATE SCHEMA [etl]');
END;
GO

DROP TABLE IF EXISTS etl.LogUpdate;
CREATE TABLE etl."LogUpdate"(
	"Table" nvarchar(50) NULL,
	"LastLoadDate" int NULL
)

INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('DimCUSTOMER',20140630)
INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('DimPRODUCT',20140630)
INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('DimTERRITORY',20140630)
INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('DimEMPLOYEE',20140630)
INSERT INTO etl.LogUpdate ([Table],[LastLoadDate]) VALUES ('FactSale',20140630)

alter table edw.DimCUSTOMER
add ValidFrom int, ValidTo int

alter table edw.DimEMPLOYEE
add ValidFrom int, ValidTo int

alter table edw.DimPRODUCT
add ValidFrom int, ValidTo int

alter table edw.DimTERRIROTY
add ValidFrom int, ValidTo int


update edw.DimCUSTOMER
set ValidFrom = 20110531, ValidTo = 99991231

update edw.DimEMPLOYEE
set ValidFrom = 20110531, ValidTo = 99991231

update edw.DimPRODUCT
set ValidFrom = 20110531, ValidTo = 99991231

update edw.DimTERRITORY
set ValidFrom = 20110531, ValidTo = 99991231



/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimCUSTOMER')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231

/*	start get added customers	*/
INSERT INTO [edw].[DimCUSTOMER]
           ([Customer_ID]
           ,[CType]
           ,[FullName]
           ,[ValidFrom]
           ,[ValidTo])
     
	SELECT  [Customer_ID]
           ,[CType]
           ,[FullName]
		   		 ,@NewLoadDate
		   		 ,@FutureDate
	FROM stage.DimCUSTOMER
	WHERE Customer_ID in (
			SELECT Customer_ID
			FROM stage.DimCUSTOMER
			EXCEPT
					SELECT Customer_ID FROM edw.DimCUSTOMER
					WHERE ValidTo=99991231
	)


INSERT INTO ETL."LogUpdate" ("Table", "LastLoadDate") VALUES ('DimCUSTOMER', @NewLoadDate)
go


/*	stop */


/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimCUSTOMER')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231

/*	start get changed  customers	*/
drop table if exists #tmp

SELECT [Customer_ID]
      ,[CType]
      ,[FullName]
INTO #tmp
FROM (
    SELECT [Customer_ID]
          ,[CType]
          ,[FullName]
    FROM [stage].[DimCUSTOMER] ---today
    EXCEPT
    SELECT [Customer_ID]
          ,[CType]
          ,[FullName]
    FROM [edw].[DimCUSTOMER] --yesterday
    WHERE ValidTo=99991231
) CHANGES
WHERE CHANGES.Customer_ID NOT IN (
    SELECT [Customer_ID]
    FROM [stage].[DimCUSTOMER] --today
    EXCEPT
    SELECT [Customer_ID]
    FROM [edw].[DimCUSTOMER]    --yesterday
    WHERE ValidTo=99991231
)
INSERT INTO [edw].[DimCUSTOMER]
           ( [Customer_ID]
						,[CType]
						,[Name]
			      ,[ValidFrom]
			      ,[ValidTo])
     
	SELECT  [Customer_ID]
				 ,[CType]
				 ,[FullName]
				 ,@NewLoadDate
				 ,@FutureDate
		FROM #tmp

update edw.DimCUSTOMER
set ValidTo = @NewLoadDate-1
where Customer_ID in (select Customer_ID from #tmp)
	and edw.DimCUSTOMER.ValidFrom<@NewLoadDate

drop table if exists #tmp

insert into etl.LogUpdate("Table", "LastLoadDate") values ('DimCUSTOMER', @NewLoadDate)
go

/*	stop */


/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimCUSTOMER')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231


/*	start get deleted	customers */

update edw.DimCUSTOMER
set ValidTo = @NewLoadDate-1
where Customer_ID in (select Customer_ID
					  from edw.DimCUSTOMER
					  where Customer_ID in (select Customer_ID
											from edw.DimCUSTOMER
											except
											select Customer_ID
											from stage.DimCUSTOMER))
					  and ValidTo=99991231

insert into etl.LogUpdate("Table", "LastLoadDate") values ('DimCUSTOMER', @NewLoadDate)
go

/* stop */