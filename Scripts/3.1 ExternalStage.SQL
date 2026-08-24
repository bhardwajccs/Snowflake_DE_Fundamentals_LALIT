/*********************************************

-- EXTERNAL STAGE

*******************************************/

CREATE DATABASE TestDB

Create Schema TestDB.TestSchema


-- STEP 1: Make Storage Integration

CREATE OR REPLACE STORAGE INTEGRATION azure_storage_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = '5df7bfe8-c66e-4465-9a6b-7636fd5c6dd8'
    STORAGE_ALLOWED_LOCATIONS = ('azure://lalitsa.blob.core.windows.net/source/')
    ;

DESC Storage Integration azure_storage_integration;



-- STEP 2: File FORMAT
CREATE OR REPLACE FILE FORMAT CSV_FORMAT_NEW
                                        Type = CSV
                                        SKIP_HEADER = 1
                                        FIELD_DELIMITER = ','
                                        RECORD_DELIMITER = '\n'
                                        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
                                        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;



CREATE OR REPLACE STAGE Azure_Ext_Stg_New
    STORAGE_INTEGRATION = azure_storage_integration
    URL = 'azure://lalitsa.blob.core.windows.net/source/'
    FILE_FORMAT = CSV_FORMAT_NEW
    ;

 LIST @Azure_Ext_Stg_New

Select $1, $2, $3, metadata$filename from @Azure_Ext_Stg_New limit 20;

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


    COPY INTO Financials FROM @Azure_Ext_Stg_New;

    Select * from Financials;
