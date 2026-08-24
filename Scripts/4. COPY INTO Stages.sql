SHOW STAGES;

List @Azure_Ext_Stg_New

-- Remove all files from @STG_CSV
REMOVE @Azure_Ext_Stg_New;


-- Move Data from SF Tables into Stages  -- COPY INTO -- Downloading


SELECT * FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

COPY INTO @Azure_Ext_Stg_New FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- File names are system generated like data_0_0_0.csv, then 0_1_0 ...
LIST @Azure_Ext_Stg_New

-- Custom relevant File name
-- And loading all data into One File only.
COPY INTO @Azure_Ext_Stg_New/Customerdata.csv 
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 
    SINGLE = TRUE              -- While Unloading data how many files want to create.
    MAX_FILE_SIZE = 17000000   -- DEFAULT = 16 MB   -- MAX = 5 GB    (In EXTERNAL Cloud like AWS)
    OVERWRITE = TRUE;          -- To Reload Data agaian in Same File

LIST @Azure_Ext_Stg_New

Select $1, $2 from @STG_CSV/Customer.csv (FILE_FORMAT => 'CSV_TYPE');

-- If we Want "Query ID" in File Name
-- QUERY ID don't work w SINGLE = TRUE and OVERWRITE = TRUE

COPY INTO @STG_CSV/Customer.csv 
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 
-- SINGLE = TRUE
Include_Query_ID = TRUE
MAX_FILE_SIZE = 17000000   
-- OVERWRITE = TRUE;         

LIST @STG_CSV;


-- When we want to COUNT Records in each File in Stage
-- DETAILED_OUTPUT = TRUE



COPY INTO @Azure_Ext_Stg_New/Customerdata_2.csv
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 
    DETAILED_OUTPUT = TRUE
    HEADER = TRUE       -- To see Col names
    OVERWRITE = TRUE;


-- Data VALIDATION Before Unlaoding into STAGE

COPY INTO @Azure_Ext_Stg_New/CustomerValidation.csv 
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 
    VALIDATION_MODE = RETURN_ROWS;    -- check

LIST @STG_CSV; -- 13 Files

-- Load Data
COPY INTO @STG_CSV/CustomerValidation.csv 
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 




-- Unloading into Stages only Supports CSV / JSON / PARQUET Only;

-- COPY FILES INTO FROM -- INTERNAL Stage <> EXTERNAL STAGES

CREATE STAGE Stage_Data;

show stages;

COPY FILES INTO @Stage_Data FROM @STG_CSV; 

List @Stage_data;
