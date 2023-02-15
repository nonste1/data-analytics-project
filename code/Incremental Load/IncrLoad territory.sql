USE [DataWareHouseAW] ---------
GO


/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimTERRITORY')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231

/*	start get added territories	*/
INSERT INTO [edw].[DimTERRITORY]
           ([Territory_ID]
           ,[TName]
           ,[CountryCode]
           ,[Region]
           ,[ValidFrom]
           ,[ValidTo])
     
	SELECT  [Territory_ID]
           ,[TName]
           ,[CountryCode]
           ,[Region]
    		   ,@NewLoadDate
    		   ,@FutureDate
	FROM stage.DimTERRITORY
	WHERE Territory_ID in (SELECT Territory_ID
						  FROM stage.DimTERRITORY
						  EXCEPT             ---new business keys
						  SELECT Territory_ID FROM edw.DimTERRITORY
						  WHERE ValidTo=99991231)

INSERT INTO ETL."LogUpdate" ("Table", "LastLoadDate") VALUES ('DimTERRITORY', @NewLoadDate)
go
/*	stop */



/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimTERRITORY')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231

/*	start get changed	territories */
SELECT [Territory_ID]
      ,[TName]
      ,[CountryCode]
      ,[Region]
INTO #tmp
FROM (
    SELECT [Territory_ID]
          ,[TName]
          ,[CountryCode]
          ,[Region]
    FROM [stage].[DimTERRITORY]
    EXCEPT                               ------all the new and changed rows
    SELECT [Territory_ID]
          ,[TName]
          ,[CountryCode]
          ,[Region]
    FROM [edw].[DimTERRITORY]
    WHERE ValidTo=99991231
) CHANGES
WHERE CHANGES.Territory_ID NOT IN (
    SELECT Territory_ID
    FROM [stage].[DimTERRITORY]
    EXCEPT     ---new business keysz
    SELECT Territory_ID
    FROM [edw].[DimTERRITORY]
    WHERE ValidTo=99991231
)
INSERT INTO [edw].[DimTERRITORY]
           ([Territory_ID]
           ,[TName]
           ,[CountryCode]
           ,[Region]
           ,[ValidFrom]
           ,[ValidTo])
		SELECT
			  [Territory_ID]
		   ,[TName]
       ,[CountryCode]
		   ,[Region]
		   ,@NewLoadDate
		   ,@FutureDate
		FROM #tmp

update edw.DimTERRITORY
set ValidTo = @NewLoadDate-1
where Territory_ID in (select Territory_ID from #tmp)
  and edw.DimTERRITORY.ValidFrom<@NewLoadDate

drop table if exists #tmp

insert into etl.LogUpdate("Table", "LastLoadDate") values ('DimTERRITORY', @NewLoadDate)
go

/* stop */



/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimTERRITORY')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231


/*	start get deleted	territories */

update edw.DimTERRITORY
set ValidTo = @NewLoadDate-1
where Territory_ID in (select Territory_ID
					  from edw.DimTERRITORY
					  where Territory_ID in (select Territory_ID
											from edw.DimTERRITORY
											except              ---deleted business keys
											select Territory_ID
											from stage.DimTERRITORY))
					  and ValidTo=99991231

insert into etl.LogUpdate("Table", "LastLoadDate") values ('DimTERRITORY', @NewLoadDate)
go

/*	stop */