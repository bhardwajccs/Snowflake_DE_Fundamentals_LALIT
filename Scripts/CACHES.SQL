
-- Query result Cache --- 

-- In Cloud Service Layer -- for all Virtual WH.
-- Validty = 24 Hours / 1 Day [MAX = 31 Days] -- If Data or Columns in SELECT don't change.
-- Past same Excuated Quereis answered from here -- WH is Not Needed -- Save Compute cost and execution time.
-- If Query strcucture changed -- data changes in Base Table -- Query Result Cache becomes Invalid -- WH is Needed.
-- If different Users Execute the same Query from Sam Account -- Valid for all Users.
-- DISABLE it vai 
      -- " ALTER SESSION SET USE_CACHED_RESULT = FALSE ";

SHOW TABLES;

Select * from Courses; -- 874 ms -- Query executed for 1st time so tim eis large. -- See Query Profiloe more info.

Select * from Courses; -- 149 ms -- Result Cache is Used since same Query -- No Active WH is Needed.

Select * from Courses; -- 46 ms -- Disable WH -- still Query executed from Result Cache only.

-- Sinc we included one new column -- Now Query Result Cache is Invlaid -- WH is needed.
Select *, current_date() from Courses;  -- 547 ms

ALTER SESSION SET USE_CACHED_RESULT = FALSE;

Select * from Courses;

-- Virtual WH Cache
-- If we have Disabled the Query Result Cache -- still result may come from "Virtual WH Cache"
        -- " Percentage scanned from cache " = 100 % -- in Query Profil.

Select TRAINER from Courses; -- Percentage scanned from cache = 100 % >> Virtual WH CACHE USED -- in STATISTICS > Query Profile

-- DISABLE WH Mannually -- No this CACHE will Not be used 
-- Now it will be TABLE SCAN Only -- NO CACHE.

Select TRAINER from Courses; -- Percentage scanned from cache = 0 %
0.00%


/*

-- METADATA CACHE
-- It is a system-managed cache that stores file-level and table-level metadata. 
-- It resides in the Cloud Services Layer (control plane) and is automatically populated and maintained by Snowflake — you don’t have to manage it manually.

-- This cache includes metadata such as:

Micro-partition information
Column-level min/max values
Null value indicators
Row counts
File locations in cloud storage

For Metadata CACHE -- WH is Not Active
As MIN, MAX, COUNT, SHOW. DESC all this Info is taken from Micro- partitions -- NO WH needed.

This Metadata info is used in building the Execution Plans of Quereis.

This CACHE Can't be DISABLED.

*/

-- This is Metadata OOPERATION

SHOW TABLES; -- See in Query Profile

Select COUNT(*) FROM courses; -- -- See in Query Profile


-- Does all SELELCT St need Active VWH -- No -- Not for Metadata SELECT St.

-- Finally
ALTER SESSION SET USE_CACHED_RESULT = TRUE;
