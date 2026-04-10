/* SNOWFLAKE Snowsight Dashboard
   It tells consumed credits over time OR storage taken by tables.
   So, Snow sight helps in making such KPIs like
   Storage Usage and 
   cost analysis Query Performance Metrics (e.g., execution time, query counts) 
   Warehouse Utilization and 
   efficiency User Activity and 
   access patterns Database and Schema Statistics

2 schemas
-- 1 Account Users Schema – 
       helps in capturing all account level parameters. 
       Here we have Latency upto 3 Hours.
       Data stays for 1 year
-- 2 Info Schema – 
       it tells all what’s happening at Database level. 
       No Latency here.
       Data stays for 3 – 6 months.

*/

-- New File > SQL File

KPI 1 :
Total Warehosues

Select Distinct WAREHOUSE_NAME
from 
SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY

Scorecard


KPI2:
Total Databases

Select Distinct database_name
from 
SNOWFLAKE.ACCOUNT_USAGE.DATABASES


KPI3:
Total Query Executed

Select Count(QUERY_ID)
from
SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY


KPI4:
Total Storage(MB)

Select ROUND((Avg(STORAGE_BYTES + STAGE_BYTES+FAILSAFE_BYTES) / 4) / 1000000,2) as StorageMB
from
SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE


KPI5:
Last 7 Days Credit Consumption

Select Day(START_TIME), SUM(CREDITS_USED)
from
SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE Date(START_TIME) >= DATEADD(day, -7, current_date())
group by all

Line Chart


KPI6:
WH wise credits Consumptions

Select WAREHOUSE_NAME, SUM(CREDITS_USED) as TotalCredits
from
SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
group by all


KPI7:
Query Types

Select QUERY_TYPE, Count(*) as TotalTime
from
SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
GROUP BY all
HAVING COUNT(*) > 100
ORDER BY 2 DESC

Here don’t take any Visual keep it default table only


KPI8:
Monthly basis WH Consumption

Select MONTHNAME(start_time), SUM(CREDITS_USED) as TotalCredit
from
SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
group by all

**************************************

-- HOW To add FILTER over DASHBOARD

Add WAREHOUSE Filter – Also add QueryFilter (WHName)

Select DISTINCT WAREHOUSE_NAME
from
SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY

Then add this Filter on Visuals you want to Filter (…) by Modifying Query

Select Count(QUERY_ID)
from 
SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE WAREHOUSE_NAME =:WHNAME

RUN

Go Back and check
When Hover arrow over Filter – Highlights Filtered Visuals

Apply Filter TOP LHS.

Now we see Filtered Visuals.

Finally

Share Dashboards
