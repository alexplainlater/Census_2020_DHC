--=============================================================================
-- Create the SQL statement to drop all the intermediary attribute tables
--=============================================================================
DECLARE @SQL VARCHAR(MAX)
DECLARE @log_message VARCHAR(MAX)

SET @log_message = 'Creating SQL statement to drop all intermediary attribute tables. Started at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
	RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
SELECT 
	@SQL = COALESCE( @SQL, '' )
		+ 'DROP TABLE Census_2020_DHC.dbo.' + TABLE_NAME
		+ CHAR(13)
FROM Census_2020_DHC.INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE 'Combined_State_Attribute_Table_%'
	OR TABLE_NAME LIKE 'US_Attribute_Table_%'
ORDER BY TABLE_NAME

SET @log_message = 'Dropping all intermediary attribute tables. Started at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
	RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
--PRINT( @SQL )
EXEC( @SQL )

--=============================================================================
-- Shrink the database to free up the unneeded space, leaving 1% free space
--=============================================================================
SET @log_message = 'Shrinking the database to free up the unneeded space. Started at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
	RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
DBCC SHRINKDATABASE( Census_2020_DHC, 1 )