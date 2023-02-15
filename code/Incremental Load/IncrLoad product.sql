USE [DataWareHouseAW] ------
GO

/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl.LogUpdate WHERE Table = 'DimPRODUCT')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231

/* start get added products */
INSERT INTO [edw].[DimPRODUCT]
           ([Product_ID]
           ,[PName]
           ,[Category]
           ,[ValidFrom]
           ,[ValidTo])
     
	SELECT  [Product_ID]
           ,[PName]
           ,[Category]
		   ,@NewLoadDate
		   ,@FutureDate
	FROM stage.DimPRODUCT
	WHERE Product_ID in (SELECT Product_ID
						  FROM stage.DimPRODUCT
						  EXCEPT
						  SELECT Product_ID FROM edw.DimPRODUCT
						  WHERE ValidTo=99991231)


INSERT INTO ETL."LogUpdate" ("Table", "LastLoadDate") VALUES ('DimPRODUCT', @NewLoadDate)
go
/*	stop */


/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimPRODUCT')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231

/*	start get changed products */
drop table if exists #tmp

SELECT [Product_ID]
      ,[PName]
      ,[Category]
INTO #tmp
FROM (
    SELECT [Product_ID]
          ,[PName]
          ,[Category]
    FROM [stage].[DimPRODUCT]
    EXCEPT
    SELECT [Product_ID]
          ,[PName]
          ,[Category]
    FROM [edw].[DimPRODUCT]
    WHERE ValidTo=99991231
) CHANGES
WHERE CHANGES.Product_ID NOT IN (
    SELECT [Product_ID]
    FROM [stage].[DimPRODUCT]
    EXCEPT
    SELECT [Product_ID]
    FROM [edw].[DimPRODUCT]
    WHERE ValidTo=99991231
)
INSERT INTO [edw].[DimPRODUCT]
           ([Product_ID]
           ,[PName]
           ,[Category]
           ,[ValidFrom]
           ,[ValidTo])
     
SELECT   [Product_ID]
        ,[PName]
        ,[Category]
		,@NewLoadDate
		,@FutureDate
FROM #tmp

update edw.DimPRODUCT
set ValidTo = @NewLoadDate-1
where Product_ID in (select Product_ID from #tmp)
	and edw.DimPRODUCT.ValidFrom<@NewLoadDate

drop table if exists #tmp

insert into etl.LogUpdate("Table", "LastLoadDate") values ('DimPRODUCT', @NewLoadDate)
go

/*	stop */


/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimPRODUCT')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231


/*	start get deleted products */


update edw.DimPRODUCT
set ValidTo = @NewLoadDate-1
where Product_ID in (
	  select Product_ID
	  from edw.DimPRODUCT
	  where Product_ID in (
	  	  select Product_ID
		  from edw.DimPRODUCT
		  except
			  select Product_ID
			  from stage.DimPRODUCT
		  )
	  )
	  and ValidTo=99991231

insert into etl.LogUpdate("Table", "LastLoadDate") values ('DimPRODUCT', @NewLoadDate)
go