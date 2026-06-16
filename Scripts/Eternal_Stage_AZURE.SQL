
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
CREATE OR REPLACE FILE FORMAT CSV_FORMAT_NEW
                                        Type = CSV
                                        SKIP_HEADER = 1
                                        FIELD_DELIMITER = ','
                                        RECORD_DELIMITER = '\n'
                                        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
                                        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;


-- STEP 3: External Stage -- Tells Snowflake where Files are Located

CREATE OR REPLACE STAGE Azure_Ext_Stg
    STORAGE_INTEGRATION = azure_storage_integration
    URL = 'azure://lalitsa.blob.core.windows.net/source/'
    FILE_FORMAT = CSV_FORMAT_NEW
    ;

-- Check Connection
 LIST @Azure_Ext_Stg;


 -- See Data from Stage
 Select $1, $2, $3, metadata$filename from @Azure_Ext_Stg limit 5;


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


-- Load data

COPY INTO Financials
FROM @Azure_Ext_Stg/FinancialSampleCSV.csv;

-- Finally
Select * from Financials;


*************************************************************************************

-- Table >>> Stage

COPY INTO @Azure_Ext_Stg
FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

List @Azure_Ext_Stg;



 

 



    
