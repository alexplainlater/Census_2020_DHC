--=============================================================================
-- The records were loaded in as VARCHAR, but I believe we can save some space 
-- by changing them to CHAR.  This data is nice enough to where the majority 
-- of the fields are fixed length character strings.  There's a few fields
-- that have no values that I'll keep as VARCHAR and some that don't appear
-- to have fixed length character strings that I'll also keep as VARCHAR. There
-- is also a couple of number fields I'll change to INT and BIGINT.
--=============================================================================
IF OBJECT_ID( 'Census_2020_DHC.dbo.DHC2020_GEO_All_States' ) IS NOT NULL
	DROP TABLE Census_2020_DHC.dbo.DHC2020_GEO_All_States
CREATE TABLE Census_2020_DHC.dbo.DHC2020_GEO_All_States
(
	FILEID CHAR(5)
	, STUSAB CHAR(2)
	, SUMLEV CHAR(3)
	, GEOVAR CHAR(2)
	, GEOCOMP CHAR(2)
	, CHARITER CHAR(3)
	, CIFSN CHAR(2)
	, LOGRECNO CHAR(7)
	, GEOID VARCHAR(60)
	, GEOCODE VARCHAR(51)
	, REGION CHAR(1)
	, DIVISION CHAR(1)
	, STATE CHAR(2)
	, STATENS CHAR(8)
	, COUNTY CHAR(3)
	, COUNTYCC CHAR(2)
	, COUNTYNS CHAR(8)
	, COUSUB CHAR(5)
	, COUSUBCC CHAR(2)
	, COUSUBNS CHAR(8)
	, SUBMCD CHAR(5)
	, SUBMCDCC CHAR(2)
	, SUBMCDNS CHAR(8)
	, ESTATE VARCHAR(5)
	, ESTATECC VARCHAR(2)
	, ESTATENS VARCHAR(8)
	, CONCIT CHAR(5)
	, CONCITCC CHAR(2)
	, CONCITNS CHAR(8)
	, PLACE CHAR(5)
	, PLACECC CHAR(2)
	, PLACENS CHAR(8)
	, TRACT CHAR(6)
	, BLKGRP CHAR(1)
	, BLOCK CHAR(4)
	, AIANHH CHAR(4)
	, AIHHTLI CHAR(1)
	, AIANHHFP CHAR(5)
	, AIANHHCC CHAR(2)
	, AIANHHNS CHAR(8)
	, AITS CHAR(3)
	, AITSFP CHAR(5)
	, AITSCC CHAR(2)
	, AITSNS CHAR(8)
	, TTRACT CHAR(6)
	, TBLKGRP CHAR(1)
	, ANRC CHAR(5)
	, ANRCCC CHAR(2)
	, ANRCNS CHAR(8)
	, CBSA CHAR(5)
	, MEMI CHAR(1)
	, CSA CHAR(3)
	, METDIV CHAR(5)
	, NECTA CHAR(5)
	, NMEMI CHAR(1)
	, CNECTA CHAR(3)
	, NECTADIV CHAR(5)
	, CBSAPCI CHAR(1)
	, NECTAPCI CHAR(1)
	, UA CHAR(5)
	, UATYPE CHAR(1)
	, UR CHAR(1)
	, CD116 CHAR(2)
	, CD118 CHAR(2)
	, CD119 CHAR(2)
	, CD120 CHAR(2)
	, CD121 CHAR(2)
	, SLDU18 CHAR(3)
	, SLDU22 CHAR(3)
	, SLDU24 CHAR(3)
	, SLDU26 CHAR(3)
	, SLDU28 CHAR(3)
	, SLDL18 CHAR(3)
	, SLDL22 CHAR(3)
	, SLDL24 CHAR(3)
	, SLDL26 CHAR(3)
	, SLDL28 CHAR(3)
	, VTD CHAR(6)
	, VTDI CHAR(1)
	, ZCTA CHAR(5)
	, SDELM CHAR(5)
	, SDSEC CHAR(5)
	, SDUNI CHAR(5)
	, PUMA CHAR(5)
	, AREALAND BIGINT
	, AREAWATR BIGINT
	, BASENAME VARCHAR(125)
	, NAME VARCHAR(125)
	, FUNCSTAT CHAR(1)
	, GCUNI CHAR(1)
	, POP100 INT
	, HU100 INT
	, INTPTLAT VARCHAR(11)
	, INTPTLON VARCHAR(12)
	, LSADC CHAR(2)
	, PARTFLAG CHAR(1)
	, UGA CHAR(5)
)

