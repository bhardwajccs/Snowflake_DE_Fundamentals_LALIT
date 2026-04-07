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
List @%EmpStage22;




 -- INTERNAL and EXTERNAL Stages
 -- INTERNAL Stages
 -- used when multiple files to be used by multiple Users and load into multiple Tables.

SHOW STAGES -- Only Shows INTERNAL and EXTERNAL Stages

CREATE STAGE Stage_Demo

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








