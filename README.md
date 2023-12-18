# 2020 Census Demographic and Housing Characteristics File

The purpose of this project is to load the data from the 2020 Census Demographic and Housing Characteristics (DHC) File into Microsoft SQL Server 2019.  The DHC file includes detailed data tables on age, sex, race, Hispanic or Latino origin, household type, family type, relationship to householder, group quarters population, housing occupancy, and housing tenure.

An effort has been made to compile any pertinent information related to this data release, however, if anything is missing or the original source is needed, more information about the file and links to download the data can be found here: https://www.census.gov/data/tables/2023/dec/2020-census-dhc.html


## Description of Files in Repository
There are three folders in this repository.  
### \Data
The first folder, [\Data](Data), holds links to where the data can be downloaded from the Census.gov website.  Other than holding links to the file download sources, this folder structure represents the expected folder structure in the later scripts.
There are two different geographic levels the files are available in: National-level and State-level.  The state-level files hold the geographic areas that are always within one state.  The national file contains geographic levels where the geographic areas can exist in two or more states.

### \Misc
The next folder, [\Misc](Misc), holds miscellaneous resources that have been compiled from the Census.gov website.  
- **2020census-demographic-and-housing-characteristics-file-and-demographic-profile-techdoc.pdf**
  - The main technical documentation from the Census Bureau.  Consult this file for any questions about the data itself.
- **2023-05-25_README.pdf**
  - A quick 3-page summary of the file characteristics.
- **file_layout_2020_DHC-National.xlsx**
  - Layout for all the attribute files.  This file has been modified to include a “clean” worksheet version that can be easily loaded into your SQL database as a lookup table.
- **geoheader-2020-dhc-national.xlsx**
  - Layout for the geography header files.  The geographic header file contains the geographic codes and other fields that identify the specific geographic entities that are linked to the table files.  This file has been modified to include a “clean” worksheet version that can be easily loaded into your SQL database as a lookup table.
- **sumlev-hierarchy-chart-dhc-national-ph.xlsx**
  - The summary levels that are present in the national-level file.  This file has been modified to include a “clean” worksheet version that can be easily loaded into your SQL database as a lookup table.
- **sumlev-hierarchy-chart-dhc-state.xlsx**
  - The summary levels that are present in the state-level files.  This file has been modified to include a “clean” worksheet version that can be easily loaded into your SQL database as a lookup table.
### \SQL_Scripts
The final folder, [\SQL_Scripts](SQL_Scripts), holds all of the T-SQL scripts that will be used to load the data files into SQL Server.
