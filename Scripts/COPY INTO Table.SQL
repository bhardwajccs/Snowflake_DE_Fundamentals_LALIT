-- SNOWSQL --

USE DATABASE SNOWSQL

USE SCHEMA RAW_LAYER;

SHOW STAGES;

SHOW FILE FORMATS;

/*

-- Problem:- Insert file data from Staging into SF Table

we need File
we need Table in SF
We need File Format            -- Created above
we need Stages w that File format
Upload Files at this Stage
We need COPY INTO Table command


*/

-- Make File Format
CREATE FILE FORMAT INGEST_DATA
                                        Type = CSV
                                        SKIP_HEADER = 1
                                        FILED_DELIMITER = ','
                                        RECORD_DELIMITER = '\N'
                                        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
                                        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

SHOW FILE FORMATS;

-- Make Stage w File Format
CREATE OR REPLACE STAGE STG_CSV
                                        FILE_FORMAT = INGEST_DATA;
                                        
-- Make Table
CREATE OR REPLACE TABLE Financial_Lalit(
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


-- Load File into Stage
PUT 'file://C:/Users/lbhardwaj/OneDrive - California Creative Solutions, Inc/Data_Backup_Cloud_Lalit/Lalit
                                        BI/Lalit Business Intelligence CCS/Module7=PowerBI/Data Sets/Datasets_Lalit_Training/FinancialSampleCSV.csv
                                        ' @STG_CSV;

-- Verify
LIST @STG_CSV;

-- COPY INTO
-- But before Moving data Stage >>> table , first we want to find all currupt records.
     -- VIA "VALIDATION_MODE = RETURN_ALL_ERRORS";
     -- It Validates the data aganist the File Format and gives records w Errors;
     -- Then chnage the Metadata of columns in Destination table.

     -- Still if there is Dirty data in Cells
     -- Use "ON_ERROR = SKIP / CONTINUE"

-- Check / Verify
COPY INTO Financial_Lalit FROM @STG_CSV
VALIDATION_MODE = RETURN_ALL_ERRORS;

-- Load Data
-- Error Data will be skipped, Rest Loaded.
COPY INTO Financial_Lalit FROM @STG_CSV
ON_ERROR = continue;

Select * from Financial_Lalit;

-- If we Rerun same command again
-- It will not load the file again as SF keeps the Metadata.
COPY INTO Financial_Lalit FROM @STG_CSV
ON_ERROR = continue;

-- But Data may have changed in Source
-- FORCE = TRUE; -- PROIPERTY
-- It will Load same data agaian including new data.

COPY INTO Financial_Lalit FROM @STG_CSV
ON_ERROR = continue
FORCE = TRUE;


-- How to remove the Files from Stages -- Once Data loaded into Table

LIST @STG_CSV;


-- Sometimes Source Date values doesn't match with SF Dates (SF has "yyyy-mm-dd")
-- While making FILE FORMAT use "Date_Format = DD/MM/YYYY"  -- Keep this value same as is coming from Source Date Values
-- Alter the FILE FORMAT Code
-- Now Also ALTER the Stage
-- Load data into Stage -- all works good now.-- no error due to dates type matching

Select current_date();

CREATE TABLE Dates_Issue(
    Agreement varchar,
    Dates Varchar
)

TRUNCATE TABLE Dates_Issue
Select * from Dates_Issue;
-- Load new csv file into STORAGE
PUT 'file://C:/Users/lbhardwaj/OneDrive - California Creative Solutions, Inc/Data_Backup_Cloud_Lalit/Lalit
                                        BI/Lalit Business Intelligence CCS/Module7=PowerBI/Data Sets/Datasets_Lalit_Training/agreement.csv' @STG_CS
                                        V;

-- COPY INTO -- ERROR -- Mismatch of Dates Data type
COPY INTO Dates_Issue from @STG_CSV/agreement.csv.gz;

-- Solution is Alter "File Format and Stage Format"
-- DATE_FORMAT Property

-- Alter File Format
CREATE or replace FILE FORMAT INGEST_DATA
                                        Type = CSV
                                        SKIP_HEADER = 1
                                        FILED_DELIMITER = ','
                                        RECORD_DELIMITER = '\N'
                                        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
                                        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;
                                        date_Format = 'DD-MM-YYYY'    -- Keep aligned w Data Source Date Format

SHOW FILE FORMATS;

-- Make Stage w File Format
CREATE OR REPLACE STAGE STG_CSV
FILE_FORMAT = INGEST_DATA;

-- RELOAD Data again into STAGES

PUT 'file://C:/Users/lbhardwaj/OneDrive - California Creative Solutions, Inc/Data_Backup_Cloud_Lalit/Lalit
                                        BI/Lalit Business Intelligence CCS/Module7=PowerBI/Data Sets/Datasets_Lalit_Training/FinancialSampleCSV.csv
                                        ' @STG_CSV;

PUT 'file://C:/Users/lbhardwaj/OneDrive - California Creative Solutions, Inc/Data_Backup_Cloud_Lalit/Lalit
                                        BI/Lalit Business Intelligence CCS/Module7=PowerBI/Data Sets/Datasets_Lalit_Training/agreement.csv' @STG_CS
                                        V;


-- COPY INTO

COPY INTO DATES_ISSUE
            FROM @STG_CSV/agreement.csv;

Select * from Dates_issue;

TRUNCATE TABLE DATES_ISSUE;


-- Imp
-- DELETE Files from Staging when COPIED INTO Table
-- PURGE = TRUE

COPY INTO DATES_ISSUE
FROM @STG_CSV/agreement.csv.gz 
PURGE = TRUE;


-- If we don't know FILE Namesm Order of Columns in STAGING Files
-- And we want SF AUtomtically Match/Validate table Columns with Stage Column and then do LOADING
-- MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
-- INCLUDE_METADATA = (Columname = Metadata$Field)
-- METADATA Column helps in AUDITING operations in TARGET Tables iN SF

-- For both these Properties "PARSE_HEAER = TRUE" -- in File Formate

TRUNCATE TABLE financial_lalit;

CREATE or replace FILE FORMAT INGEST_DATA
                                        Type = CSV
                                        -- SKIP_HEADER = 1
                                        INFER_SCHEMA = TRUE
                                        FIELD_DELIMITER = ','
                                        RECORD_DELIMITER = '\N'
                                        FIELD_OPTIONALLY_ENCLOSED_BY = '"'
                                        ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
                                        DATE_FORMAT = 'DD-MM-YYYY'    -- Keep aligned w Data Source Date Format
                                        PARSE_HEADER = TRUE;


CREATE OR REPLACE STAGE STG_CSV
FILE_FORMAT = INGEST_DATA;

Select * from financial_lalit


COPY INTO Financial_Lalit FROM @STG_CSV/FinancialSampleCSV.csv.gz;
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
INCLUDE_METADATA = (FILENAME = METADATA$FILENAME)  -- FILENMANE is new column we took in Table -- AUDITING

-- Also we can add New column = ETL_Load Time in table

ALTER TABLE Financial_Lalit
Add Colum ETL_Load Datetime;

COPY INTO Financial_Lalit FROM @STG_CSV/FinancialSampleCSV.csv.gz;
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
INCLUDE_METADATA = (FILENAME = METADATA$FILENAME, ETLLOAD_Time = Metadata$Start_Scan_Time) -- Helps in ETL Issues.

Select * from Financial_Lalit


