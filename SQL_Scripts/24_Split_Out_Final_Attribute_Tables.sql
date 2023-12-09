/*
--=============================================================================
-- Need to break up the attribute tables into their individual tables
-- **This script will take multiple hours**
-- You can adjust the initial table cursor statement to restrict which tables
-- will be created
--=============================================================================
*/

DECLARE @curSegment TINYINT
DECLARE @curTableNumber VARCHAR(10)
DECLARE @curTableName VARCHAR(255)
DECLARE @TableName VARCHAR(255)
DECLARE @SQL_Beginning VARCHAR(MAX)
DECLARE @SQL_Beginning_Fields VARCHAR(MAX)
DECLARE @SQL_Fields VARCHAR(MAX)
DECLARE @SQL_Into VARCHAR(MAX)
DECLARE @SQL_From_National VARCHAR(MAX)
DECLARE @SQL_From_States VARCHAR(MAX)
DECLARE @SQL_Index VARCHAR(MAX)
DECLARE @SQL_Total VARCHAR(MAX)
DECLARE @log_message VARCHAR(MAX)
DECLARE @NEWLINE CHAR(1) = CHAR(13)

DECLARE tableCursor CURSOR FOR
	--=============================================================================
	-- Use the layout to cycle through all the tables that need to be created
	-- Need to remove special characters from the Title field so we can use that as
	-- the table name
	--=============================================================================
	SELECT
		Segment
		, TableNumber
		, Title =	REPLACE( 
						REPLACE( 
							REPLACE( 
								REPLACE( 
									REPLACE( 
										REPLACE( 
											REPLACE( 
												REPLACE( Title, ' ', '_' ) -- replaces spaces with underscores
												, ':', '_' ) -- replace colons with underscores
											, '(', '_' ) -- replace opening parenthesis with underscores
										, ')', '' ) -- Remove closing parenthesis - looks like only show up at the end so no need for underscore
									, '-', '_' ) -- replace dashes with underscores
								, '/', '_' ) -- replace slash with underscores
							, ',', '_' ) -- replace commas with underscores
						, '__', '_' ) -- replace any double underscores we created with a single underscore
	FROM Census_2020_DHC.dbo.layoutDHC2020
	GROUP BY
		Segment
		, TableNumber
		, REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( Title, ' ', '_' ), ':', '_' ), '(', '_' ), ')', '' ), '-', '_' ), '/', '_' ), ',', '_' ), '__', '_' )
	ORDER BY 1,2

OPEN tableCursor

FETCH NEXT FROM tableCursor
INTO @curSegment, @curTableNumber, @curTableName

