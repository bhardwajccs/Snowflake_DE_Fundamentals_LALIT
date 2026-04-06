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


-- DDLs

-- Context
-- select DB and Schema

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

