Show tables
-- By Default Tables are Permanent.

Create table CustomerDupl(ID int, Name varchar)

Create transient table EmployeeDupl(ID int, Name varchar)

Create Global temporary table OrdersDupl(Oid int, OName Varchar)

Create temporary table ProductsDupl(Pid int, PName Varchar)

Select * from OrdersDupl

-- Hybrid Table -- Not in Trail SF Accounts
-- PK is Must
Create Hybrid table HCustomerDupl(Cid int Primary key, CName Varchar)

-- When we make Hybrid tables both types come as Tables so how we identify if a table is Normal / Hybrid?
-- Answer is 
-- In SHOW Tables -- Is_Hybrid Column = YES

SHOW Tables


-- External Tables
-- For these we need to have "External Stage Ready" means Account in Data Lakes S3 / Blob / Google.
-- There we keep those Files(100 GB) and wanted to use in Snowflake without loading in SF to avoid two place storage costs.       -- So, here Make External table. Only pay Compute Cost in SF



-- Retention Time/Time Travel 
-- Max = 90 Days
-- By Default = 1 Day
-- only permanent tables Retention time can be changed
Alter table CustomerDupl
Set Data_retention_Time_In_Days=13

SHOW tables;


-- Fail Safe -- Non configurable
-- 7 Days over 90 Days -- Only for Permanent tables. 
-- and Other tables = 0


-- Note -- IMP
-- We can have like Temp tables same name as Regular Tables / Transient Tables in same Schema it is possible
-- Then in SQL Operations Temp table will take Precedence.
-- In SHOW Tables we only see TEMP Tables -- No Permanent tables -- in same session
-- But from different sessions we only see Permanent tables -- No TEMP Tables


-- If we drop this Table -- Temp will be Dropped Regular / Transient is still there.
-- SHOW Tables -- will still show Permanent / Transient tables.


-- Interview Question
-- Q  We Drop table but we see the data , WHY ?
-- ANS   It's because it was Temp table with same name as Permanent / Transient table.


Create temp table CustomerDupl(ID int, Name varchar) -- Same as Permanent

SHOW TABLES;

DROP TABLE CustomerDupl

Select * from CustomerDupl   - Still we see data




-- Temp Table can't be cloned to Permanent Table but can be cloned to Transient / Temp

Create or replace temporary table OrdersDupl(Oid int, OName Varchar)

Create or replace table Orders_Clone -- TEMP Table can't be cloned to PERMANENT Table
Clone OrdersDupl


-- Transient Table can't be cloned to Permanent Table but can be cloned to Transient / Temp.

-- Permanent Table can't be cloned to Permanent / Transient / Temp

-- View can be craeted on Top of all these.



-- USUAGE

-- Temp -- To store session specific Temp Data like Calculation results / For intermediate Results.
        -- For Transofrmtaions and Aggregtaions.

-- Transient Table -- for intermediate data processing also for all sessions and all users. here we don't                  --
    -- worry about lossing data as it is Staging Area and we can get data agaian from Source.
    -- Staging tables -- where we don't need to store data permanently and No need of data Recovery
-- Permenent Table -- we have Time Travel + Fail Safe as we can recover data but Storage cost is High here.
-- External -- If Data is Outside of SF like S3 and we don't want to store in SF.
