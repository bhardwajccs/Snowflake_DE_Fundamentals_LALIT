SHOW STAGES;

-- Remove all files from Stage
REMOVE @STG_CSV;

COPY INTO @STG_CSV FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

-- File names are system generated like data_0_0_0.csv, then 0_1_0 ...
LIST @STG_CSV;

-- Custom relevant File name
-- And loading all data into One File onloy
COPY INTO @STG_CSV/Customer.csv 
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 
SINGLE = TRUE
MAX_FILE_SIZE = 17000000   -- DEFAULT = 16 MB   -- MAX = 5 GB    (In EXTERNAL Cloud like AWS)
OVERWRITE = TRUE;          -- To Reload Data agaian in Same File


-- If we Want "Query ID" in File Name
-- QUERY ID don't work w SINGLE = TRUE and OVERWRITE = TRUE

COPY INTO @STG_CSV/Customer.csv 
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 
-- SINGLE = TRUE
Include_Query_ID = TRUE
MAX_FILE_SIZE = 17000000   -- DEFAULT = 16 MB   -- MAX = 5 GB    (In EXTERNAL Cloud like AWS)
-- OVERWRITE = TRUE;          -- To Reload Data agaian in Same Fi

LIST @STG_CSV;


-- When we want to COUNT Records in each File in Stage
-- DETAILED_OUTPUT = TRUE

COPY INTO @STG_CSV/CustomerCount.csv 
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 
DETAILED_OUTPUT = TRUE
HEADER = TRUE;              -- To see Col names


-- VALIDATING what Data will be Loaded in STAGE -- Befroe Loading

COPY INTO @STG_CSV/CustomerValidation.csv 
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 
VALIDATION_MODE = RETURN_ROWS;

LIST @STG_CSV; -- 13 Files

-- Load Data
COPY INTO @STG_CSV/CustomerValidation.csv 
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER 


-- Unloading into Stages only Supports CSV / JSON / PARQUET Only;

-- Copy Files INTERNAL Stage <> EXTERNAL STAGES
-- COPY FILES INTO FROM

CREATE STAGE Stage_Data;

show stages;

COPY FILES INTO @Stage_Data FROM @STG_CSV; 

List @Stage_data;


