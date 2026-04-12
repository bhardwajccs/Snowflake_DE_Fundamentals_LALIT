-- AZURE as Externa Stage
-- Copy data into SNOWFLAKE

-- Make Table in SF
Create table Courses(Course_Name Varchar, Trainer varchar);

Select * from COURSES;

-- Make Storage INTEGRATION

CREATE STORAGE INTEGRATION Azure_SI
TYPE = external_stage
STORAGE_PROVIDER = azure
AZURE_TENANT_ID = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'   -- Copy from Azure Home Account
ENABLED = TRUE
STORAGE_ALLOWED_LOCATIONS = ('azure://extstgacc.blob.core.windows.net/filedata') ;   -- Copied from Container ...

-- Make F   ile F   ormat
CREATE or replace FILE FORMAT INGEST_DATA_Ext
                                        Type = CSV
                                        SKIP_HEADER = 1
                                        
                                        
-- Make External Stage
CREATE OR REPLACE STAGE Stage_Ext
URL = 'azure://extstgacc.blob.core.windows.net/filedata' -- Container URL -- Replace https w azure in URL
FILE_FORMAT = INGEST_DATA_Ext
STORAGE_INTEGRATION = Azure_SI;

-- We don't see anything in BLOB
-- Since still NO HANDSHAKE b/n Azure and SF
LIST @Stage_Ext

-- We See
-- AZURE_TENANT_ID -- (We take from Azure and Put in Storage Integration iN SNOWFLAKE)
-- AZURE_Consent_URL -- Clink on It and Give Consent
-- Azure_Multi_Tenant_App_Name -- Is taken from SF and Put in AZURE -- IAM -  82hxnxsnowflakepacint_1775951059616 
    -- IAM > Blob / Storage Account > New Role > Search "BLOB Stoarge Data Contributor " > Add Member = 82hxnxsnowflakepac
-- Above Steps are TWO Way Handshake b/n AZURE and SNOWFLAKE.

DESCRIBE INTEGRATION Azure_SI

-- Handshake Works Now
LIST @Stage_Ext;

-- See data in Stage
Select $1,$2 from  @Stage_Ext

SHOW Tables;

-- Load into Table
COPY INTO Courses FROM @Stage_Ext

-- Check Data
Select * from COURSES;



