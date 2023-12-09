DECLARE @PROJ_DIR VARCHAR(255) = 'Z:\Census_2020\Demographic_and_Housing_Characteristics_File\'
DECLARE @DataFile VARCHAR(255)
DECLARE @formatFile VARCHAR(255)
DECLARE @SQL VARCHAR(MAX)

--=============================================================================
--Take a look at the main fields
--=============================================================================
SELECT
	[ColumnID]
	,[FIELD]
	,[DATA DICTIONARY REFERENCE]
	,[MAXIMUM FIELD SIZE]
	,[DATA TYPE]	
FROM [Census_2020_DHC].[dbo].[layoutDHC2020_Geo]

--=============================================================================
-- Went through this whole process and found that the BASENAME field actually
-- has a maximum field size closer to 125, so updating that here.
--=============================================================================
UPDATE a
SET [MAXIMUM FIELD SIZE] = 125
FROM [Census_2020_DHC].[dbo].[layoutDHC2020_Geo] a
WHERE [DATA DICTIONARY REFERENCE] = 'BASENAME'

--=============================================================================
-- Going to build a format file to use to import the data in the GEO file.
-- Match format from:
-- https://learn.microsoft.com/en-us/sql/relational-databases/import-export/non-xml-format-files-sql-server
--=============================================================================
DECLARE @Version VARCHAR(5)
DECLARE @MaxNumColumns VARCHAR(5)
DECLARE @Rows VARCHAR(MAX)
DECLARE @FullFile VARCHAR(MAX)
DECLARE @TAB_CHARACTER CHAR(1) = CHAR(9)
DECLARE @NEWLINE CHAR(1) = CHAR(10)

SET @Version = '14.0'

SELECT @MaxNumColumns = CONVERT( VARCHAR, MAX( ColumnID ) )
FROM [Census_2020_DHC].[dbo].[layoutDHC2020_Geo]

SELECT @Rows = COALESCE( @Rows, '' ) + 
	 CONVERT( VARCHAR, ColumnID )
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ 'SQLCHAR'
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ '0'
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ CONVERT( VARCHAR, [MAXIMUM FIELD SIZE] )
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ CASE WHEN ColumnID = CONVERT( INT, @MaxNumColumns ) THEN '"\n"' ELSE '"|"' END
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ CONVERT( VARCHAR, ColumnID )
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ [DATA DICTIONARY REFERENCE]
		+ @TAB_CHARACTER + @TAB_CHARACTER
		+ '""'
		+ @NEWLINE
FROM [Census_2020_DHC].[dbo].[layoutDHC2020_Geo]
ORDER BY ColumnID ASC

SET @FullFile = @Version + @NEWLINE + @MaxNumColumns + @NEWLINE + @Rows + @NEWLINE

--=============================================================================
-- Put the results in a quick temporary table so we can export them
--=============================================================================
SELECT file_contents = @FullFile
INTO ##tmp

--=============================================================================
-- Call the BCP utility to export what we created to a file.
--=============================================================================
DECLARE @SQL_Command VARCHAR(1000)
SET @SQL_Command = 'bcp "SELECT file_contents FROM ##tmp" queryout ' + @PROJ_DIR + 'Format_Files\DHC2020_Geo_Layout.fmt -c -T'
EXEC master..xp_cmdshell @SQL_Command

--=============================================================================
-- Drop our temporary table
--=============================================================================
DROP TABLE ##tmp

--=============================================================================
-- Import the data using the format file we just created
--=============================================================================
SET @DataFile = @PROJ_DIR + 'Data\National\us2020.dhc\usgeo2020.dhc'
SET @formatFile = @PROJ_DIR + 'Format_Files\DHC2020_Geo_Layout.fmt'

SET @SQL = '
	IF OBJECT_ID( ''Census_2020_DHC.dbo.DHC2020_GEO'' ) IS NOT NULL
		DROP TABLE Census_2020_DHC.dbo.DHC2020_GEO
	SELECT a.*
	INTO Census_2020_DHC.dbo.DHC2020_GEO
	FROM OPENROWSET(
		BULK ''' + @DataFile + '''
			, FORMATFILE = ''' + @formatFile + '''
			, MAXERRORS = 0
			, FIRSTROW = 1
	) a
'
--PRINT( @SQL )
EXEC( @SQL )
--(603,898 rows affected)

--=============================================================================
-- Take a quick look at what was imported
--=============================================================================
SELECT TOP 1000 *
FROM Census_2020_DHC.dbo.DHC2020_GEO

SELECT a.SUMLEV, b.[Summary Level], COUNT(*)
FROM Census_2020_DHC.dbo.DHC2020_GEO a
INNER JOIN Census_2020_DHC.dbo.lkpSUMLEV_National_DHC2020 b
	ON a.SUMLEV = b.SUMLEV
GROUP BY a.SUMLEV, b.[Summary Level]
ORDER BY 3 DESC


--***Seem to be missing block level data, looks like that data is in state specific files

--=============================================================================
-- Import the NV state data using the format file we just created
--=============================================================================
SET @DataFile = @PROJ_DIR + 'Data\States\nv2020.dhc\nvgeo2020.dhc'
SET @formatFile = @PROJ_DIR + 'Format_Files\DHC2020_Geo_Layout.fmt'

SET @SQL = '
	IF OBJECT_ID( ''Census_2020_DHC.dbo.DHC2020_State_NV_GEO'' ) IS NOT NULL
		DROP TABLE Census_2020_DHC.dbo.DHC2020_State_NV_GEO
	SELECT a.*
	INTO Census_2020_DHC.dbo.DHC2020_State_NV_GEO
	FROM OPENROWSET(
		BULK ''' + @DataFile + '''
			, FORMATFILE = ''' + @formatFile + '''
			, MAXERRORS = 0
			, FIRSTROW = 1
	) a
'
--PRINT( @SQL )
EXEC( @SQL )
--(75600 rows affected)

--=============================================================================
-- Take a quick look at what was imported
--=============================================================================
SELECT TOP 1000 *
FROM Census_2020_DHC.dbo.DHC2020_NV_GEO

SELECT a.SUMLEV, b.[Summary Level], COUNT(*)
FROM Census_2020_DHC.dbo.DHC2020_State_NV_GEO a
LEFT JOIN Census_2020_DHC.dbo.lkpSUMLEV_State_DHC2020 b
	ON a.SUMLEV = b.SUMLEV
GROUP BY a.SUMLEV, b.[Summary Level]
ORDER BY 3 DESC

--=============================================================================
-- What's the overlap like between the two files.?
--=============================================================================
SELECT n.*
	, s.*
FROM Census_2020_DHC.dbo.lkpSUMLEV_National_DHC2020 n
INNER JOIN Census_2020_DHC.dbo.lkpSUMLEV_State_DHC2020 s
	ON n.SUMLEV = s.SUMLEV

SELECT TOP 1000 * 
FROM Census_2020_DHC.dbo.DHC2020_GEO
WHERE State = '32'

SELECT TOP 1000 *
FROM Census_2020_DHC.dbo.DHC2020_State_NV_GEO 


SELECT TOP 1000 n.*, st.*
FROM Census_2020_DHC.dbo.DHC2020_GEO n
INNER JOIN Census_2020_DHC.dbo.DHC2020_State_NV_GEO st
	ON n.GEOID = st.GEOID