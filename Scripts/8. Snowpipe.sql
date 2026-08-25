/*

Snowpipe is Snowflake's continuous data ingestion service. It automates loading data from files into Snowflake tables as soon as they become available in cloud storage, eliminating the need for manual scheduling or large, periodic batch loads

No Manual COPY INTO -- It's Real-Time Pipelines -- No Scheduler / CRON Jobs is needed.

Files Arrives >>> Snowpipe is Triggered as it receives Notification from Bucket >>> Data is loaded.

Snowpipe uses Serveless means you do not pay per-cluster-uptime. Instead, Snowpipe is billed directly per gigabyte (GB) of data ingested.


    
Azure Blob Storage                  -- Files Lands
        │
        ▼
Azure Event Grid                    -- It sends a message to a Storage Queue. 
        │
        ▼
Azure Storage Queue       
        │
        ▼
Snowflake Notification Integration   -- Snowflake Listens to Storage Queue
        │
        ▼
Snowpipe (AUTO_INGEST = TRUE)        -- Triggered
        │
        ▼
Snowflake Target Table               -- Data Loaded


HOW

Upload CSV to Azure Blob Folder
          ↓
Azure Event Grid fires event
          ↓
Azure Storage Queue receives message
          ↓
Snowflake Notification Integration reads queue
          ↓
Snowpipe executes COPY INTO
          ↓
Data appears in table





-- Requirements

AZURE
    SA
    TenantID     = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'
    ContainerURL = 'azure://lalitsa.blob.core.windows.net/source/'
    Azure Storage Queue URL = https://lalitsa.queue.core.windows.net/snowpipequeuenew
    
    


SNOWFLAKE
    Table
    Storage Integration
    Notification Integration
    File Format
    Stage
    COPY INTO


*/


CREATE OR REPLACE STORAGE INTEGRATION azure_storage_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'
    STORAGE_ALLOWED_LOCATIONS = ('azure://lalitsa.blob.core.windows.net/source/')   -- replace https w azure
    ;


-- STEP 2

-- Grant Snowflake to access to Storage Locations on Azure.

-- To SNOWFLAKE APP give
-- Azure Services » Storage Accounts >> Access Control (IAM) » Add role assignment.>> Add below 2 Roles > Add Member > Add SF App.

    -- Storage Blob Data Reader (read only access)
    -- Storage Blob Data Contributor (read and write access)

DESC Storage Integration azure_storage_integration;



-- STEP 3: 

-- File FORMATs

CREATE OR REPLACE FILE FORMAT CSV_FORMAT_NEW
                                        Type = CSV
                                        SKIP_HEADER = 1
                                        FIELD_DELIMITER = ','
                                        RECORD_DELIMITER = '\n'
                                        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
                                        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- STEP 4:

-- External Stage

CREATE OR REPLACE STAGE Azure_Ext_Stg_New
    STORAGE_INTEGRATION = azure_storage_integration
    URL = 'azure://lalitsa.blob.core.windows.net/source/'
    FILE_FORMAT = CSV_FORMAT_NEW
    ;


-- LIST Stage Files.

LIST @Azure_Ext_Stg_New

Select $1, $2, $3, metadata$filename from @Azure_Ext_Stg_New limit 20;


-- STAGE 5

-- Snowflake Table

CREATE OR REPLACE TABLE Financials(
                                            Segment varchar,
                                            Country varchar,
                                            Product varchar,
                                            DiscountBand varchar,
                                            UnitsSold varchar,
                                            ManufacturingPrice varchar,
                                            SalePrice varchar,
                                            GrossSales varchar,
                                            Discount varchar,
                                            Sales varchar,
                                            COGS varchar,
                                            Profit varchar,
                                            Date varchar,
                                            MonthNumber varchar,
                                            MonthName varchar,
                                            Year varchar,
                                            __PowerAppsId__ varchar,
                                            Filename varchar          -- Metadata extra column we added
                                            );



-- Stage 6

-- SF Need Notification Integraion -- for Snowflake to read Azure Queue messages

-- SET UP Event on Azure

--1. Register Event Grid in Azure from Azure CLI
            -- type =     az provider register --namespace Microsoft.EventGrid
            -- type =     az provider show --namespace Microsoft.EventGrid --query "registrationState"          -- Enter


         
--2  Storage Account >>> Events >>> New >>> Create Queue 

-- 3. Copy QueueURL -- From SA >>> Queue

CREATE OR REPLACE NOTIFICATION INTEGRATION Azure_Notification_Int
    ENABLED = TRUE
    TYPE = QUEUE
    NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
    AZURE_TENANT_ID = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'
    AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://lalitsa.queue.core.windows.net/snowqueue'
    ;

DESC INTEGRATION Azure_Notification_Int;
-- Follow same steps like SI
-- SA > IAM > Storage Queue Data Contributor > Add



-- STEP 7: SNOWPIPE

CREATE PIPE Azure_Snowpipe
    AUTO_INGEST = TRUE
    INTEGRATION = Azure_Notification_Int
    AS
    COPY INTO Financials FROM @Azure_Ext_Stg;



Select * from Financials;


TRUNCATE TABLE Financials;

-- Dump some files in Blob -- Wait minutes

-- Azure Snowpipe Status
SELECT SYSTEM$PIPE_STATUS('Azure_Snowpipe');
