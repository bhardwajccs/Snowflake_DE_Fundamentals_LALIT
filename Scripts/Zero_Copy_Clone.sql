/*

ZERO COPY CLONING

Backups of DB, Tables for TESTING or diff needs.
Traditional DB we make backups and once used then we drop those Backups
But in SF it’s very smooth no need of Dropping.
SF Cloning is without any storage cost


When we store data in SF micro partitions created at Storage layer.
   SF keeps Metadata (holding info about micro partitions) in Cloud Service layer. So, queries like Count, Max are answered from Metadata layer.
      If we clone tables SF doesn’t clone the Micro partitions but rather make diff Metadata copy referring to original micro partitions. So,SAVE storage cost in Clones.


*/

-- Clone DB
-- Not clones Internal Stages and External Tables.
-- If we clone DB / Tables SF charges No Storage Cost.

Create or replace database SNOWSQL_Cloned
CLONE SNOWSQL;

-- Clone Table
CREATE TABLE Course_Cloned CLONE Courses;

-- To See storage cost in 'ActiveBytes col' = 0;
Select * from INFORMATION_SCHEMA.table_storage_metrics where table_catalog = 'SNOWSQL'

-- How you identify is table is Clone or Not
    -- If ID != CLONE_GROUP_ID    -- Then YES Clone.
Select * from INFORMATION_SCHEMA.table_storage_metrics where table_catalog = 'SNOWSQL'

-- NOTE_1
-- But for new DML in Clone Table -- then SF will charge as for that new data new Micro- Partitions will be created.

-- NOTE_2
-- If we make any DML changes in Parent copy does it impacts in Clone copy -- NOOOOO
-- So these are two indpendent copies means changes on any table Not imapcts other -- CLONE is SNAPSHOT Copy
-- If we DROP Original table -- Still Clone is there.

-- Delete from PARENT
TRUNCATE Table Courses;
-- UNDROP TABLE Courses;

-- Child -- No Change
SELECT * FROM COURSE_Cloned;

-- NOTE_3
-- If Base Table was using in PBI -- Courses Table -- Later we Dropeed this table -- Reports will go crazu. 
-- Noe we have created Clone of that Table.
-- But we can't ask PBI guy to use this Cloned table now.

-- Solution
-- time Travel + Copy Clone

Select * from Courses -- PBI Used

Create or replace table Course_Old Clone Courses at(offset => -60*10) -- Made Cloned Copy 10 minutes Ago.-- " CLONE + TIME TRAVEL ""

-- solution
Alter table COURSES
SWAP WITH Course_Old

Select * from Courses; -- PBI Guy still gets data indirectly by cloned copy -- Courses_Old


-- NOTE
-- If we have CUSTOMER TABLE -- 100 Columns - 100 Million Records
-- Then Mistakenly we CREATE ANother CUSTOMER Table - 10 Columns, Then How we Reach to Original Table

SHOW TABLES;
Select * from Courses;

-- Recreate same table
CREATE OR REPLACE Table Courses(Trainer varchar);

-- NO Data as We just ReCReated this Cousres table -- 10 Minutes ago there is No data.
-- Here Time Travel Will Not Work.
Select * from Courses at (offset => -60*10);

-- S0LUTION

ALTER TABLE Courses RENAME TO Courses_Old;

UNDROP TABLE Courses;

SELECT * FROM Courses;
