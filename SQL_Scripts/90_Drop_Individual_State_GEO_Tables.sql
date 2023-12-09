--=============================================================================
-- Remove (clean up) all of the individual state tables
-- Dynamically create and execute the code to remove each individual state table.
--=============================================================================

DECLARE @SQL VARCHAR(MAX)
DECLARE @tableName VARCHAR(50)
DECLARE @log_message VARCHAR(MAX)

DECLARE tbl_cursor CURSOR FOR
SELECT TABLE_NAME
FROM Census_2020_DHC.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'DHC2020_State%'

OPEN tbl_cursor

FETCH NEXT FROM tbl_cursor
INTO @tableName

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @log_message = 'Dropping ' + @tableName + ' at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
	
	SET @SQL = 'DROP TABLE Census_2020_DHC.dbo.' + @tableName

	EXEC( @SQL )

	FETCH NEXT FROM tbl_cursor
	INTO @tableName
END

CLOSE tbl_cursor

DEALLOCATE tbl_cursor

--=============================================================================
-- Remove the view we created that combined all of the state tables
--=============================================================================
GO

USE Census_2020_DHC

GO

DROP VIEW dbo.vwDHC2020_GEO_ALL