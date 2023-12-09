/*
--=============================================================================
-- Load all of the state-level attribute files.  This will act as staging as we
-- will break them up into separate tables later in the process.
--=============================================================================
*/

DECLARE @CurSegment TINYINT
DECLARE @CurState CHAR(2)
DECLARE @DataPath VARCHAR(255) = 'Z:\Census_2020\Demographic_and_Housing_Characteristics_File\Data\States\'
DECLARE @File_Name VARCHAR(255)
DECLARE @FormatFilePath VARCHAR(255) = 'Z:\Census_2020\Demographic_and_Housing_Characteristics_File\Format_Files\'
DECLARE @FormatFile VARCHAR(255)
DECLARE @TableName VARCHAR(255)
DECLARE @SQL VARCHAR(MAX)
DECLARE @log_message VARCHAR(MAX)

--=============================================================================
-- Cycle through each state and then each segment (file) and use the proper 
-- format file to load into SQL
--=============================================================================
DECLARE stateCursor CURSOR FOR
	SELECT Abbr
	FROM Census_2020_DHC.dbo.lkpStates
	WHERE State_Code IS NOT NULL
	ORDER BY 1

OPEN stateCursor

FETCH NEXT FROM stateCursor 
INTO @CurState

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @log_message = 'Started ' + CONVERT( VARCHAR, @CurState ) + ' at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
	
	--=============================================================================
	-- For each state, cycle through each segment (file) and use the proper format 
	-- file to load into SQL
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
		SET @File_Name = LOWER( @CurState ) + '2020.dhc\' + LOWER( @CurState ) + '000' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 ) + '2020.dhc'
		SET @FormatFile = 'AttributeFile' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 ) + '.fmt'
		SET @TableName = 'Census_2020_DHC.dbo.' + @CurState + '_State_Attribute_Table_' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 )

	
		SET @log_message = 'Started loading ' + @CurState + ' segment: ' + CONVERT( VARCHAR, @CurSegment ) + ' at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
			RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
		SET @SQL = '
			IF OBJECT_ID( ''' + @TableName + ''' ) IS NOT NULL
				DROP TABLE ' + @TableName + '
			SELECT a.*
			INTO ' + @TableName + '
			FROM OPENROWSET(
				BULK ''' + @DataPath + @File_Name + '''
					, FORMATFILE = ''' + @FormatFilePath + @FormatFile + '''
					, MAXERRORS = 0
					, FIRSTROW = 1
			) a'
		EXEC( @SQL )

		FETCH NEXT FROM segmentCursor 
		INTO @CurSegment
	END

	CLOSE segmentCursor

	DEALLOCATE segmentCursor

	FETCH NEXT FROM stateCursor 
	INTO @CurState

END

CLOSE stateCursor

DEALLOCATE stateCursor