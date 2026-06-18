/*

DT are Complex SQL Queries w TARGET_LAG which dictates the refresh frequency. 

Dynamic Tables  are Automated refresh processes that use transformation queries on base tables to generate new tables. 

Dynamic Tables simplify data orchestration pipelines where data freshness is important and complex SQL-based transformations are necessary.

Unlike views which require the user to compute the table when it is queried, Dynamic Tables stay calculated which improves query speeds. Likewise, while materialized views offer the same kind of cached data, Dynamic Tables are able to utilize things like joins, unions, and nested views that materialized views cannot.


CREATE [ OR REPLACE ] DYNAMIC TABLE <name>
  TARGET_LAG = { '<num> { seconds | minutes | hours | days }' | DOWNSTREAM }
  WAREHOUSE = <warehouse_name>
  AS <query>


-----------------USE CASES------------------------------

For finance-based organizations, it might be useful to have periodic refreshes of transactional data, like fraud detection or chargebacks. 
Since we don’t need up-to-the-second data, we might like a TARGET_LAG of 10 minutes for general system health dashboards. Perhaps you have a data science model that saves all fraud alerts into one table and a third-party chargeback monitoring system which saves to another table. 
You can bring these two together into an aggregated table simply without the need for complex Airflow DAGs. This should simplify and improve querying performance.

Perhaps for retail analytics, we are interested in how different regions are performing. It’s possible each region has their own central database that pushes data periodically, but slightly off-sync. Instead of building out ETL pipelines which have to tailor their timings to each database, we can build a Dynamic Table which aggregates these all together as needed based on lags from each table. This reduces pipeline complexity and minimizes the need for constant maintenance.

Some other scenarios might involve:

Real-time behavioral analytics: aggregate real-time customer behavior information to summarize emerging trends
CDC workflows: keep near-real-time data for operational changes to keep track of business issues
Data vault modeling: incrementally add new data as it arrives and serve as a singular source of how the data was ingested

*/

CREATE OR REPLACE TABLE EMPLOYEE(EMP_ID INT, EMP_NAME VARCHAR,EMP_ADDRESS VARCHAR);

INSERT INTO EMPLOYEE VALUES(1,'AGAL','INDIA');
INSERT INTO EMPLOYEE VALUES(2,'KINNU','INDIA');
INSERT INTO EMPLOYEE VALUES(3,'SHUKESH','AUSTRALIA');
INSERT INTO EMPLOYEE VALUES(4,'SUPREET','UAE');

SELECT * FROM EMPLOYEE;

CREATE OR REPLACE TABLE EMPLOYEE_SKILL(
SKILL_ID NUMBER,
EMP_ID NUMBER,
SKILL_NAME VARCHAR(50),
SKILL_LEVEL VARCHAR(50)
);

INSERT INTO EMPLOYEE_SKILL VALUES(1,1,'SNOWFLAKE','ADVANCE');
INSERT INTO EMPLOYEE_SKILL VALUES(2,1,'PYTHON','BASIC');
INSERT INTO EMPLOYEE_SKILL VALUES(3,1,'SQL','INTERMEDIATE');
INSERT INTO EMPLOYEE_SKILL VALUES(1,2,'SNOWFLAKE','ADVANCE');
INSERT INTO EMPLOYEE_SKILL VALUES(1,4,'SNOWFLAKE','ADVANCE');

SELECT * FROM EMPLOYEE_SKILL;


/*

As dynamic tables rely on tracking changes in the Base tables.
When creating a dynamic table in Snowflake automatically enable change tracking on the underlying objects.

*/

-- change_tracking column = OFF
SHOW TABLES;

-- Make Dynamic Table
CREATE OR REPLACE DYNAMIC TABLE EMPLOYEE_DT
 TARGET_LAG = '1 MINUTE'
 REFRESH_MODE = incremental -- full / AUTO
  WAREHOUSE = COMPUTE_WH
  AS
    SELECT A.EMP_ID,A.EMP_NAME,A.EMP_ADDRESS, B.SKILL_ID,B.SKILL_NAME,B.SKILL_LEVEL
    FROM EMPLOYEE A, EMPLOYEE_SKILL B
    WHERE A.EMP_ID=B.EMP_ID
    ORDER BY B.SKILL_ID ;

-- -- change_tracking column = ONJ
SHOW TABLES;


Select * from EMPLOYEE_DT;


-- DML on BASE Tables
UPDATE EMPLOYEE_SKILL
SET SKILL_LEVEL = 'ADVANCED'
WHERE EMP_ID = 1 AND SKILL_NAME = 'SNOWFLAKE';

DELETE FROM EMPLOYEE
WHERE EMP_ID = 4;

-- Wait 1 Minute
Select * from EMPLOYEE_DT;

-- Modify DT 
ALTER Dynamic Table sales_agg SET TARGET_LAG = '3 minutes';

ALTER Dynamic Table EMPLOYEE_DT SUSPEND;



CREATE OR REPLACE Dynamic Table sales_agg
  TARGET_LAG = '5 minutes'
  WAREHOUSE = 'compute_wh'
  AS
SELECT
  store_id,
  SUM(amount) AS total_sales,
  COUNT(*) AS sale_count
FROM raw_sales
GROUP BY store_id;


-- Clong older version of DT w Time Travel
CREATE Dynamic Table clone_sales_agg
CLONE sales_agg
AT (OFFSET => -24*60*60) –-24 hours ago
TARGET_LAG = DOWNSTREAM
WAREHOUSE = sales_wh;


ALTER Dynamic Table sales_agg SUSPEND;

