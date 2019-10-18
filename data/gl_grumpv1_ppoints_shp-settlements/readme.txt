Global Rural-Urban Mapping Project, Version 1 (GRUMPv1): Settlement Points


Contents:

DESCRIPTION
CITATION
FILE TYPE
FIELDS
PROJECTION
NOTES
DATA RESTRICTIONS
DATA ERRORS, CORRECTIONS AND QUALITY ASSESSMENT
NO WARRANTY OR LIABILITY


DESCRIPTION

This zip file contains data from Center for International Earth Science Information 
Network (CIESIN) and colleagues' (see "citation", below) Global Rural-Urban Mapping 
Project, Version 1 (GRUMPv1): Settlement Points database. 
Documentation is available on the GRUMP web site at:

http://sedac.ciesin.columbia.edu/data/dataset/grump-v1-settlement-points/docs

This is the release of version 1 of the GRUMP product. See the GRUMP home 
page for additional information on the product.  If you should discover any 
problems or errors, please inform us at:

grump@ciesin.columbia.edu


CITATION

We recommend the following for citing the database:

Center for International Earth Science Information Network (CIESIN), 
Columbia University; International Food Policy Research Institute (IFPRI), 
the World Bank; and Centro Internacional de Agricultura Tropical (CIAT). 2011. 
Global Rural-Urban Mapping Project, Version 1 (GRUMPv1): Settlement Points. 
Palisades, NY: Socioeconomic Data and Applications Center (SEDAC), Columbia University. 
Available at http://sedac.ciesin.columbia.edu/data/dataset/grump-v1-settlement-points. 
(Date of download)


FILE TYPE

The settlement file in this zip folder is in MS Excel (xls), Comma-Separated 
Values (csv), or ESRI Shapfile (shp) file formats.

The file names are prefixed
by the three letter ISO code for the country or a two letter code for the 
continent or globe.

XLS
----

The xls file is a worksheet file with data arranged in tabular form that is typically used 
in spreadsheets. This xls file was created using version 2000 of MS Excel.

CSV
----

The csv file format allows for the data table to be imported into a variety of applications - 
typically spreadsheet or database applications.

SHP
----
The shp file is a spatial data format that can be used in GIS applications. This shp file 
was created using ESRI ArcGIS version 9.x. 


FIELDS

Variable Name	Definition

OBJECTID	Unique numeric field
LATLONGID	ID value
LATITUDE	Latitude in geographic coordinates (decimal degrees)
LONGITUDE	Longitude in geographic coordinates (decimal degrees)
URBORRUR	U = urban, R = rural
YEAR		Year of population estimate
ES90POP	Population estimate adjusted to 1990
ES95POP	Population estimate adjusted to 1995
ES00POP	Population estimate adjusted to 2000
INSGRUSED	Growth rate for interpolation extrapolation based on population estimates
CONTINENT	UN Continent to which the country/territory belongs
UNREGION	UN Region to which the country/territory belongs
COUNTRY	Country name in English
UNSD		UN Statistics Division code for the country/territory
ISO3		ISO 3-letter abbreviation for the country/territory
SCHNM		Populated place name in upper case with spaces and special characters removed
NAME1		Populated place name
NAME2		Alternative name
NAME3		Alternative name
FORGNNM	Name in foreign language, if applicable/available
SCHADMNM	State/Province name to which the populated place belongs in upper case with 
spaces and special characters removed
ADMNM1	State/Province which the populated place falls within, if available
ADMNM2	Second level administrative unit (county/district) which the populated place falls 
within, if available
TYPE		Populated place type or designation if specified (C means census)
SRCTYP	Population type or designation if specified
COORDSRCE	Name of the source of geographic coordinates of the populated place
DATSRC	Name of data source (population estimate and name)
LOCNDATSRC	Link to the geographic coordinate source
NOTES		Notes on edits, sources, and extraplations of poplation values


PROJECTION

These data are stored in geographic coordinates of decimal degrees based
on the World Geodetic System spheroid of 1984 (WGS84).


NOTES

Some names may appear to be mis-spelled or truncated. We hope to verify spellings and names in 
future versions. If you have questions about a particular place name, please contact us.

The publicly released Settlement Points dataset includes places with a population of 1000 
persons and larger. 

For the development of the GRUMP population grids, points representing settlements smaller 
than 1000 persons were also used, where available and appropriate.


DATA RESTRICTIONS

These data are for noncommercial use only. No third party distribution of all, 
or parts, of the electronic files is authorized. The data used in the creation of 
this dataset were provided to CIESIN by the organizations identified in the source data.


DATA ERRORS, CORRECTIONS AND QUALITY ASSESSMENT

CIESIN follows procedures designed to ensure that data disseminated by CIESIN 
are of reasonable quality. If, despite these procedures, users encounter 
apparent errors or misstatements in the data, please contact CIESIN 
Customer Services at 845/365-8920 or via Internet e-mail at 
ciesin.info@ciesin.columbia.edu. Neither CIESIN nor NASA verifies or guarantees
the accuracy, reliability, or completeness of any data provided.


NO WARRANTY OR LIABILITY

CIESIN provides this data without any warranty of any kind whatsoever, either 
express or implied. CIESIN shall not be liable for incidental, consequential, 
or special damages arising out of the use of any data provided by CIESIN.