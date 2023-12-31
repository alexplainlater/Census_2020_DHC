USE Census_2020_DHC

GO
--=============================================================================
-- Create a vew that UNIONS together all of the state tables
--=============================================================================
CREATE VIEW dbo.vwDHC2020_GEO_ALL AS
(
	SELECT a.*
	FROM
	(
		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_AK_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_AL_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_AR_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_AZ_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_CA_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_CO_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_CT_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_DC_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_DE_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_FL_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_GA_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_HI_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_IA_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_ID_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_IL_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_IN_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_KS_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_KY_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_LA_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_MA_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_MD_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_ME_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_MI_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_MN_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_MO_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_MS_GEO

		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_MT_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_ND_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_NC_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_NE_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_NH_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_NJ_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_NM_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_NV_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_NY_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_OH_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_OK_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_OR_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_PA_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_PR_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_RI_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_SC_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_SD_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_TN_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_TX_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_UT_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_VA_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_VT_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_WA_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_WI_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_WV_GEO
	
		UNION ALL

		SELECT * FROM [Census_2020_DHC].[dbo].DHC2020_State_WY_GEO
	) a
)

GO

--=============================================================================
-- Confirm all the states are present (50 + DC + PR)
--=============================================================================
SELECT
	States = COUNT( DISTINCT STATE )
FROM Census_2020_DHC.dbo.vwDHC2020_GEO_ALL 
--52