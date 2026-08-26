/*

SF STREAMS – to implement CDC.

To capture all DMLs on table Stream takes the Snapshot of every Record in table – Alternate was time travel i.e complex.

Stream doesn’t hold any data only metadata so takes less storage.

-- Streams are used in implementing SCD and INCREMENATL LOADS

-- Stream table
     -- All Base table column values + METADATA$ACTION(Insert/Update/Delete)+ METADATA$ISUPDATE + METADATA$ROW_ID
     -- If for two records METADATA$ROW_ID is same it's CASE OF UPDATE = DELETE + INSERT

*/

Show tables;

Select * from employee;

-- Create Stream on table

Create or replace stream Str_Employrr
   on table employee;

-- By DEFAULT - Stream valid = 14 days -- Stale after that -- menas snapshots are lost.

-- Max = 90 days

SHOW STREAMS;

-- But we can change it from 14 days ?

ALTER TABLE employee
   SET max_data_extension_time_in_days = 20;

-- Check "stale_after" Column

SHOW STREAMS;

-- How we see Streams Data

Select * from STR_EMPLOYRR;

-- Do some INSWERT
INSERT INTO Employee VALUES (111, 'Raama','San jose',12345);
INSERT INTO Employee VALUES (222, 'krishanan','PZ',33333);

-- Do some DELETE
DELETE FROM Employee WHERE  EID = 101;

-- do some Update

UPDATE Employee Set Name = 'AI' WHERE Address = 'PZ';

-- Check Stream

Select * from STR_EMPLOYRR;

SELECT * FROM EMPLOYEE;

TRUNCATE TABLE EMPLOYEE;

-- STREAMS 3 types

-- 1: STANDARD STREAM 

-- DEFAULT >> Captures all DML and TRUNCATE

-- MODE Col = DEFAULT

SHOW STREAMS;


-- Type_2: Append Only Stream -- for INSERT only -- Regular tables

Create or replace stream Str2_Courses
   on table COURSES
   APPEND_ONLY = True;

SHOW STREAMS; -- MOde = APEND_ONLY

Select * from COURSES;

-- DELETE

DELETE FROM courses WHERE TRAINER = 'kelyn';

INSERT INTO Courses values ('SQL', 'Trump')

Select * from str_courses; -- Recorded both INSERT and DELETE

Select * from str2_courses; -- Only Recorded INSERT -- NOT DELETE



-- Type_3 : INSERT Only Stream same as Append_only -- Only for Apache ICEBERGrg and External Tables

Select * from MY_EXT_TBL;

Create or replace stream Str2_emp
on External table MY_EXT_TBL
INSERT_ONLY = True;

-- INSERT Only will be captured on above External table.



-- How to consume stream on External table

Create or replace table consumed_stream
AS
Select * exclude(METADATA$ACTION, METADATA$ISUPDATE) from STR_EMPLOYRR;


-- We will see some data in Cosumed Stream

Select * from consumed_stream

-- Now if we try to read from Stream there is No data
-- This Stream data in now saved in HDD -- Nothing in RAM.

Select * from STR_EMPLOYRR;
