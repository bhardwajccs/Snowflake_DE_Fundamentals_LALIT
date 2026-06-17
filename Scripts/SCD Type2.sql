-- SCD Type 1 and TYPE 2


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


 -- Stage Table
 CREATE OR REPLACE TABLE Financials_STG(
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


-- Silver Layer Table
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


-- dimension
-- Silver Layer Table
CREATE OR REPLACE TABLE dimFinancials(
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
                                            Filename varchar,          -- Metadata extra column we added,
                                            StatusFlag boolean,
                                            StartDate date,
                                            EndDate date
                                            );


-- Do AUTO.
-- As SFNOWFLAKE doesn't allow Loading same file againa and again -- OR Forcefully we can Load but we can TRUNCATE w Task.
CREATE OR REPLACE TASK CLEAN_STAGE_TABLE
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = '1 MINUTE'
AS
    TRUNCATE TABLE Financials_STG;


-- Load Stage data
CREATE OR REPLACE TASK LOAD_STAGE_DATA
    WAREHOUSE = COMPUTE_WH
    AFTER CLEAN_STAGE_TABLE
AS
    COPY INTO Financials_STG FROM @Azure_Ext_Stg 
        FILE_FORMAT = CSV_FORMAT_NEW;


-- Silver Layer -- TYPE1 SCD
CREATE OR REPLACE TASK Financials_SCD1_Load
    WAREHOUSE = COMPUTE_WH
    AFTER LOAD_STAGE_DATA
AS
MERGE INTO FINANCIALS fin
USING (SELECT * FROM Financials_STG) src
ON fin.segment = src.segment and fin.country = src.country
WHEN MATCHED AND (fin.Mobile != src.Mobile)
THEN 
    UPDATE SET fin.Mobile = src.Mobile
WHEN NOT MATCHED THEN
    INSERT ALL BY NAME;      -- If same columns in both source and destination tables
    -- INSERT(fin.segement, fin.country.....) VALUES (src.segement, src.country....)


ALTER TASK CLEAN_STAGE_TABLE RESUME;
ALTER TASK LOAD_STAGE_DATA RESUME;
ALTER TASK Financials_SCD1_Load RESUME;

SHOW TASKS;

SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY());

-- Upload File

Select * from FINANCIALS_STG;
Select * from FINANCIALS;


ALTER TASK CLEAN_STAGE_TABLE SUSPEND;

-- SCD TYPE 2

-- Create STREAM on Top of TYPE1 Table in SILVER LAYER -- so that we can capture the changes from Stream.
-- Work from here ???

CREATE OR REPLACE STREAM ON TABLE Financials_STM;

Select * from Financials_STM;

-- Task
CREATE OR REPLACE TASK dimFinancials_LOAD
    WAREHOUSE = COMPUTE_WH
    AFTER Financials_SCD1_Load       -- TRGIGGER Based task as it works only if STREAM has data
    WHEN SYSTEM$STREAM_HAS_DATA('Financials_STM')
AS

MERGE INTO dimFinancial dimF
USING (
    SELECT *
    FROM Financials_STM
) chk
ON dimF.segment = chk.segment
AND dimF.country = chk.country

WHEN MATCHED
     AND (chk.metadata$action = 'DELETE')
THEN
    UPDATE SET
        dimF.EndDate = CURRENT_DATE,
        dimF.StatusFlag = 'False'

WHEN NOT MATCHED
     AND (chk.metadata$action = 'INSERT')
THEN
    -- INSERT ALL BY NAME;
    INSERT (
        dimF.Segment,
        dimF.Country,
        dimF.Product,
        dimF.Discount Band,
        dimF.Units Sold,
        dimF.Manufacturing Price,
        dimF.Sale Price,
        dimF.Gross Sales,
        dimF.Discount,
        dimF.Sales,
        dimF.COGS,
        dimF.Profit,
        dimF.Date
        dimF.Month Number
        dimF.Month Name
        dimF.Year
        dimF.__PowerAppsId__
        dimF.Mobile,
        dimF.StartDate,
        dimF.StatusFlag
    )
    VALUES (
        chk.Segment,
        chk.Country,
        chk.Product,
        chk.Discount Band,
        chk.Units Sold,
        chk.Manufacturing Price,
        chk.Sale Price,
        chk.Gross Sales,
        chk.Discount,
        chk.Sales,
        chk.COGS,
        chk.Profit,
        chk.Date
        chk.Month Number
        chk.Month Name
        chk.Year
        chk.__PowerAppsId__
        chk.Mobile,
        CURRENT_DATE,
        'True'
    );


