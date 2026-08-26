/*
-- TIME TRAVEL

SF Storage layer is on S3 / BLOB / GCS
When we store data there.
When we load data in S3 SF AUTO. makes chunks called Micro-Partitions to store data.
Each Micro-Partitions has uncompressed size = 50 – 500 MB0 and final size of 16 MB
Micro-Partitions are Immutable means if we update any data SF table SF retains original partitions and makes new partitions for new data
Original Partition is kept for x days (depending on Retention Period of that table).
When Retention Period expires (1- 90 days) data go into Fail Safe zone (Only for permanent tables) where it stays for 7 more days. 
For Temp / Transient table = 0 Days.
Retention Period can be disabled but Not Fail Safe.
We can change Retention Period limit as well.
By DEFAULT Tables have Parent’s (Schema) Retention Period – 1 day.


-- FAIL SAFE
-- Once Time Travel Period is Over >> Data enter into Fail Safe for 7 days -- Only fro Permanent Tables
-- Non- Configuarble
-- Only SNOWFLAKE Team can Recover


*/

Select * from DUMMY;

SHOW TABLES; -- DEFAULT "retention_time" = 1 day

ALTER TABLE DUMMY SET DATA_RETENTION_TIME_IN_DAYS = 10; -- Changed 

-- Since every SCHAME has DEFAULT " Retention_Time = 1 " Days so tables alswo take it as 1 day by DEAFULT.
-- It follwos Parent Strategy if not specified.
SHOW SCHEMAS;  -- 1 day

ALTER SCHEMA TESTSCHEMA SET DATA_RETENTION_TIME_IN_DAYS = 80;
SHOW SCHEMAS;

-- AUTO all Tables in SCHEMA will also get DEAFULT = 15 Days
SHOW TABLES;

Select * from dummy;

-- PROBLEM_1
-- If Accidently DROP Schema
DROP SCHEMA TESTSCHEMA;

-- Solution
UNDROP SCHEMA TESTSCHEMA; -- Restored Back due to Retention_Time Period -- TIME TRAVEL.



-- PROBLEM_2

UPDATE Fin SET UNITSSOLD = 0; ---- Accident DML Operation done.

Select * from FIN;

-- Solutions

-- 3 Ways to Access Historical data in TIME TRAVEL

-- Way_1

-- At Specific Time / Day
Select * from FIN;


Select * from FIN AT (timestamp => '2026-08-26 10:05:32'::TIMESTAMP_NTZ);-- Works now

-- way_2
-- To Query 5/10 Minute back data
Select * from FIN AT (OFFSET => -800); -- Someone may be caused this issue 2000 seconds ago


-- Way_3
-- Accessing for any Query_ID -- BEST

-- Find the Query_ID
-- Query History > SQL Text = Table name > There see UPDATE Statement > Copy Query_ID

Select * from FIN BEFORE (statement => '01c6a6a5-0004-bf5a-0000-71e5000434b6'); -- See Original data


-- Note :- PBI Guy may be using this table

-- Take help of "Zero Copy Clone" so that his work in Not impacted.


-- No of Bytes allocated -- INFO
-- Columns
    -- Active_Bytes
    -- Time_Travel_Bytes

Select * from SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
