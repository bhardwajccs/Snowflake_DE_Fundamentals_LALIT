

SHOW TASKS;

-- Task via UI
-- In SCHEMA
create task Task_UI
    warehouse = COMPUTE_WH
    schedule = '2 M'
    -- <session_parameter> = <value> [ , <session_parameter> = <value> ... ]
    -- user_task_timeout_ms = <num>
    -- copy grants
    -- comment = '<comment>'
    -- after <string>
  -- when <boolean_expr>
  as
    Select 1;



-- Method_2

Create or replace Table Task_test
    (
        ID INT,
        Details Varchar
    );


Create OR REPLACE SEQUENCE SE_01 START WITH 1
   INCREMENT BY 1;


Select * from Task_test;

-- INSERT Mannually

INSERT INTO TASK_TEST VALUES(SE_01.nextval, 'Any Data Inserted')
INSERT INTO TASK_TEST VALUES(SE_01.nextval, 'Any Data Inserted')

Select * from Task_test;

-- How to INSERT Data w TASK on Schedule

CREATE OR REPLACE TASK Insert_Task_test
WAREHOUSE = COMPUTE_WH
SCHEDULE = '1 M'   -- MAX Time = '11520 Minutes == 8 Days'
AS
INSERT INTO TASK_TEST VALUES(SE_01.nextval, 'Any Data Inserted');

-- STATE = SUSPENDED Means TASK WIll Not Trigger.
SHOW TASKS;

-- SOLUTION - Mannually RESUME TASK -- When we Create it.
ALTER TASK Insert_Task_test RESUME;

-- TEST DATA
-- After Every 1 Minute data is being Inserted.
Select * from Task_test;

-- INFO About all TASKS Executed in SF
Select * from Table(INFORMATION_SCHEMA.TASK_HISTORY());

-- INFO Abouit a Specific Task
Select * from Table(INFORMATION_SCHEMA.TASK_HISTORY(TASK_NAME => 'Insert_Task_test'));

-- SUSPEND this TASK
ALTER TASK Insert_Task_test SUSPEND;



-- Create a TASK via CRON – WH will be NULL as Serverless.
-- and see History -- To see History 1st RESUME TASK

CREATE OR REPLACE TASK CRON_TASK
SCHEDULE = 'USING CRON 30 9 * * 1 Central America'
AS
INSERT INTO TASK_TEST VALUES(SE_01.nextval, 'Any Data Inserted');

-- No TASK History in CRON Task -- As it is Not Schuled task
-- ASLO It was DSIABLED.
Select * from Table(INFORMATION_SCHEMA.TASK_HISTORY(TASK_NAME => 'CRON_TASK'));

-- WH = NULL as It was Serverless
SHOW TASKS;



-- 
-- PARENT CHILD TASK Hierarchy

-- Child TABLE
Create or replace Table CHILD
    (
        ID INT,
        TextScript Varchar
    );



-- PARENT TASK

CREATE OR REPLACE TASK PARENT
WAREHOUSE = COMPUTE_WH  -- User Managed
SCHEDULE = '1 M'   -- MAX Time = '11520 Minutes == 8 Days'
AS
INSERT INTO TASK_TEST VALUES(SE_01.nextval, 'Any Data Inserted');


-- CHILD TASK
CREATE OR REPLACE TASK CHILDTask
WAREHOUSE = COMPUTE_WH
AFTER PARENT
AS
INSERT INTO CHILD VALUES(SE_01.nextval, 'Any Data Inserted');

-- Scheule for Child task = Null
-- Notice Predecessor
SHOW TASKS;


-- NOTE
-- FIRST to RESUME CHILD TASK -- PARENT Must be SUSPENDED
-- tHEN RESUME PARENT TASKS
ALTER TASK PARENT RESUME;
ALTER TASK CHILDTask RESUME;

Select * from TASK_TEST;
Select * from CHILD;

-- SUSPEND both
ALTER TASK PARENT SUSPEND;
ALTER TASK CHILDTask SUSPEND;
ALTER TASK CHILD SUSPEND;

SHOW TASKS;
