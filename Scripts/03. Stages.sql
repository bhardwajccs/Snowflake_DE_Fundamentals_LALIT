-- STAGES in SNOWFLAKE

-- User Stage 
-- No Set UP and No Storage Limit.
-- No Alter 
-- No File Format needed to make these Stages
-- In Projects make this Stage to Store private data that you want No one lese able to Access.
-- Not even ACCOUNTADMIN / SECURTIYADMIN can access this Stage
-- Use it if Files to be accessed by Single User but need to be copied into many tables.

LIST @~ ;



-- Table Stage
-- AUTO. created when we make a Table.
-- This Stage is OWNED by Table Owner.
-- No File Format needed to make these Stages
-- Don't support transofrmations while Loading data into This Stage.
-- Use it if Files needed to be copied in to single table but files to be used by many users.

Create or replace table EmpStage22(ID int, Name varchar)
List @%EmpStage22;    -- We can see all Staged Files here.

PUT file:///path/to/employee.csv @%EmpStage22;

List @%EmpStage22;

-- This Now works here

SHOW STAGES;


 -- INTERNAL and EXTERNAL Stages
 
 -- INTERNAL Stages
 
 -- used when multiple files to be used by multiple Users and load into multiple Tables.

SHOW STAGES -- Only Shows INTERNAL and EXTERNAL Stages

/******************************
 -- INTERNAL Stage
 ******************************/
 
CREATE OR REPLACE STAGE Stage_Demo

LIST @Stage_Data  -- How many Files in Stage

DESC STAGE Stage_Data -- See different Properties of Stage

-- See data of a Files in Stage

Select $1,$2,$3,$4 from @Stage_Data limit 3

-- See data of specific File

Select $1,$2,$3,$4 from @Stage_Data/FinancialSampleCSV.csv

-- How to Skip Headers as they are coming as 1st ROW
-- Make a File Format

CREATE OR REPLACE FILE FORMAT CSVTYPE
TYPE = 'CSV'
SKIP_HEADER = 1;

-- Modify the Stage using this File Format

CREATE OR REPLACE STAGE Stage_Demo
FILE_FORMAT = CSVTYPE

-- Reload data into Stage as Old data is gone.

Select $1,$2,$3,$4 from @Stage_Data/FinancialSampleCSV.csv


--------------------------
-- PRODUCTION Side
-------------------------
 
-- STEP:1  In Real make a STAGE without any file format -- then it can take all types of Files Ingestion

-- acts like Directory

CREATE OR REPLACE STAGE landing_zone_stage;

-- STEP 2: Make multiple File Formats

-- Format for delimited files
CREATE OR REPLACE FILE FORMAT ff_csv
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null');   -- Converst String ['Null' , 'null'] >>>  SQL [NULL]

-- Format for semi-structured JSON
CREATE OR REPLACE FILE FORMAT ff_json
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;    -- Removes Outer Array [{}, {}, {}] >>> {},{}

-- Format for columnar Parquet
CREATE OR REPLACE FILE FORMAT ff_parquet
  TYPE = 'PARQUET';


-- STEP 3: When moving data from your raw landing stage into Snowflake tables
COPY INTO target_csv_table
FROM @landing_zone_stage
FILE_FORMAT = (FORMAT_NAME = 'ff_csv')
PATTERN = '.*\.csv'; -- Ingests only CSV files








