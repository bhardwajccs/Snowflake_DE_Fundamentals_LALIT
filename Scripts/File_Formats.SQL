
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


