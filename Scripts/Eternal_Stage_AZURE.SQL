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


-- We See
-- AZURE_TENANT_ID -- (We take from Azure and Put in Storage Integration iN SNOWFLAKE)
-- AZURE_Consent_URL -- Clink on It and Give Consent
-- Azure_Multi_Tenant_App_Name -- Is taken from SF and Put in AZURE -- IAM -  82hxnxsnowflakepacint_1775951059616 
    -- SA > IAM > Blob / Storage Account > New Role > Search "BLOB Stoarge Data Contributor " > Add Member = 82hxnxsnowflakepac
-- Above Steps are TWO Way Handshake b/n AZURE and SNOWFLAKE.

DESCRIBE INTEGRATION Azure_SI


-- Make File Format
CREATE or replace FILE FORMAT INGEST_DATA_Ext
                                        Type = CSV
                                        SKIP_HEADER = 1
                                        
                                        
-- Make External Stage
CREATE OR REPLACE STAGE Stage_Ext
URL = 'azure://extstgacc.blob.core.windows.net/filedata' -- Container URL -- Replace https w azure in URL
FILE_FORMAT = INGEST_DATA_Ext
STORAGE_INTEGRATION = Azure_SI;

-- Handshake Works Now BETWEEM Azure and SF
LIST @Stage_Ext;


-- See data in Stage
Select $1,$2 from  @Stage_Ext

SHOW Tables;

-- Load into Table
COPY INTO Courses FROM @Stage_Ext

-- Check Data
Select Count(*) from COURSES;

Select * from COURSES;



-- SNOWPIPE

-- Many Files are Landing in Staging area in Blob Container -- Daily
-- Ingest all files Auto. via SNOWPIPE -- No COPY INTO Mannually

-- Make PIPE

-- SF Comes to know about new files in Blob vai NOTIFICATIONS
-- Make INTEGRATION NOTIFICATION
CREATE OR REPLACE NOTIFICATION INTEGRATION Azure_Pipe_NI
  ENABLED = TRUE
  TYPE = QUEUE
  NOTIFICATION_PROVIDER = 'AZURE_STORAGE_QUEUE'
  AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://extstgacc.queue.core.windows.net/' -- Azure > SA > Events > Not working
  AZURE_TENANT_ID = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'


-- Do same steps as we did in STORAGE INTEGRATION
DESCRIBE INTEGRATION Azure_Pipe_NI
  
-- PIPE
CREATE PIPE Azure_Pipe
AUTO_INGEST = TRUE
INTEGRATION = 'Azure_Pipe_NI'
AS
COPY INTO Courses 
    FROM @Stage_Ext
    FILE_FORMAT = (FORMAT_NAME = INGEST_DATA_Ext);


LIST @Stage_Ext;


-- While Loading Data from Stage how Stage will Tell SF i have Messgaes / Data to be laoded
-- Via Messgae Events

-- Copy Notification Channel
SHOW PIPES;
