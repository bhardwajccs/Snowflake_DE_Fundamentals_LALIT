/*

SF STREAMS – to implement CDC.
To capture all DMLs on table Stream takes the Snapshot of every Record in table – Alternate was time travel i.e complex.
Stream doesn’t hold any data only metadata so takes less storage.

-- Streams are used in implementing SCD and INCREMENATL LAODS

-- In Stream table
     -- we have all Base table column values + METADATA$ACTION(Insert/Update/Delete)+ METADATA$UPDATE + METADATA$ROW_ID
     -- If for two records METADATA$ROW_ID is same it's CASE OF UPDATE = DELETE + INSERT

*/

Show tables;

Select * from courses;

-- Make Stream on table
Create or replace stream str_courses
   on table courses;

-- By DEFAULT - Stream valid = 14 days
-- Stale_after column = 14 days >> Stream is InValid means Snapshots are lost.
SHOW STREAMS;

-- But we can change it from 14 days ?
ALTER TABLE COURSES
   SET max_data_extension_time_in_days = 20;

-- TEST -- See in "stale_after" column = 20 days -- [MAX = 90 Days]
SHOW STREAMS;

-- How we see Streams Data
Select * from str_courses;

-- Do some INSWERT
INSERT INTO COURSES VALUES ('Snowflake', 'Jenish');

-- Do some DELETE
DELETE FROM courses WHERE TRAINER = 'Bill';

-- do some Update

UPDATE Courses Set Course_name = 'AI' WHERE Trainer = 'Edicson';

-- Check Stream Snapshots now
Select * from str_courses;


-- STREAMS 3 types

-- Type_1 : STANDARD STREAM - DEFAULT >> Captures all DML and TRUNCATE
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

- Select * from str_courses; -- Recorded both INSERT and DELETE
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
Select * exclude(METADATA$ACTION, METADATA$ISUPDATE) from str_courses;

-- We will see some data in Cosumed Stream
Select * from consumed_stream

-- Now if we try to read from Stream there is No data
-- This Stream data in now saved in HDD -- Nothing in RAM.

Select * from STR_COURSES; -- -- No data

