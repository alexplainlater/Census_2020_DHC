--=============================================================================
-- Create a quick state lookup table -- Grabbed  and adjusted from: 
-- https://en.wikipedia.org/wiki/Federal_Information_Processing_Standard_state_code
--=============================================================================
IF OBJECT_ID( 'Census_2020_DHC.dbo.lkpStates' ) IS NOT NULL
	DROP TABLE Census_2020_DHC.dbo.lkpStates
CREATE TABLE Census_2020_DHC.dbo.lkpStates
(
	Abbr VARCHAR(255) NULL
	, [State Name] VARCHAR(255) NULL
	, State_Code CHAR(2) NULL
)

INSERT INTO Census_2020_DHC.dbo.lkpStates( Abbr, [State Name], State_Code )