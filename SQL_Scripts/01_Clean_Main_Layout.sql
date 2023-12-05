--=============================================================================
--Take a look at what we imported
--=============================================================================
SELECT TOP 1000 *
FROM [Census_2020_DHC].[dbo].[layoutDHC2020]

--=============================================================================
-- Take a look at the data types that were generated
--=============================================================================
SELECT
	COLUMN_NAME
	, ORDINAL_POSITION
	, DATA_TYPE
	, CHARACTER_MAXIMUM_LENGTH
FROM Census_2020_DHC.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'layoutDHC2020'

--=============================================================================
-- Looks like we need to do some clean up of the imported data, so let's create
-- a new table with the cleaned up fields.
--=============================================================================
IF OBJECT_ID( '[Census_2020_DHC].[dbo].[layoutDHC2020_Clean]' ) IS NOT NULL
	DROP TABLE [Census_2020_DHC].[dbo].[layoutDHC2020_Clean] 
SELECT
	PersonHousing = CONVERT( CHAR(1), LTRIM( RTRIM( [Person (P) or Housing (H)] ) ) )
	, TableNumber = CONVERT( VARCHAR(10), LTRIM( RTRIM( [Table number] ) ) )
	, ReferenceName = CONVERT( VARCHAR(10), LTRIM( RTRIM( [Data dictionary reference name] ) ) )
	, Segment = CONVERT( TINYINT, LTRIM( RTRIM( Segment ) ) )
	, FileName = CONVERT( VARCHAR(15), LTRIM( RTRIM( [File Name] ) ) )
	, MaxSize = CONVERT( TINYINT, LTRIM( RTRIM( [Max Size] ) ) )
	, SortOrder = CONVERT( TINYINT, LTRIM( RTRIM( [Sort Order] ) ) )
	, Title_Orig = CONVERT( VARCHAR(255), LTRIM( RTRIM( Title ) ) )
	, Title = CONVERT( VARCHAR(255), 
				LTRIM( 
					RTRIM( 
						SUBSTRING( 
							Title -- field to adjust
							, 0  -- starting position of string to keep
							, CHARINDEX( '[', Title ) -- spot to start removal of '[x]'
						) 
					)
				)
			)
	, Universe = CONVERT( VARCHAR(255), LTRIM( RTRIM( Universe ) ) )
	, Field = CONVERT( VARCHAR(255), LTRIM( RTRIM( [Table contents] ) ) )
	, Table_Field_Num = CONVERT( TINYINT, 
							ROW_NUMBER() OVER( 
								PARTITION BY CONVERT( VARCHAR(10), LTRIM( RTRIM( [Table number] ) ) ) 
								ORDER BY CONVERT( VARCHAR(10), LTRIM( RTRIM( [Data dictionary reference name] ) ) ) ASC 
							)
						)
	, File_Field_Num = CONVERT( TINYINT, 
							ROW_NUMBER() OVER( 
								PARTITION BY CONVERT( VARCHAR(10), LTRIM( RTRIM( Segment ) ) ) 
								ORDER BY CONVERT( TINYINT, LTRIM( RTRIM( [Sort Order] ) ) ) ASC
									, CONVERT( VARCHAR(10), LTRIM( RTRIM( [Data dictionary reference name] ) ) ) ASC 
							)
						) 
INTO [Census_2020_DHC].[dbo].[layoutDHC2020_Clean] 
FROM [Census_2020_DHC].[dbo].[layoutDHC2020]

--=============================================================================
-- Let's put a clustered index on the table just so it is sorted the way we want
--=============================================================================
CREATE UNIQUE CLUSTERED INDEX UC_IDX_Sort ON [Census_2020_DHC].[dbo].[layoutDHC2020_Clean]( Segment, SortOrder, ReferenceName )

--=============================================================================
-- Drop the original table
--=============================================================================
DROP TABLE [Census_2020_DHC].[dbo].[layoutDHC2020]

--=============================================================================
-- Rename our new clean table to the table name we want
--=============================================================================
EXEC sp_rename  
	@objname = '[Census_2020_DHC].[dbo].[layoutDHC2020_Clean]'
	, @newname = 'layoutDHC2020'

--=============================================================================
-- Double check our work.  Take a look at the data types that were generated
--=============================================================================
SELECT * 
FROM [Census_2020_DHC].[dbo].[layoutDHC2020]

SELECT
	COLUMN_NAME
	, ORDINAL_POSITION
	, DATA_TYPE
	, CHARACTER_MAXIMUM_LENGTH
FROM Census_2020_DHC.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'layoutDHC2020'