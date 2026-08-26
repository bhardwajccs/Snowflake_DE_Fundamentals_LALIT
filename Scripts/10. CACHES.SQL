
-- Cache no 1 and 3 -- in Cloud Service layer in SF

-- Cache 2 -- VWH

-- 1. Query result Cache --

-- In Cloud Service Layer -- for all Virtual WH.

-- Validty = 24 Hours = 1 Day [MAX = 31 Days] -- If Data or Columns in SELECT don't change.

-- Past same Excuated Quereis answered from here -- WH is Not Needed -- Save Compute cost and execution time.

-- If Query strcucture changed -- data changes in Base Table -- Query Result Cache becomes Invalid -- WH is Needed.

-- If different Users Execute the same Query from Same Account -- Valid for all Users.

-- DISABLE it via

      -- " ALTER SESSION SET USE_CACHED_RESULT = TRUE ";

SHOW TABLES;

Select * from FIN; -- 874 ms -- Query executed for 1st time so tim eis large. -- See Query Profiloe more info.

Select * from DUMMY; -- 149 ms -- Result Cache is Used since same Query -- No Active WH is Needed.

Select * from DUMMY; -- 46 ms -- Disable WH -- still Query executed from Result Cache only.

Select *,CURRENT_DATE() from FIN;

Select COUNTRY from FIN;

-- Sinc we included one new column -- Now Query Result Cache is Invlaid -- WH is needed.

Select *, current_date() from child;  -- 547 ms

ALTER SESSION SET USE_CACHED_RESULT = FALSE;



-- 2 Virtual WH Cache --

-- If we have Disabled the Query Result Cache -- still result may come from "Virtual WH Cache"

-- " Percentage scanned from cache " = 100 % -- in Query Profile.

Select TRAINER from Courses; -- Percentage scanned from cache = 100 % 

-- DISABLE WH Mannually -- Now this CACHE will Not be used 

-- Now it will be TABLE SCAN Only -- NO CACHE.

Select TRAINER from Courses; -- Percentage scanned from cache = 0 %



/*

-- 3 METADATA CACHE --

-- It is a system-managed cache that stores file-level metadata and table-level metadata. 

-- Its in Cloud Services Layer (control plane)

-- When we load data into SF -- Micropartitions craeted and metadata info gets Saved in MEtadata Cache automatically..

-- This cache includes metadata such as:

Micro-partition information
Column-level min/max values
Null value indicators
Row counts
File locations in cloud storage

For Metadata CACHE -- WH is Not Active
As MIN, MAX, COUNT, SHOW. DESC all this Info is taken from Micro- partitions

This Metadata info is used in building the Execution Plans of Quereis.

This CACHE Can't be DISABLED.

*/

-- This is Metadata OOPERATION

SHOW TABLES; -- See in Query Profile

Select COUNT(*) FROM Fin; -- -- See in Query Profile


-- Finally

ALTER SESSION SET USE_CACHED_RESULT = TRUE;
