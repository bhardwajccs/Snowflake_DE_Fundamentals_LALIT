/*

ACCOUNT USUAGE Schema Views – to track account info and user activities 
         110+ Views
AND INFORMATION SCHEMA Views
         40+ Views
         Created by DEFAULT when we create a DB
        Holds Metadata Info of DB Objects.
      READ Only



SNOWFLAKE System DB
          ACCOUNT_USUAGE Schema
          READER_ACCOUNT_USAGE Schema



*/

-- ACCOUNT LEVEL -- Tells about users Activities and how ACCOUNT is being used.
-- To check all Tables, Views, Event Tables, 
Select * from SNOWFLAKE.ACCOUNT_USAGE.Tables;


-- INFORMATION_SCHEMA View
-- List Metadata Info of System Views AND tables in the DB
Select * from SNOWSQL.INFORMATION_SCHEMA.Tables;

SHOW TABLES;

CREATE TABLE Duplicate(ID INT)
