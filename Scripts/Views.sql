Show VIEWS;

-- View Row Level Security
Create or replace view v_customer AS
Select * from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER
where C_NATIONKEY IN (14,15);

Select * from v_customer;

-- Column level securtriy
Create or replace view v_col_customer AS
Select * exclude(C_ACCTBAL, C_PHONE) from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

Select * from v_col_customer;

-- View based on Multiple Tables
Create or replace view view_multiple_tables AS
Select  N.N_Name,COUNT(C.C_CUSTKEY) from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
Inner Join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
ON C.C_NATIONKEY = N.N_NATIONKEY
Group by all;

-- Materilazied View
-- Storage Cost in Memory So performance compared to Normal Viw as data in m/m,
-- Best if Data is Not chnaging in Base table and Aggregtaions Quereis.
-- Maintained AUTO. if Base Data changes.
-- LIMITATION -- More than one Table can't be Referenced

Create or replace materialized view matv_customer AS
Select * exclude(c_address) from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

select * from matv_customer;

-- Limitation of Matrialized View -- More than One Tbales can't be JOINED
-- run slowly comapred to normal; views
-- Below will Not work
Create or replace materialized view matv_customer AS
Select  N.N_Name,COUNT(C.C_CUSTKEY) from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER C
Inner Join SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.NATION N
ON C.C_NATIONKEY = N.N_NATIONKEY
Group by N.N_Name;


-- SECURE VIEWS
-- SLOW in Performance
-- Data Sharimng in SNOWFLAKE   is only via SECURE Views.

-- View Text is Visible if It is Not SECURE View
 SHOW VIEWS;

-- View Deff is Exposed -- Query Profile Somone can see all Columns
Select * from v_customer

-- Solution - SECURE VIEW
Create or replace secure view sv_col_customer AS
Select * exclude(c_address) from SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

Select * from sv_col_customer;