--=============================================================================
-- Insert the records from the view into our new table with the proper data types
--=============================================================================
INSERT INTO Census_2020_DHC.dbo.DHC2020_GEO_All_States
SELECT * FROM Census_2020_DHC.dbo.vwDHC2020_GEO_ALL

--=============================================================================
-- Looking for a primary key
--=============================================================================
SELECT 
	COUNT(*) --11,660,804
	, COUNT( DISTINCT GEOID ) --11,263,667  <-- Looks like 397,137 GEOIDs show up twice (or some slightly smaller amount  multiple times)
	, COUNT( DISTINCT FILEID + GEOID ) --11,660,804 <-- found it
	, COUNT( DISTINCT LOGRECNO ) --855,286
	, COUNT( DISTINCT GEOCODE ) --11,006,751
	, COUNT( DISTINCT FILEID + GEOCODE ) --11,188,568
FROM Census_2020_DHC.dbo.DHC2020_GEO_All_States

--=============================================================================
-- Is there any advantage to keeping the national file?
--=============================================================================
SELECT
	FILEID, COUNT(*)
FROM Census_2020_DHC.dbo.DHC2020_GEO_All_States a
GROUP BY FILEID
ORDER BY 1
-- DHCST	11,056,906
-- DHCUS	603,898

--=============================================================================
/*
	I want to see if any fields have different values between the records that 
	are the same.  There's a lot of fields so I threw the following prompt into 
	Microsoft Copilot Chat GPT to save me some typing/copy/paste:

	I have a list of columns that I'm writing a SQL statement for.  The first column is named, "FILEID".  I'm going to supply you with a list of columns and for each column, I'd like a line produced for each one that resembles this line of code:
		FILEID = SUM( CASE WHEN ISNULL( a.FILEID, '' ) <> ISNULL( b.FILEID, '' ) THEN 1 ELSE 0 END )

	Ok, here is my list of columns separated by commas:
	[FILEID], [STUSAB], [SUMLEV], [GEOVAR], [GEOCOMP], [CHARITER], [CIFSN], [LOGRECNO], [GEOID], [GEOCODE], [REGION], [DIVISION], [STATE], [STATENS], [COUNTY], [COUNTYCC], [COUNTYNS], [COUSUB], [COUSUBCC], [COUSUBNS], [SUBMCD], [SUBMCDCC], [SUBMCDNS], [ESTATE], [ESTATECC], [ESTATENS], [CONCIT], [CONCITCC], [CONCITNS], [PLACE], [PLACECC], [PLACENS], [TRACT], [BLKGRP], [BLOCK], [AIANHH], [AIHHTLI], [AIANHHFP], [AIANHHCC], [AIANHHNS], [AITS], [AITSFP], [AITSCC], [AITSNS], 

	Here's another list of columns to do the same with:
	[TTRACT], [TBLKGRP], [ANRC], [ANRCCC], [ANRCNS], [CBSA], [MEMI], [CSA], [METDIV], [NECTA], [NMEMI], [CNECTA], [NECTADIV], [CBSAPCI], [NECTAPCI], [UA], [UATYPE], [UR], [CD116], [CD118], [CD119], [CD120], [CD121], [SLDU18], [SLDU22], [SLDU24], [SLDU26], [SLDU28], [SLDL18], [SLDL22], [SLDL24], [SLDL26], [SLDL28], [VTD], [VTDI], [ZCTA], [SDELM], [SDSEC], [SDUNI], [PUMA], [AREALAND], [AREAWATR], [BASENAME], [NAME], [FUNCSTAT], [GCUNI], [POP100], [HU100], [INTPTLAT], [INTPTLON], [LSADC], [PARTFLAG], [UGA]
*/
--=============================================================================
SELECT
	FILEID = SUM( CASE WHEN ISNULL( a.FILEID, '' ) <> ISNULL( b.FILEID, '' ) THEN 1 ELSE 0 END )
	, STUSAB = SUM( CASE WHEN ISNULL( a.STUSAB, '' ) <> ISNULL( b.STUSAB, '' ) THEN 1 ELSE 0 END )
	, SUMLEV = SUM( CASE WHEN ISNULL( a.SUMLEV, '' ) <> ISNULL( b.SUMLEV, '' ) THEN 1 ELSE 0 END )
	, GEOVAR = SUM( CASE WHEN ISNULL( a.GEOVAR, '' ) <> ISNULL( b.GEOVAR, '' ) THEN 1 ELSE 0 END )
	, GEOCOMP = SUM( CASE WHEN ISNULL( a.GEOCOMP, '' ) <> ISNULL( b.GEOCOMP, '' ) THEN 1 ELSE 0 END )
	, CHARITER = SUM( CASE WHEN ISNULL( a.CHARITER, '' ) <> ISNULL( b.CHARITER, '' ) THEN 1 ELSE 0 END )
	, CIFSN = SUM( CASE WHEN ISNULL( a.CIFSN, '' ) <> ISNULL( b.CIFSN, '' ) THEN 1 ELSE 0 END )
	, LOGRECNO = SUM( CASE WHEN ISNULL( a.LOGRECNO, '' ) <> ISNULL( b.LOGRECNO, '' ) THEN 1 ELSE 0 END )
	, GEOID = SUM( CASE WHEN ISNULL( a.GEOID, '' ) <> ISNULL( b.GEOID, '' ) THEN 1 ELSE 0 END )
	, GEOCODE = SUM( CASE WHEN ISNULL( a.GEOCODE, '' ) <> ISNULL( b.GEOCODE, '' ) THEN 1 ELSE 0 END )
	, REGION = SUM( CASE WHEN ISNULL( a.REGION, '' ) <> ISNULL( b.REGION, '' ) THEN 1 ELSE 0 END )
	, DIVISION = SUM( CASE WHEN ISNULL( a.DIVISION, '' ) <> ISNULL( b.DIVISION, '' ) THEN 1 ELSE 0 END )
	, STATE = SUM( CASE WHEN ISNULL( a.STATE, '' ) <> ISNULL( b.STATE, '' ) THEN 1 ELSE 0 END )
	, STATENS = SUM( CASE WHEN ISNULL( a.STATENS, '' ) <> ISNULL( b.STATENS, '' ) THEN 1 ELSE 0 END )
	, COUNTY = SUM( CASE WHEN ISNULL( a.COUNTY, '' ) <> ISNULL( b.COUNTY, '' ) THEN 1 ELSE 0 END )
	, COUNTYCC = SUM( CASE WHEN ISNULL( a.COUNTYCC, '' ) <> ISNULL( b.COUNTYCC, '' ) THEN 1 ELSE 0 END )
	, COUNTYNS = SUM( CASE WHEN ISNULL( a.COUNTYNS, '' ) <> ISNULL( b.COUNTYNS, '' ) THEN 1 ELSE 0 END )
	, COUSUB = SUM( CASE WHEN ISNULL( a.COUSUB, '' ) <> ISNULL( b.COUSUB, '' ) THEN 1 ELSE 0 END )
	, COUSUBCC = SUM( CASE WHEN ISNULL( a.COUSUBCC, '' ) <> ISNULL( b.COUSUBCC, '' ) THEN 1 ELSE 0 END )
	, COUSUBNS = SUM( CASE WHEN ISNULL( a.COUSUBNS, '' ) <> ISNULL( b.COUSUBNS, '' ) THEN 1 ELSE 0 END )
	, SUBMCD = SUM( CASE WHEN ISNULL( a.SUBMCD, '' ) <> ISNULL( b.SUBMCD, '' ) THEN 1 ELSE 0 END )
	, SUBMCDCC = SUM( CASE WHEN ISNULL( a.SUBMCDCC, '' ) <> ISNULL( b.SUBMCDCC, '' ) THEN 1 ELSE 0 END )
	, SUBMCDNS = SUM( CASE WHEN ISNULL( a.SUBMCDNS, '' ) <> ISNULL( b.SUBMCDNS, '' ) THEN 1 ELSE 0 END )
	, ESTATE = SUM( CASE WHEN ISNULL( a.ESTATE, '' ) <> ISNULL( b.ESTATE, '' ) THEN 1 ELSE 0 END )
	, ESTATECC = SUM( CASE WHEN ISNULL( a.ESTATECC, '' ) <> ISNULL( b.ESTATECC, '' ) THEN 1 ELSE 0 END )
	, ESTATENS = SUM( CASE WHEN ISNULL( a.ESTATENS, '' ) <> ISNULL( b.ESTATENS, '' ) THEN 1 ELSE 0 END )
	, CONCIT = SUM( CASE WHEN ISNULL( a.CONCIT, '' ) <> ISNULL( b.CONCIT, '' ) THEN 1 ELSE 0 END )
	, CONCITCC = SUM( CASE WHEN ISNULL( a.CONCITCC, '' ) <> ISNULL( b.CONCITCC, '' ) THEN 1 ELSE 0 END )
	, CONCITNS = SUM( CASE WHEN ISNULL( a.CONCITNS, '' ) <> ISNULL( b.CONCITNS, '' ) THEN 1 ELSE 0 END )
	, PLACE = SUM( CASE WHEN ISNULL( a.PLACE, '' ) <> ISNULL( b.PLACE, '' ) THEN 1 ELSE 0 END )
	, PLACECC = SUM( CASE WHEN ISNULL( a.PLACECC, '' ) <> ISNULL( b.PLACECC, '' ) THEN 1 ELSE 0 END )
	, PLACENS = SUM( CASE WHEN ISNULL( a.PLACENS, '' ) <> ISNULL( b.PLACENS, '' ) THEN 1 ELSE 0 END )
	, TRACT = SUM( CASE WHEN ISNULL( a.TRACT, '' ) <> ISNULL( b.TRACT, '' ) THEN 1 ELSE 0 END )
	, BLKGRP = SUM( CASE WHEN ISNULL( a.BLKGRP, '' ) <> ISNULL( b.BLKGRP, '' ) THEN 1 ELSE 0 END )
	, BLOCK = SUM( CASE WHEN ISNULL( a.BLOCK, '' ) <> ISNULL( b.BLOCK, '' ) THEN 1 ELSE 0 END )
	, AIANHH = SUM( CASE WHEN ISNULL( a.AIANHH, '' ) <> ISNULL( b.AIANHH, '' ) THEN 1 ELSE 0 END )
	, AIHHTLI = SUM( CASE WHEN ISNULL( a.AIHHTLI, '' ) <> ISNULL( b.AIHHTLI, '' ) THEN 1 ELSE 0 END )
	, AIANHHFP = SUM( CASE WHEN ISNULL( a.AIANHHFP, '' ) <> ISNULL( b.AIANHHFP, '' ) THEN 1 ELSE 0 END )
	, AIANHHCC = SUM( CASE WHEN ISNULL( a.AIANHHCC, '' ) <> ISNULL( b.AIANHHCC, '' ) THEN 1 ELSE 0 END )
	, AIANHHNS = SUM( CASE WHEN ISNULL( a.AIANHHNS, '' ) <> ISNULL( b.AIANHHNS, '' ) THEN 1 ELSE 0 END )
	, AITS = SUM( CASE WHEN ISNULL( a.AITS, '' ) <> ISNULL( b.AITS, '' ) THEN 1 ELSE 0 END )
	, AITSFP = SUM( CASE WHEN ISNULL( a.AITSFP, '' ) <> ISNULL( b.AITSFP, '' ) THEN 1 ELSE 0 END )
	, AITSCC = SUM( CASE WHEN ISNULL( a.AITSCC, '' ) <> ISNULL( b.AITSCC, '' ) THEN 1 ELSE 0 END )
	, AITSNS = SUM( CASE WHEN ISNULL( a.AITSNS, '' ) <> ISNULL( b.AITSNS, '' ) THEN 1 ELSE 0 END )
	, TTRACT = SUM( CASE WHEN ISNULL( a.TTRACT, '' ) <> ISNULL( b.TTRACT, '' ) THEN 1 ELSE 0 END )
	, TBLKGRP = SUM( CASE WHEN ISNULL( a.TBLKGRP, '' ) <> ISNULL( b.TBLKGRP, '' ) THEN 1 ELSE 0 END )
	, ANRC = SUM( CASE WHEN ISNULL( a.ANRC, '' ) <> ISNULL( b.ANRC, '' ) THEN 1 ELSE 0 END )
	, ANRCCC = SUM( CASE WHEN ISNULL( a.ANRCCC, '' ) <> ISNULL( b.ANRCCC, '' ) THEN 1 ELSE 0 END )
	, ANRCNS = SUM( CASE WHEN ISNULL( a.ANRCNS, '' ) <> ISNULL( b.ANRCNS, '' ) THEN 1 ELSE 0 END )
	, CBSA = SUM( CASE WHEN ISNULL( a.CBSA, '' ) <> ISNULL( b.CBSA, '' ) THEN 1 ELSE 0 END )
	, MEMI = SUM( CASE WHEN ISNULL( a.MEMI, '' ) <> ISNULL( b.MEMI, '' ) THEN 1 ELSE 0 END )
	, CSA = SUM( CASE WHEN ISNULL( a.CSA, '' ) <> ISNULL( b.CSA, '' ) THEN 1 ELSE 0 END )
	, METDIV = SUM( CASE WHEN ISNULL( a.METDIV, '' ) <> ISNULL( b.METDIV, '' ) THEN 1 ELSE 0 END )
	, NECTA = SUM( CASE WHEN ISNULL( a.NECTA, '' ) <> ISNULL( b.NECTA, '' ) THEN 1 ELSE 0 END )
	, NMEMI = SUM( CASE WHEN ISNULL( a.NMEMI, '' ) <> ISNULL( b.NMEMI, '' ) THEN 1 ELSE 0 END )
	, CNECTA = SUM( CASE WHEN ISNULL( a.CNECTA, '' ) <> ISNULL( b.CNECTA, '' ) THEN 1 ELSE 0 END )
	, NECTADIV = SUM( CASE WHEN ISNULL( a.NECTADIV, '' ) <> ISNULL( b.NECTADIV, '' ) THEN 1 ELSE 0 END )
	, CBSAPCI = SUM( CASE WHEN ISNULL( a.CBSAPCI, '' ) <> ISNULL( b.CBSAPCI, '' ) THEN 1 ELSE 0 END )
	, NECTAPCI = SUM( CASE WHEN ISNULL( a.NECTAPCI, '' ) <> ISNULL( b.NECTAPCI, '' ) THEN 1 ELSE 0 END )
	, UA = SUM( CASE WHEN ISNULL( a.UA, '' ) <> ISNULL( b.UA, '' ) THEN 1 ELSE 0 END )
	, UATYPE = SUM( CASE WHEN ISNULL( a.UATYPE, '' ) <> ISNULL( b.UATYPE, '' ) THEN 1 ELSE 0 END )
	, UR = SUM( CASE WHEN ISNULL( a.UR, '' ) <> ISNULL( b.UR, '' ) THEN 1 ELSE 0 END )
	, CD116 = SUM( CASE WHEN ISNULL( a.CD116, '' ) <> ISNULL( b.CD116, '' ) THEN 1 ELSE 0 END )
	, CD118 = SUM( CASE WHEN ISNULL( a.CD118, '' ) <> ISNULL( b.CD118, '' ) THEN 1 ELSE 0 END )
	, CD119 = SUM( CASE WHEN ISNULL( a.CD119, '' ) <> ISNULL( b.CD119, '' ) THEN 1 ELSE 0 END )
	, CD120 = SUM( CASE WHEN ISNULL( a.CD120, '' ) <> ISNULL( b.CD120, '' ) THEN 1 ELSE 0 END )
	, CD121 = SUM( CASE WHEN ISNULL( a.CD121, '' ) <> ISNULL( b.CD121, '' ) THEN 1 ELSE 0 END )
	, SLDU18 = SUM( CASE WHEN ISNULL( a.SLDU18, '' ) <> ISNULL( b.SLDU18, '' ) THEN 1 ELSE 0 END )
	, SLDU22 = SUM( CASE WHEN ISNULL( a.SLDU22, '' ) <> ISNULL( b.SLDU22, '' ) THEN 1 ELSE 0 END )
	, SLDU24 = SUM( CASE WHEN ISNULL( a.SLDU24, '' ) <> ISNULL( b.SLDU24, '' ) THEN 1 ELSE 0 END )
	, SLDU26 = SUM( CASE WHEN ISNULL( a.SLDU26, '' ) <> ISNULL( b.SLDU26, '' ) THEN 1 ELSE 0 END )
	, SLDU28 = SUM( CASE WHEN ISNULL( a.SLDU28, '' ) <> ISNULL( b.SLDU28, '' ) THEN 1 ELSE 0 END )
	, SLDL18 = SUM( CASE WHEN ISNULL( a.SLDL18, '' ) <> ISNULL( b.SLDL18, '' ) THEN 1 ELSE 0 END )
	, SLDL22 = SUM( CASE WHEN ISNULL( a.SLDL22, '' ) <> ISNULL( b.SLDL22, '' ) THEN 1 ELSE 0 END )
	, SLDL24 = SUM( CASE WHEN ISNULL( a.SLDL24, '' ) <> ISNULL( b.SLDL24, '' ) THEN 1 ELSE 0 END )
	, SLDL26 = SUM( CASE WHEN ISNULL( a.SLDL26, '' ) <> ISNULL( b.SLDL26, '' ) THEN 1 ELSE 0 END )
	, SLDL28 = SUM( CASE WHEN ISNULL( a.SLDL28, '' ) <> ISNULL( b.SLDL28, '' ) THEN 1 ELSE 0 END )
	, VTD = SUM( CASE WHEN ISNULL( a.VTD, '' ) <> ISNULL( b.VTD, '' ) THEN 1 ELSE 0 END )
	, VTDI = SUM( CASE WHEN ISNULL( a.VTDI, '' ) <> ISNULL( b.VTDI, '' ) THEN 1 ELSE 0 END )
	, ZCTA = SUM( CASE WHEN ISNULL( a.ZCTA, '' ) <> ISNULL( b.ZCTA, '' ) THEN 1 ELSE 0 END )
	, SDELM = SUM( CASE WHEN ISNULL( a.SDELM, '' ) <> ISNULL( b.SDELM, '' ) THEN 1 ELSE 0 END )
	, SDSEC = SUM( CASE WHEN ISNULL( a.SDSEC, '' ) <> ISNULL( b.SDSEC, '' ) THEN 1 ELSE 0 END )
	, SDUNI = SUM( CASE WHEN ISNULL( a.SDUNI, '' ) <> ISNULL( b.SDUNI, '' ) THEN 1 ELSE 0 END )
	, PUMA = SUM( CASE WHEN ISNULL( a.PUMA, '' ) <> ISNULL( b.PUMA, '' ) THEN 1 ELSE 0 END )
	, AREALAND = SUM( CASE WHEN ISNULL( a.AREALAND, 0 ) <> ISNULL( b.AREALAND, 0 ) THEN 1 ELSE 0 END )
	, AREAWATR = SUM( CASE WHEN ISNULL( a.AREAWATR, 0 ) <> ISNULL( b.AREAWATR, 0 ) THEN 1 ELSE 0 END )
	, BASENAME = SUM( CASE WHEN ISNULL( a.BASENAME, '' ) <> ISNULL( b.BASENAME, '' ) THEN 1 ELSE 0 END )
	, NAME = SUM( CASE WHEN ISNULL( a.NAME, '' ) <> ISNULL( b.NAME, '' ) THEN 1 ELSE 0 END )
	, FUNCSTAT = SUM( CASE WHEN ISNULL( a.FUNCSTAT, '' ) <> ISNULL( b.FUNCSTAT, '' ) THEN 1 ELSE 0 END )
	, GCUNI = SUM( CASE WHEN ISNULL( a.GCUNI, '' ) <> ISNULL( b.GCUNI, '' ) THEN 1 ELSE 0 END )
	, POP100 = SUM( CASE WHEN ISNULL( a.POP100, 0 ) <> ISNULL( b.POP100, 0 ) THEN 1 ELSE 0 END )
	, HU100 = SUM( CASE WHEN ISNULL( a.HU100, 0 ) <> ISNULL( b.HU100, 0 ) THEN 1 ELSE 0 END )
	, INTPTLAT = SUM( CASE WHEN ISNULL( a.INTPTLAT, '' ) <> ISNULL( b.INTPTLAT, '' ) THEN 1 ELSE 0 END )
	, INTPTLON = SUM( CASE WHEN ISNULL( a.INTPTLON, '' ) <> ISNULL( b.INTPTLON, '' ) THEN 1 ELSE 0 END )
	, LSADC = SUM( CASE WHEN ISNULL( a.LSADC, '' ) <> ISNULL( b.LSADC, '' ) THEN 1 ELSE 0 END )
	, PARTFLAG = SUM( CASE WHEN ISNULL( a.PARTFLAG, '' ) <> ISNULL( b.PARTFLAG, '' ) THEN 1 ELSE 0 END )
	, UGA = SUM( CASE WHEN ISNULL( a.UGA, '' ) <> ISNULL( b.UGA, '' ) THEN 1 ELSE 0 END )
