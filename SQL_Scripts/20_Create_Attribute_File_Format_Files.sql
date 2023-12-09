/*
	--=============================================================================
	Need to create a format file for each attribute file.  The same format files can
	be used for the state files and the national files, but each file has its own
	format.

	Thoughts:
	Probably want to load the whole file in first so we don't have to load the file numerous times
	Once loaded, we can split the results into the multiple tables we want

	We will call each format file: AttributeFile[01-44].fmt
	We will call each table: US_Attribute_Table[01-44]
	We can use the reference name for the initial column name

	For every file, we need to add the first five fields to the beginning
	--=============================================================================
*/

-- Constants
DECLARE @VERSION VARCHAR(5) = '14.0'
DECLARE @TAB_CHARACTER CHAR(1) = CHAR(9)
DECLARE @NEWLINE CHAR(1) = CHAR(10)
DECLARE @PROJ_DIR VARCHAR(255) = 'Z:\Census_2020\Demographic_and_Housing_Characteristics_File\'

-- Variables
DECLARE @CurSegment TINYINT
DECLARE @PrefixColumnCount TINYINT
DECLARE @MaxNumColumns SMALLINT
DECLARE @PrefixRows VARCHAR(MAX)
DECLARE @Rows VARCHAR(MAX)
DECLARE @FullFile VARCHAR(MAX)
DECLARE @log_message VARCHAR(MAX)

--=============================================================================
-- Fill in the prefix fields.  These fields show up in the beginning of all files
--=============================================================================
SET @log_message = 'Start creating prefix information at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
	RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
	
--=============================================================================
-- Grab the number of fields for the file prefix.  Making this dynamic just in 
-- case they get changed for whatever reason
--=============================================================================
SELECT @PrefixColumnCount = COUNT(*)
FROM [Census_2020_DHC].[dbo].[layoutDHC2020_Beginning]

--=============================================================================
-- Build the format file entries for the fields at the beginning of every file
--=============================================================================
SELECT @PrefixRows = COALESCE( @PrefixRows, '' ) + 
	 CONVERT( VARCHAR, Field_Num )
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ 'SQLCHAR'
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ '0'
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ CONVERT( VARCHAR, Max_Size )
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ '"|"'
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ CONVERT( VARCHAR, Field_Num )
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ Field_Name
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ '""'
		+ @NEWLINE
FROM [Census_2020_DHC].[dbo].[layoutDHC2020_Beginning]
ORDER BY Field_Num ASC

SET @log_message = 'Finished creating prefix information at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
	RAISERROR( @log_message, 0, 1 ) WITH NOWAIT

--=============================================================================
-- Start the construction of the non-prefix fields in the format file.  Will
-- need to cycle through each segment (file) and build its specific format file
--=============================================================================
DECLARE segmentCursor CURSOR FOR
	SELECT Segment
	FROM [Census_2020_DHC].[dbo].[layoutDHC2020]
	GROUP BY Segment
	ORDER BY 1

OPEN segmentCursor

FETCH NEXT FROM segmentCursor INTO @CurSegment

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @log_message = 'Started segment: ' + CONVERT( VARCHAR, @CurSegment ) + ' at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT

	--=============================================================================
	-- Grab the number of columns from this file that will be loaded and add prefix columns
	--=============================================================================
	SELECT @MaxNumColumns = COUNT(*) + @PrefixColumnCount
	FROM [Census_2020_DHC].[dbo].[layoutDHC2020]
	WHERE Segment = @CurSegment

	--=============================================================================
	-- build the entries in the format file for the file's fields
	--=============================================================================
	SELECT @Rows = COALESCE( @Rows, '' ) + 
		 CONVERT( VARCHAR, File_Field_Num + @PrefixColumnCount )
			+ @TAB_CHARACTER + @TAB_CHARACTER
			+ 'SQLCHAR'
			+ @TAB_CHARACTER + @TAB_CHARACTER
			+ '0'
			+ @TAB_CHARACTER + @TAB_CHARACTER
			+ CONVERT( VARCHAR, MaxSize )
			+ @TAB_CHARACTER + @TAB_CHARACTER
			+ CASE WHEN File_Field_Num + @PrefixColumnCount = @MaxNumColumns THEN '"\n"' ELSE '"|"' END
			+ @TAB_CHARACTER + @TAB_CHARACTER
			+ CONVERT( VARCHAR, File_Field_Num + @PrefixColumnCount )
			+ @TAB_CHARACTER + @TAB_CHARACTER
			+ ReferenceName
			+ @TAB_CHARACTER + @TAB_CHARACTER
			+ '""'
			+ @NEWLINE
	FROM [Census_2020_DHC].[dbo].[layoutDHC2020]
	WHERE Segment = @CurSegment
	ORDER BY File_Field_Num ASC

	--=============================================================================
	-- Combine all the format file components
	--=============================================================================
	SET @FullFile = @Version + @NEWLINE + CONVERT( VARCHAR(5), @MaxNumColumns ) + @NEWLINE + @PrefixRows + @Rows + @NEWLINE
		
	--=============================================================================
	-- Put the results in a quick temporary table so we can export them
	--=============================================================================
	SELECT file_contents = @FullFile
	INTO ##tmp

	--=============================================================================
	-- Call the BCP utility to export what we created to a file.
	--=============================================================================
	SET @log_message = 'Exporting segment: ' + CONVERT( VARCHAR, @CurSegment ) + ' at: ' + CONVERT( VARCHAR, GETDATE(), 113 )
		RAISERROR( @log_message, 0, 1 ) WITH NOWAIT
	DECLARE @SQL_Command VARCHAR(1000)
	SET @SQL_Command = 'bcp "SELECT file_contents FROM ##tmp" queryout ' + @PROJ_DIR + 'Format_Files\AttributeFile' + RIGHT( '00' + CONVERT( VARCHAR, @CurSegment ), 2 ) + '.fmt -c -T'
	EXEC master..xp_cmdshell @SQL_Command

	--=============================================================================
	-- Drop our temporary table and clear out our @Rows variable
	--=============================================================================
	DROP TABLE ##tmp
	SET @Rows = NULL
	
	FETCH NEXT FROM segmentCursor INTO @CurSegment
END

CLOSE segmentCursor

DEALLOCATE segmentCursor

