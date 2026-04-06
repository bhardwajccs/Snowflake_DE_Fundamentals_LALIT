/*

-- FILE FORMATS in Stages in SF

*/

SHOW FILE FORMATS

-- STEP_1 
CREATE OR REPLACE FILE FORMAT CSVONE
TYPE = CSV  -- Default Value
SKIP_HEADER = 1
FIELD_DELIMITER = ','
RECORD_DELIMITER = '\n'


-- Sometimes We have comma in single column -- ERROR
ALTER FILE FORMAT CSVONE
SET FIELD_OPTIONALLY_ENCLOSED_BY = '"'; -- Encloses fields in double quotes

-- When Source File and Destination Columns Not MATCH
ALTER FILE FORMAT CSVONE
SET error_on_column_count_mismatch = FALSE;

-- SF has YYYY-DD-MM FORMATS
-- to give same date format from source
ALTER FILE FORMAT CSVONE
SET date_format = 'yyyy-mm-dd'

DESC FILE FORMAT CSVONE

-- STEP_2
CREATE or replace TABLE EMPLOAD(
    Empid	int
    ,Name	varchar
    ,Email	varchar
    ,Phoneno	int
    ,Address	varchar
    ,COMPANY	varchar
    ,"Joining Date"	date
)

Select * from EMPLOAD

-- STEP_3
-- Load data into Table w above File Format w UI -- ERROR

TRUNCATE TABLE empload
drop file format csvone




/*

Semi -Structured Data

To Insert the data we need below objects
-- Data File
-- Table
-- File format
-- Stages (Table Stages here)

*/

--- For Semi-structured data we need Variant data type.
-- Make Table w one column
Create or replace table JSONDATA
(Datacolumn variant)

-- File Format
Create or replace File Format JSONTYPE
Type=JSON;

-- Load JSON File Data Titanic in JSON Folder w UI Method >>> Snowflake table
-- Titanic data in JSON Folder

Select * from JSONDATA     -- But JSN Data can't be used as it is for Reporting so need to FLATTEN Fun


/*

XML Data Loading

*/

Create or Replace table XMLData
(Datacolumn variant)

Create Or Replace File Format XMLType
Type=XML

-- Load Data

Select * from XMLDATA -- Flatten It for Usuage -- Flatten converts data into readable form.


/*

Parquet Data >>> Stage in SF

*/

-- Now Load Parquet Data into Stage -- rather than in Table
-- Format is CSV by DEFAULT in Stage

Create stage Stage_Data

-- Load parquet data into Stage
-- Check the Files in Stage -- done Loading


/*

-- Parquet File data into Table

*/

Create or replace table Parquet_Data
(datacolumn variant)

Create file format ParquetType
Type=Parquet

-- Load the data

Select * from parquet_data

-- Parsing will do later

