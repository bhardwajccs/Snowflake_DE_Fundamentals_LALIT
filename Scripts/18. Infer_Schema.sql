
-- External Stage -- AZURE


-- STEP 1: Make Storage Integration

CREATE OR REPLACE STORAGE INTEGRATION azure_storage_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'
    STORAGE_ALLOWED_LOCATIONS = 
    ('azure://lalitsa.blob.core.windows.net/source/')
    ;

-- Step 1.1  
-- Give permissions
-- SA > IAM > Add Role > Storage Blob data Contributor > Select Members > Add Multi-tenant App name > Assign permissions
DESC Storage Integration azure_storage_integration;

-- STEP 2: File FORMAT
CREATE OR REPLACE FILE FORMAT PARQUET_Format
 Type = PARQUET;


-- STEP 3: External Stage -- Tells Snowflake where Files are Located

CREATE OR REPLACE STAGE Azure_Ext_Stg_Open
    STORAGE_INTEGRATION = azure_storage_integration
    URL = 'azure://lalitsa.blob.core.windows.net/source/'
    ;

-- Check Connection
 LIST @Azure_Ext_Stg_Open;

-- Read the data
Select * from @Azure_Ext_Stg_Open/house-price.parquet (FILE_FORMAT => 'PARQUET_Format');

-- INFER SCHEMA()
SELECT * FROM TABLE(
                INFER_SCHEMA(
                    LOCATION => '@Azure_Ext_Stg_Open',
                    FILE_FORMAT => 'PARQUET_Format',
                    -- FILES => 'house-price.parquet'
                    IGNORE_CASE => TRUE
                )
            );
 
-- CTAS

CREATE OR REPLACE TABLE Inferred_Schema
  USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) 
        FROM TABLE(
                    INFER_SCHEMA(
                        LOCATION => '@Azure_Ext_Stg_Open',
                        FILE_FORMAT => 'PARQUET_Format',
                        IGNORE_CASE => TRUE
                    )
                )
            );

SHOW TABLES;

-- LOAD DATABASE

COPY INTO Inferred_Schema
FROM @Azure_Ext_Stg_Open
FILE_FORMAT = 'PARQUET_Format'
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

Select * from Inferred_Schema;








 

 



    
