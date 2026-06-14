-- ACCOUNT_USUAGE v/s INFORMATION_SCHEMA

-- ACCOUNT Level SNOWFLAKE Tables and VIEWS. 
Select * from SNOWFLAKE.INFORMATION_SCHEMA.Tables;

-- returns Metadata about all tables in your Snowflake account -- NO DATA
-- Also Info about DROPPED Tables.
Select * from SNOWFLAKE.ACCOUNT_USAGE.Tables;

Select * from SNOWFLAKE.ACCOUNT_USAGE.TASK_HISTORY;   -- Table View

-- Database level Tables and VIEWS.
Select * from SNOWSQL.INFORMATION_SCHEMA.Tables;

-- All databases/schemas visible to your role;
SHOW TABLES;

Create table T1(ID INT);  -- Check above all Counts noew -- see difference


-- SNOWFLAKE DB
-- ACCOUNT_USUAGE and READER_ACCOUNT_USUAGE  SCHEMAS
-- Views like Query_History, Storage_Usuage, WAREHOUSE_METRING_HISTORY_ TASK_HISTORY...
    -- There Quereis Info like Longest Running etc...

SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORYSNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS

    
-- Differences in Notes
