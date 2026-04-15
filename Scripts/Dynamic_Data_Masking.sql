
-- Data Masking

-- Masking POLICY

CREATE OR REPLACE MASKING POLICY PI_MASKING AS (CARD String)
    RETURNS STRING ->
    CASE
     WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN') THEN CARD
     WHEN CURRENT_ROLE() IN ('BI_ROLE') THEN regexp_replace(card, substring(1,7), '########')
     WHEN CURRENT_ROLE() IN ('SYSADMIN') THEN '$$$$$$$$$$'
     ELSE '****Sorry, data can not be accessed ***'
    END;


-- Another POLICY

CREATE OR REPLACE MASKING POLICY PII AS (PAN String)
    RETURNS STRING ->
    CASE
     WHEN CURRENT_ROLE() IN ('ACCOUNTADMIN') THEN PAN
     WHEN CURRENT_ROLE() IN ('BI_ROLE') THEN regexp_replace(PAN, substring(1,4), 'AAAA')
     WHEN CURRENT_ROLE() IN ('SYSADMIN') THEN '$$$$$$$$$$'
     ELSE '****Sorry, data can not be accessed ***'
    END;




-- If Policy is alreday there use below Script while making table.

CREATE OR REPLACE TABLE CREDIT_CARD_CUSTOMER
    (
        ID Number,
        First_Name String,
        Last_Name String,
        DoB String,
        CreditCard String masking policy PI_MASKING,
        PAN String,
        Country String,
        City String
    );

    INSERT INTO CREDIT_CARD_CUSTOMER VALUES
       (1, 'Lalit', 'Kumar','09-01-1988', '3437465566', 'ABCD', 'San Jose', 'Costa Rica'),
       (2, 'Jenish', 'Kumar','09-01-1988', '3434565566', 'ABCD', 'San Jose', 'Costa Rica'),
       (3, 'Rahul', 'Kumar','09-01-1988', '3437465789', 'ABCD', 'San Jose', 'Costa Rica'),
       (4, 'Ram', 'Kumar','09-01-1988', '3437465234', 'ABCD', 'San Jose', 'Costa Rica'),
       (5, 'Lalit', 'Kumar','09-01-1988', '3437465566', 'ABCD', 'San Jose', 'Costa Rica'),
       (6, 'Lalit', 'Kumar','09-01-1988', '3437465566', 'ABCD', 'San Jose', 'Costa Rica')
       

    -- DESC Table
    -- See Policy Name column
    DESC TABLE CREDIT_CARD_CUSTOMER;


    -- If table Exists how to apply Policy

    ALTER TABLE IF EXISTS CREDIT_CARD_CUSTOMER MODIFY COLUMN CreditCard SET MASKING POLICY PI_Masking;

    -- Do for PAN

     ALTER TABLE IF EXISTS CREDIT_CARD_CUSTOMER MODIFY COLUMN PAN SET MASKING POLICY PII;


     DESC TABLE CREDIT_CARD_CUSTOMER;

     -- TEST via diff Roles
     -- ACCOUNTADMIN

     Select * from CREDIT_CARD_CUSTOMER; -- ADMIN see all Data

     -- For different Customr Roles ensure Roles have Access on Databases and Schemas and Tables
     
     GRANT USAGE ON DATABASE SNOWSQL TO ROLE BI_ROLE; 
     GRANT ALL ON SCHEMA SNOWSQL.RAW_LAYER TO ROLE BI_ROLE;
     GRANT SELECT , INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA SNOWSQL.RAW_LAYER TO ROLE BI_ROLE;
     GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE BI_ROLE;

     -- make Supplier Role and do same 4 Steps.

     -- BI_Role
     Select * from CREDIT_CARD_CUSTOMER; -- Partial Masking


     -- SYSADMI9N
     Select * from CREDIT_CARD_CUSTOMER; -- Full Masking

     -- SYSADMIN
     -- Even if exact filter value is given is Masking is there it will not show the result
     -- Good thing of Masking
     Select * from CREDIT_CARD_CUSTOMER where creditcard = '3437465566'; -- No shows data

     
     -- remove UNMASK Policy
     -- ACCOUNTADMIN
     ALTER TABLE IF EXISTS CREDIT_CARD_CUSTOMER MODIFY COLUMN PAN UNSET MASKING POLICY;


     -- ADMIN
     -- GOVERANCE and Masking Plociies
     
     
