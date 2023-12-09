--=============================================================================
-- Cursor to cycle through all of the states and dynamically build the SQL 
-- statement to load their geography tables into SQL.  Each state has its
-- own geography table.
--=============================================================================
DECLARE @SQL VARCHAR(MAX)
DECLARE @stateAbbr CHAR(2)
DECLARE @log_message VARCHAR(MAX)
DECLARE @PROJ_DIR VARCHAR(255) = 'Z:\Census_2020\Demographic_and_Housing_Characteristics_File\'

DECLARE state_cursor CURSOR FOR
SELECT Abbr
FROM [Census_2020_DHC].[dbo].[lkpStates]
WHERE Abbr NOT IN( 'AS', 'GU', 'VI', 'MP' )
ORDER BY 1

OPEN state_cursor

FETCH NEXT FROM state_cursor
INTO @stateAbbr

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @log_message = 'Beginning ' + @stateAbbr + ' at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
	SET @SQL = '
	IF OBJECT_ID( ''Census_2020_DHC.dbo.DHC2020_State_' + @stateAbbr + '_GEO'' ) IS NOT NULL
		DROP TABLE Census_2020_DHC.dbo.DHC2020_State_' + @stateAbbr + '_GEO
	SELECT a.*
	INTO Census_2020_DHC.dbo.DHC2020_State_' + @stateAbbr + '_GEO
	FROM OPENROWSET(
		BULK ''' + @PROJ_DIR + 'Data\States\' + @stateAbbr + '2020.dhc\' + @stateAbbr + 'geo2020.dhc''
			, FORMATFILE = ''' + @PROJ_DIR + 'Format_Files\DHC2020_Geo_Layout.fmt''
			, MAXERRORS = 0
			, FIRSTROW = 1
	) a'

	EXEC( @SQL )


	FETCH NEXT FROM state_cursor
	INTO @stateAbbr
END

CLOSE state_cursor

DEALLOCATE state_cursor


