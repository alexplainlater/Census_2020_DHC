/*
--=============================================================================
-- Combine state attribute tables
-- For each segment (file/table #), union all records from every state into a
-- combined state attribute table.  Add a clustered index on the combined table
--=============================================================================
*/

DECLARE @NEWLINE CHAR = CHAR(13)
DECLARE @CurSegment TINYINT
DECLARE @SQL VARCHAR(MAX)
DECLARE @log_message VARCHAR(MAX)

--=============================================================================
-- Cycle through each segment (file/table #)
--=============================================================================
DECLARE segmentCursor CURSOR FOR
	SELECT Segment
	FROM [Census_2020_DHC].[dbo].[layoutDHC2020]
	GROUP BY Segment
	ORDER BY 1

OPEN segmentCursor

FETCH NEXT FROM segmentCursor 
INTO @CurSegment

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @log_message = 'Creating SQL statement for segment: ' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 ) + '. Started at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT

	--=============================================================================
	-- Create a temporary table to hold all the state table names for the current 
	-- segment.  Add a row number so we know which table is first and which is last
	-- That way we can modify the SQL statement generation
	--=============================================================================
	IF OBJECT_ID( 'tempdb..#tmp' ) IS NOT NULL
		DROP TABLE #tmp
	SELECT TABLE_NAME
		, RN = ROW_NUMBER() OVER( ORDER BY TABLE_NAME )
	INTO #tmp
	FROM Census_2020_DHC.INFORMATION_SCHEMA.TABLES
	WHERE TABLE_NAME LIKE '%State_Attribute_Table_' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 )
	ORDER BY TABLE_NAME
	
	--=============================================================================
	-- Generate the SELECT-INTO statement that UNIONs all of the state tables together
	-- The CASE statements allow us to add the additional statements (DROP table if 
	-- it exists and the INTO piece) for the first table and exclude the UNION ALL 
	-- after the last table.
	--=============================================================================
	SELECT @SQL = COALESCE( @SQL, '' ) 
		+ CASE 
			WHEN RN = (SELECT MIN(RN) FROM #tmp) THEN 
				'IF OBJECT_ID( ''Census_2020_DHC.dbo.Combined_State_Attribute_Table_' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 ) + ''' ) IS NOT NULL'
				+ @NEWLINE
				+ 'DROP TABLE Census_2020_DHC.dbo.Combined_State_Attribute_Table_' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 )
				+ @NEWLINE
				+ 'SELECT *'
				+ @NEWLINE
				+ 'INTO Census_2020_DHC.dbo.Combined_State_Attribute_Table_' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 )
				+ @NEWLINE
				+ 'FROM Census_2020_DHC.dbo.' + TABLE_NAME 
			ELSE
				'SELECT *'
				+ @NEWLINE
				+ 'FROM Census_2020_DHC.dbo.' + TABLE_NAME 
			END
		+ @NEWLINE 
		+ CASE 
			WHEN RN = (SELECT MAX(RN) FROM #tmp) THEN ''
			ELSE
				' UNION ALL' 
			END
		+ @NEWLINE
	FROM #tmp
	ORDER BY TABLE_NAME

	--=============================================================================
	-- Execute the SQL statement that was generated
	--=============================================================================
	SET @log_message = 'Executing SQL statement for segment: ' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 ) + '. Started at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
	--PRINT( @SQL )
	EXEC( @SQL )

	--=============================================================================
	-- Reset variables
	--=============================================================================
	DROP TABLE #tmp
	SET @SQL = NULL

	FETCH NEXT FROM segmentCursor 
	INTO @CurSegment
END

CLOSE segmentCursor

DEALLOCATE segmentCursor