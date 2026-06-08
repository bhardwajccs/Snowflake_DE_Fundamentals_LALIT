/*

/*

Azure Blob Storage
        │
        ▼
Azure Event Grid
        │
        ▼
Azure Storage Queue
        │
        ▼
Snowflake Notification Integration
        │
        ▼
Snowpipe (AUTO_INGEST = TRUE)
        │
        ▼
Snowflake Target Table

Note: When a file lands in Azure Blob Storage, Azure Event Grid sends a message to a Storage Queue. Snowpipe listens to that queue and automatically loads the file into Snowflake.



PROCESS
A process will dump the data in a certain format onto Azure Blob Storage while at the same time Snowflake will read from the same storage and load the data to our target table.

Needed ?


AZURE
    
    Blob SA
    Queue -- that LOGs Availability of new data
    Event Grid service for event handling

Snowflake:

    Optional: File format
    Azure Extyernal Stage
    Storage integration (Azure)
    Notification integration (Azure)
    Table to load the data
    Pipe to continuously check for new data and load it
    

*/


-- Tenant ID: 5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8
-- Storage Account Container Path(s): azure://lalitsa.blob.core.windows.net/snowpipecontainer/
    -- Later Snowflake will generate consent URLs to actually get access t
-- Storage Queue URL: https://lalitsa.queue.core.windows.net/snowpipequeue
    -- TO Store the event messages from the Event Grid. 



-- 1. Snowflake Storage Integration
    -- Secure Snowflake object that connects Snowflake to your external cloud storage.

CREATE OR REPLACE STORAGE INTEGRATION azure_storage_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'
    STORAGE_ALLOWED_LOCATIONS = 
    ('azure://lalitsa.blob.core.windows.net/snowpipecontainer/')
    ;


-- 1.1 Grant Snowflake to access to Storage Locations on Azure. SF Generates consent url that we can simply visit and grant access. 

-- AZURE_CONSNET_URL -- Send Link to ADMIN and ask them to accept the consent request.
    -- They should also grant the following ROLES to the Snowflake Service Principal.

    -- Storage Blob Data Reader (read only access)
    -- Storage Blob Data Contributor (read and write access)

-- AZURE_MULTI_TENANT_APP_NAME = Name of the Snowflake client application created for your account.
    -- Azure Services » Storage Accounts >> Access Control (IAM) » Add role assignment.>> "Storage Blob Data Contributor" >Add Member.

DESC STORAGE INTEGRATION azure_storage_integration;

-- Storage Integration Completed.



-- 2. Notification Integration

CREATE OR REPLACE NOTIFICATION INTEGRATION Azure_Notification_Int
    ENABLED = TRUE
    TYPE = QUEUE
    NOTIFICATION_PROVIDER = AZURE_STORAGE_QUEUE
    AZURE_TENANT_ID = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'
    AZURE_STORAGE_QUEUE_PRIMARY_URI = 'https://lalitsa.queue.core.windows.net/snowpipequeue'
    ;

SHOW NOTIFICATION INTEGRATIONS;

-- 2.1 Grant Snowflake Access to the Storage Queue
    
    -- SA > Data Storage > Queues > Make and copy URL 

-- Note: We follow similar steps to generate a consent url, accept the consent request and grant the snowflake app Storage Queue Data Contributor role.

DESC NOTIFICATION INTEGRATION Azure_Notification_Int;

    -- Azure Services » Storage Accounts >> Access Control (IAM) » Add role assignment.>> "Storage Queue Data Contributor" >Add Member.


-- 3 EVENET NOTIFICATION


-- 4. Make FILE FORMAT


CREATE OR REPLACE FILE FORMAT CSV_FORMAT
                                        Type = CSV
                                        SKIP_HEADER = 1
                                        FIELD_DELIMITER = ','
                                        RECORD_DELIMITER = '\n'
                                        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
                                        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- 5. External stage: this tells snowflake where our files are located.

CREATE OR REPLACE STAGE Azure_Ext_Stg
    STORAGE_INTEGRATION = azure_storage_integration
    URL = 'azure://lalitsa.blob.core.windows.net/snowpipecontainer'
    FILE_FORMAT = CSV_Format
    ;
-- 5. 


-- 6. SnowPipe Deff.

CREATE OR REPLACE PIPE MySnowPipe
    AUTO_INGEST = TRUE
    INTEGRATION = Azure_Notification_Int
    AS 
    COPY INTO SNOWSQL.RAW_LAYER.Financials
    FROM @Azure_Ext_Stg
    FILE_FORMAT = CSV_Format
    ;


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


-- TEST
-- Drop File in Blob and see if Data loaded into Table


SELECT * FROM Financials;


List @Azure_Ext_Stg

-- Pipe Status
SELECT SYSTEM$PIPE_STATUS('MySnowPipe');

-- Mannually RUN Pipr
ALTER PIPE MySnowPipe refresh;


-- LOGs
SELECT *
FROM TABLE(
    INFORMATION_SCHEMA.COPY_HISTORY(
        TABLE_NAME=>'FINANCIALs',
        START_TIME=>DATEADD(HOUR,-24,CURRENT_TIMESTAMP())
    )
)
ORDER BY LAST_LOAD_TIME DESC;

