-- SCD Type1,2
-- w Tasks and Streams

CREATE OR REPLACE FILE FORMAT CSVONE
TYPE = CSV  -- Default Value
SKIP_HEADER = 1
FIELD_DELIMITER = ','
RECORD_DELIMITER = '\n'
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

ALTER FILE FORMAT CSVONE
SET date_format = 'yyyy-mm-dd';


CREATE OR REPLACE STORAGE INTEGRATION Azure_SI
TYPE = external_stage
STORAGE_PROVIDER = azure
ENABLED = TRUE
AZURE_TENANT_ID = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'   -- Copy from Azure Home Account
STORAGE_ALLOWED_LOCATIONS = ('azure://extstgacc.blob.core.windows.net/filedata/');


DESC Integration Azure_SI;

CREATE OR REPLACE STAGE Stage_Ext
URL = 'azure://extstgacc.blob.core.windows.net/filedata/' -- Container URL -- Replace https w azure in URL
FILE_FORMAT = CSVONE
STORAGE_INTEGRATION = Azure_SI;

SHOW Stages;

LIST @Stage_Ext;

CREATE OR REPLACE TABLE STG_Courses
    (
        CName Varchar,
        Trainer Varchar
    );


-- TYPE1

CREATE OR REPLACE TABLE Courses_Type1
    (
        CName Varchar,
        Trainer Varchar
    );

-- TYPE2 Data
CREATE OR REPLACE TABLE Courses_Type2
    (
        CName Varchar,
        Trainer Varchar,
        Start_Date date,
        End_date Date DEFAULT date '2000-10-23',
        Is_Active Boolean
    );

Select current_date();

-- TASK1 -- AUTOMATE Truncation every 1 Minute
CREATE OR REPLACE TASK Clean_Stage_Table
Warehouse = 'COMPUTE_WH'
SCHEDULE = '1 minute'
AS
TRUNCATE TABLE STG_COURSES;

-- Task2
-- This is Child task RUNS After Parent task 1
-- LOAD Stage Table from Blob File

CREATE OR REPLACE TASK LOAD_STAGE_DATA
WAREHOUSE = COMPUTE_WH
AFTER Clean_Stage_Table
AS
COPY INTO STG_COURSES
   FROM @Stage_ExtL;

-- Child task 2
-- Insert Data Into Silver Layer -- TYPE1

Select * from COURSES_TYPE1;

CREATE OR REPLACE TASK Courses_Typ1_LOAD
WAREHOUSE = COMPUTE_WH
AFTER LOAD_STAGE_DATA
AS
MERGE INTO COURSES_TYPE1 crc_1
USING (Select * from STG_COURSES) src
ON crc_1.CNAME = src.CNAME
WHEN MATCHED AND (crc_1.Trainer != src.Trainer)
THEN UPDATE SET crc_1.Trainer = src.Trainer
WHEN NOT MATCHED
THEN INSERT (crc_1.CNAME, crc_1.Trainer) VALUES (srs.CNAME,src.Trainer);

-- TASKS are SUPSNEDED
SHOW TASKS;

-- ENABLE TASKS
-- 1st ENABLE Child Tasks then PARENT Task
ALTER TASK Clean_Stage_Table RESUME;
ALTER TASK LOAD_STAGE_DATA RESUME;
ALTER TASK Courses_Typ1_LOAD RESUME;

DROP TASK Clean_Stage_Table;
DROP TASK LOAD_STAGE_DATA;
DROP TASK Courses_Typ1_LOAD;

SELEct * from STG_COURSES;
select * from COURSES_TYPE1;

-- Check is TASK Executed ?

Select * from table(INFORMATION_SCHEMA.TASK_HISTORY());

-- Check Data
SELEct * from STG_COURSES;
select * from COURSES_TYPE1;


-- TYPE 2
-- SUSPEND Mian TASK
ALTER TASK Clean_Stage_Table SUSPEND;

-- CREATE STREAM on Type_1 Table for capturing changed data values

CREATE OR REPLACE STREAM Str_CoursesType1 on Table COURSES_TYPE1;

Select * from Str_CoursesType1;

-- Final task
CREATE OR REPLACE TASK Courses_Type2_LOAD
WAREHOUSE = COMPUTE_WH
AFTER Courses_Typ1_LOAD
WHEN
SYSTEM$stream_has_data('Str_CoursesType1')
AS
MERGE INTO Courses_Type2 dest
USING (Select * from STG_COURSES) chk
ON dest.CNAME = chk.CNAME
WHEN MATCHED AND (chk.metadata$action ='DELETE')
THEN UPDATE 
       SET End_Date = current_date(),
       IS_ACTIVE = 'FALSE'
WHEN NOT MATCHED AND (chk.metadata$action ='INSERT')
THEN INSERT 
        (dest.CNAME, dest.Trainer, dest.start_date, dest.is_active) VALUES (chk.CNAME,chk.Trainer, current_date(), 'TRUE');



Select * from Courses_Type2;


ALTER TASK Clean_Stage_Table RESUME;
ALTER TASK LOAD_STAGE_DATA RESUME;
ALTER TASK Courses_Typ1_LOAD RESUME;
ALTER TASK Courses_Type2_LOAD RESUME;



Select * from Courses_Type2;

Select * from table(INFORMATION_SCHEMA.TASK_HISTORY());