FROM Census_2020_DHC.dbo.DHC2020_GEO_All_States a
INNER JOIN Census_2020_DHC.dbo.DHC2020_GEO_All_States b
	ON a.GEOID = b.GEOID
WHERE a.FILEID = 'DHCST'
	AND b.FILEID = 'DHCUS'

--=============================================================================
-- The only fields different here are FILEID, STUSAB, and LOGRECNO <-- 397,137 records on all three fields
-- I think I'm going to remove the national-level versions and keep the state level
--=============================================================================
DELETE d
FROM Census_2020_DHC.dbo.DHC2020_GEO_All_States d
INNER JOIN
(
	SELECT
		b.FILEID
		, b.LOGRECNO
		, b.GEOID
	FROM Census_2020_DHC.dbo.DHC2020_GEO_All_States a
	INNER JOIN Census_2020_DHC.dbo.DHC2020_GEO_All_States b
		ON a.GEOID = b.GEOID
	WHERE a.FILEID = 'DHCST'
		AND b.FILEID = 'DHCUS'
) c
	ON d.FILEID = c.FILEID
	AND d.LOGRECNO = c.LOGRECNO
	AND d.GEOID = c.GEOID
WHERE d.FILEID = 'DHCUS'
--(397,137 rows affected)

--=============================================================================
-- Size of the new table, ensure it is unique on GEOID
--=============================================================================
SELECT COUNT(*), COUNT( DISTINCT GEOID )
FROM Census_2020_DHC.dbo.DHC2020_GEO_All_States
--11,159,338	11,159,338
