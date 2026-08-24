/*********************************************

-- EXTERNAL STAGE

*******************************************/

CREATE DATABASE TestDB

Create Schema TestDB.TestSchema


-- STEP 1: 

-- Snowflake Storage Integration 

-- for Secure Snowflake to read Blob Storage.

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


-- STEP 6:

-- Move Data

COPY INTO Financials FROM @Azure_Ext_Stg_New;


-- Verify Data

Select * from Financials;