WHILE @@FETCH_STATUS = 0
BEGIN
	--=============================================================================
	-- The table we're about to create
	-- Some Titles end up being too long so we take the left 128 characters
	-- Added in the table number prefix for multiple reasons:
	--		- Ease of lookup when referencing layout
	--		- Ensure table names are unique (esp with the 128 cutoff above)
	--		- Table ordering/grouping (although not the best...)
	--=============================================================================
	SET @TableName = 'Census_2020_DHC.dbo.' + LEFT( @curTableNumber + '_' + @curTableName, 128 )

	--=============================================================================
	-- Create the initial part of the SQL statement we're building that drops the
	-- table if it already exists
	--=============================================================================
	SET @SQL_Beginning = '
		IF OBJECT_ID( ''' + @TableName + ''' ) IS NOT NULL
			DROP TABLE ' + @TableName

	--=============================================================================
	-- All the tables should have these fields so we can join them to the GEO tables
	--=============================================================================
	SET @SQL_Beginning_Fields = '
		SELECT
			FILEID = CONVERT( CHAR(5), FILEID )
			, STUSAB = CONVERT( CHAR(2), STUSAB )
			, CIFSN = CONVERT( CHAR(2), CIFSN )
			, LOGRECNO = CONVERT( CHAR(7), LOGRECNO )'

	--=============================================================================
	-- Bring in the fields from the layout
	-- Need to clean up the field name in the layout to remove weird characters since
	-- we'll be using that name to name each column
	--=============================================================================
	SELECT
		@SQL_Fields = COALESCE( @SQL_Fields, '' )
			+ '	, '
			-- prefix the field with the ReferenceName to ensure uniqueness
			-- also need the left 128 characters due to length restrictions
			+ LEFT( ReferenceName + '_'
			+ REPLACE( 
				REPLACE( 
					REPLACE( 
						REPLACE( 
							REPLACE( 
								REPLACE( 
									REPLACE( 
										REPLACE( 
											REPLACE( 
												REPLACE( 
													REPLACE( Field, ' ', '_' ) -- replace spaces with an underscore
													, '''', '' ) -- remove quotes
												, ':', '' ) -- remove colons
											, ';', '' ) -- remove semicolons
										, CHAR(160), '_' ) -- weird character that looked like a space that showed up in a few field names in the layout - replace with an underscore
									, '(', '_' ) -- replace opening parenthesis with an underscore
								, ')', '' ) -- remove closing parenthesis
							, '-', '_' ) -- replace dash with an underscore
						, '/', '_' ) -- replace slash with an underscore
					, ',', '_' ) -- replace commma with an underscore
				, '__', '_' ) -- replace any double underscores with just a single underscore
			, 128 )  -- Closing piece of the LEFT(128) statement
			+ ' = CONVERT( '
			-- Median age fields show up as decimal values, everything else are INT
			+ CASE WHEN LOWER(Title) LIKE 'median age%' THEN 'DECIMAL( 7, 2 )' ELSE 'INT' END
			-- Some fields have values of just a period, we'll NULL these out
			+', LTRIM( RTRIM( NULLIF( ['
			+ ReferenceName
			+ '], ''.'' ) ) ) )'
			+ @NEWLINE
	FROM Census_2020_DHC.dbo.layoutDHC2020
	WHERE Segment = @curSegment
		AND TableNumber = @curTableNumber
	ORDER BY Table_Field_Num ASC

	--=============================================================================
	-- The final pieces of our SQL statement that we're building
	--=============================================================================
	SET @SQL_Into = 'INTO ' + @TableName
	SET @SQL_From_National = 'FROM Census_2020_DHC.dbo.US_Attribute_Table_' + RIGHT( '00' + CONVERT( VARCHAR, @curSegment ), 2 )
	SET @SQL_From_States = 'FROM Census_2020_DHC.dbo.Combined_State_Attribute_Table_' + RIGHT( '00' + CONVERT( VARCHAR, @curSegment ), 2 )
	SET @SQL_Index = 'CREATE UNIQUE CLUSTERED INDEX UC_IDX ON ' + @TableName + '( FILEID, STUSAB, LOGRECNO )'

	--=============================================================================
	-- Build the whole SQL statement for this table
	--	Drop the table if it exists
	--  SELECT our standard fields + table specific fields INTO new table FROM our state attribute table
	--  UNION ALL
	--  SELECT our standard fields + table specific fields FROM our national attribute table
	-- While we're here:
	--  CREATE clustered index on the table using the fields most likely to be joined on
	--=============================================================================
	SET @SQL_Total = 
		@SQL_Beginning
		+ @SQL_Beginning_Fields
		+ @NEWLINE
		+ @SQL_Fields
		+ @SQL_Into
		+ @NEWLINE
		+ @SQL_From_National
		+ @NEWLINE
		+ @NEWLINE
		+ 'UNION ALL'
		+ @NEWLINE
		+ @SQL_Beginning_Fields
		+ @NEWLINE
		+ @SQL_Fields
		+ @SQL_From_States
		+ @NEWLINE
		+ @SQL_Index

	SET @log_message = 'Creating table: ' + @TableName + '. Started at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
	--PRINT( @SQL_Total )
	EXEC( @SQL_Total )

	--=============================================================================
	-- Reset all of our SQL statement variables (just to be sure)
	-- The only one that really needs this is @SQL_Fields, but just wanted to
	-- put this all here for completness and just to ensure everything gets cleared
	-- and nothing strange happens.
	--=============================================================================
	SET @SQL_Beginning = NULL
	SET @SQL_Beginning_Fields = NULL
	SET @SQL_Fields = NULL
	SET @SQL_From_National = NULL
	SET @SQL_From_States = NULL
	SET @SQL_Into = NULL
	SET @SQL_Total = NULL
	SET @SQL_Index = NULL

	FETCH NEXT FROM tableCursor
	INTO @curSegment, @curTableNumber, @curTableName
END

CLOSE tableCursor

DEALLOCATE tableCursor

--=============================================================================
-- Double check all the tables were created
--=============================================================================
SELECT *
FROM 
(
	SELECT
		TABLE_NAME = LEFT( TableNumber + '_' + REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( Title, ' ', '_' ), ':', '_' ), '(', '_' ), ')', '' ), '-', '_' ), '/', '_' ), ',', '_' ), '__', '_' ), 128 )
	FROM Census_2020_DHC.dbo.layoutDHC2020
	GROUP BY
		LEFT( TableNumber + '_' + REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( Title, ' ', '_' ), ':', '_' ), '(', '_' ), ')', '' ), '-', '_' ), '/', '_' ), ',', '_' ), '__', '_' ), 128 )
) a
LEFT JOIN
(
	SELECT
		TABLE_NAME
	FROM Census_2020_DHC.INFORMATION_SCHEMA.TABLES
	GROUP BY TABLE_NAME
) b
	ON a.TABLE_NAME = b.TABLE_NAME
WHERE b.TABLE_NAME IS NULL

