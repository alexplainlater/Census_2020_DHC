DECLARE @CurSegment TINYINT
DECLARE @CurState CHAR(2)
DECLARE @TableName VARCHAR(255)
DECLARE @SQL VARCHAR(MAX)
DECLARE @log_message VARCHAR(MAX)

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
		SET @TableName = 'Census_2020_DHC.dbo.' + @CurState + '_State_Attribute_Table_' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 )

		SET @log_message = 'Dropping table: ' + @TableName + ' at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
			RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
		SET @SQL = '
			IF OBJECT_ID( ''' + @TableName + ''' ) IS NOT NULL
				DROP TABLE ' + @TableName	
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