USE [DataWareHouseAW] --------
GO

/* declare variables */
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimEMPLOYEE')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231

/*	start get added employees */


INSERT INTO [edw].[DimEMPLOYEE]
           ([Employee_ID]
           ,[FullName]
           ,[BirthDate]
	     ,[Gender]
	     ,[Title]
           ,[ValidFrom]
           ,[ValidTo])
     
	SELECT  [Employee_ID]
             ,[FullName]
             ,[BirthDate]
	       ,[Gender]
	       ,[Title]
		 ,@NewLoadDate
		 ,@FutureDate
	FROM stage.DimEMPLOYEE
	WHERE Employee_ID in (
		SELECT Employee_ID
		  FROM stage.DimEMPLOYEE
		  EXCEPT
			  SELECT Employee_ID FROM edw.DimEMPLOYEE
			  WHERE ValidTo=99991231
		  )


INSERT INTO ETL."LogUpdate" ("Table", "LastLoadDate") VALUES ('DimEMPLOYEE', @NewLoadDate)
go
/* stop */



/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimEMPLOYEE')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231

/*	start get changed	employees */
drop table if exists #tmp

SELECT [Employee_ID]
      ,[FullName]
      ,[BirthDate]
      ,[Gender]
      ,[Title]
FROM (
    SELECT [Employee_ID]
          ,[FullName]
          ,[BirthDate]
          ,[Gender]
          ,[Title]
    FROM [stage].[DimEMPLOYEE]
    EXCEPT
    SELECT [Employee_ID]
          ,[FullName]
          ,[BirthDate]
          ,[Gender]
          ,[Title]
    FROM [edw].[DimEMPLOYEE]
    WHERE ValidTo=99991231
) CHANGES
WHERE CHANGES.Employee_ID NOT IN (
    SELECT Employee_ID
    FROM [stage].[DimEMPLOYEE]
    EXCEPT
    SELECT Employee_ID
    FROM [edw].[DimEMPLOYEE]
    WHERE ValidTo=99991231
)
INSERT INTO [edw].[DimEMPLOYEE]
           ([Employee_ID]
           ,[FullName]
           ,[BirthDate]
	     ,[Gender]
	     ,[Title]
           ,[ValidFrom]
           ,[ValidTo])
     
	SELECT  [Employee_ID]
             ,[FullName]
             ,[BirthDate]
		 ,[Gender]
	       ,[Title]
             ,[ValidFrom]
             ,[ValidTo]
		 ,@NewLoadDate
		 ,@FutureDate
	FROM #tmp

update edw.DimEMPLOYEE
set ValidTo = @NewLoadDate-1
where Employee_ID in (select Employee_ID from #tmp) and edw.DimEMPLOYEE.ValidFrom<@NewLoadDate

drop table if exists #tmp

insert into etl.LogUpdate("Table", "LastLoadDate") values ('DimEMPLOYEE', @NewLoadDate)
go

/* stop */



/*		declare variables		*/
DECLARE @LastLoadDate int
SET @LastLoadDate = (SELECT MAX([LastLoadDate]) FROM etl."LogUpdate" WHERE "Table" = 'DimEMPLOYEE')

DECLARE @NewLoadDate int
SET @NewLoadDate = CONVERT(CHAR(8), GETDATE(), 112)

DECLARE @FutureDate int
SET @FutureDate = 99991231


/*	start get deleted	employees */

update edw.DimEMPLOYEE
set ValidTo = @NewLoadDate-1
where Employee_ID in (
	select Employee_ID
	  from edw.DimEMPLOYEE
	  where Employee_ID in (
	  	select Employee_ID
		from edw.DimEMPLOYEE
		except
		select Employee_ID
		from stage.DimEMPLOYEE
		)
	  )
	  and ValidTo=99991231

insert into etl.LogUpdate("Table", "LastLoadDate") values ('DimEMPLOYEE', @NewLoadDate)
go

/* stop */