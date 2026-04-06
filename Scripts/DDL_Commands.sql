Create Database SnowflakeDB_LALIT

Create Schema Raw_Data

-- Initially first time
-- Query Time = Query Compilation time + WH Provisioning Time + Query Execution Time

-- when same Query Executed again
-- Query time = Only Query Execution time.
Select * from customer limit 10; -- 01c38402-0001-3762-001a-18e3000142f6
Select * from customer limit 10; -- 01c38405-0001-3799-0000-001a18e37241

Select * from customer -- 15 Million Records -- 01c3840b-0001-36d6-0000-001a18e38449
Select * from customer -- 01c3840d-0001-35af-0000-001a18e3c301

-- In Python Notebooks we can write Python SNOWPARK Code.
-- In Notebooks we can write Jupyter Notebook code in Python / SQL.

SHOW WAREHOUSES




-- Context
-- select DB and Schema

-- DDLs

Create table Employee
(
    Eid int,
    Name varchar(30),
    Address Varchar(50),
    Phone int
)


-- Kind means PERMANENT Tables -- By DEFAULT
-- PERMANENT Tables have "retention_time >> A Day =  24 Hours"
show tables 

-- See metadata of table
Desc table employee


Create or Replace table Employee
(
    Eid int primary key,
    Name varchar(30) not null,
    Address Varchar, -- Varchar(max)
    Phone int DEFAULT 9999
)

desc table employee

-- DML
-- SF doesn't any Enforce Constraints except NOT NULL.
-- But in Hybrid Tables in SF -- OLTP -- there PK Enforcement is there.
Insert into employee (eid,name,address) values(101,'Lalit','San Jose')
Insert into employee (eid,name,address) values(101,'Lalit','San Jose') -- Violation of PK

select * from employee

desc table employee

-- NOT NULL is Enforced Always
Insert into employee (eid,address) values(101,'San Jose') -- Errors 

-

TRUNCATE Table Employee;

Drop table Employee

Show Tables;

/*

Methods to INSERT Data in to SNOWFLAKE Warehosues

-- 1 UI – Only CSV / TSV / JSON / Parquet / Avro / ORC Data Files supported from Source. -- File Size = 250 MB.
-- 2 SNOWSQL
-- 3 SNOWPIPE // Using Copy Into in Ext. Stage.
-- 4 3rd Party Tools – Informatica / Matillion / Python.

--- 1 UI Based
   SF will create Table, File Format and COPY INTO Script -- " Show SQL "" option while loading from File

*/




/*

-- FILE FORMATS in Stages in SF

*/

SHOW FILE FORMATS

-- STEP_1 
CREATE OR REPLACE FILE FORMAT CSVONE
TYPE = CSV  -- Default Value
SKIP_HEADER = 1
FIELD_DELIMITER = ','
RECORD_DELIMITER = '\n'


-- Sometimes We have comma in single column -- ERROR
ALTER FILE FORMAT CSVONE
SET FIELD_OPTIONALLY_ENCLOSED_BY = '"'; -- Encloses fields in double quotes

-- When Source File and Destination Columns Not MATCH
ALTER FILE FORMAT CSVONE
SET error_on_column_count_mismatch = FALSE;

-- SF has YYYY-DD-MM FORMATS
-- to give same date format from source
ALTER FILE FORMAT CSVONE
SET date_format = 'yyyy-mm-dd'

DESC FILE FORMAT CSVONE

-- STEP_2
CREATE or replace TABLE EMPLOAD(
    Empid	int
    ,Name	varchar
    ,Email	varchar
    ,Phoneno	int
    ,Address	varchar
    ,COMPANY	varchar
    ,"Joining Date"	date
)

Select * from EMPLOAD

-- STEP_3
-- Load data into Table w above File Format w UI -- ERROR

TRUNCATE TABLE empload
drop file format csvone


