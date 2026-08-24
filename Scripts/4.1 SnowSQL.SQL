/*

SNOW SQL – SF CLI interface used to connect to SF from command line.

is used to do work when someone don’t have full access in Snowflake UI.

Can do DDL / DMLs / COPY INTO / PUT / GET  Data Loading / Unloading etc..

All executed commands are saved in folder in Program files as – History.


*/

-- Install Snow SQL

-- cmd line

snowsql -v

-- Connect w Snowflake

-- HJFRANF-OEC40504.snowflakecomputing.com
snowsql -a HJFRANF-OEC40504 -u LALITKUMAR -d snowsql -w compute_wh;

SHOW databases;

-- Connect Databse
USE DATABASE snowsql;


-- Create Schema
create schema RAW_LAYER;

-- Make Table
CREATE TABLE Employee(EID int, Ename Varchar);

-- Show Tables
SHOW TABLES;

-- We load Large N-files from local Local Machine <> Stages
    -- Note:- PUT & GET not works in UI but only in Snow Sql.
    
PUT --to load from M/C >> Stage
GET –- to Load from Staging >> M/C



-- Create File Format
CREATE FILE FORMAT CSV_TYPE
TYPE = CSV
SKIP_HEADER = 1;

-- Create Stage
CREATE STAGE STAGE_CSV
FILE_FORMAT = 'CSV_TYPE';

SHOW STAGES;

-- Question 1

-- PUT Command

-- Load Local Files into Stages 

PUT 'file://C:/Users/lbhardwaj/OneDrive - California Creative Solutions, Inc/Da
                                        ta_Backup_Cloud_Lalit/Lalit BI/Lalit Business Intelligence CCS/SnowFlake/Snowfl
                                        ake Projects/Banking SF/Data/client.csv' @STAGE_CSV;

-- Note:- if again we run above same PUT Statemenet SF will SKIPPED this as metadata was alreday saved w SF.

-- STATUS = SKIPPED.

-- Solution
OVERWRITE = TRUE;

PUT 'file://C:/Users/lbhardwaj/OneDrive - California Creative Solutions, Inc/Da
                                        ta_Backup_Cloud_Lalit/Lalit BI/Lalit Business Intelligence CCS/SnowFlake/Snowfl
                                        ake Projects/Banking SF/Data/client.csv' @STAGE_CSV OVERWRITE = TRUE;

-- Load all CSV Files in a LOCATION - *.CSV
PUT 'file://C:/Users/lbhardwaj/OneDrive - California Creative Solutions, Inc/Da
                                        ta_Backup_Cloud_Lalit/Lalit BI/Lalit Business Intelligence CCS/SnowFlake/Snowfl
                                        ake Projects/Banking SF/Data/*.csv' @STAGE_CSV;

                                        

-- Question2:- Check all Files from Stages

LIST @STAGE_CSV;


-- Query data from Stage
Select $1,$2,$3 from @Stage_csv limit 4;


-- Query a specific File in Stage

Select $1,$2,$3 from @Stage_csv/FinancialSampleCSV.csv.gz limit 6;

-- REMOVE Files from Stage
REMOVE @STAGE_CSV/File1.csv;

-- Apply Transformations on Stage data

Select $1,REPLACE($2,'C','X') as Cleaned,$3 from @Stage_csv/FinancialSampleCSV.csv.gz limit 6;

Select $1, COUNT($1) from @Stage_csv/FinancialSampleCSV.csv.gz GROUP BY $1;


-- If we make New Stage without File Format -- It will take DEFAULT CSV File Format

CREATE STAGE NewStage;
DESC STage NewStage;

-- COPY Files Stage > Stage

COPY FILES INTO @NewStage from @STAGE_CSV;

LIST @NewStage;


-- UNLOAD Data into STAGE from TABLE

REMOVE @STAGE_CSV;

COPY INTO @STAGE_CSV FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;


-- GET Command

-- Stage >>> Local Clinet Machines

GET @STAGE_CSV 'file://C:/Users/lbhardwaj/OneDrive - California Creative Solutio
                                       ns, Inc/Data_Backup_Cloud_Lalit/Lalit BI/Lalit Business Intelligence CCS/SnowFla
                                       ke/Snowflake Projects/Banking SF/Data/Copied';


                                        

                                        
