

/*

ACCESS CONTROL in SG

https://medium.com/@satyavarssheni/access-control-framework-of-snowflake-1b45ac339744

*/


GRANT USAGE ON SCHEMA Snowsql.raw_layer TO ROLE BI_ROLE;

-- Give Grant on ALL TABLES to BI_Role
GRANT SELECT ON ALL TABLES IN SCHEMA Snowsql.raw_layer TO ROLE BI_ROLE;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA Snowsql.raw_layer TO ROLE BI_ROLE;

-- To see who all can Access DB
SHOW GRANTS ON DATABASE SNOWSQL;

-- Futrue Roles
CREATE TABLE SNOWSQL.RAW_LAYER.ABC(ID INT);

DROP TABLE ABC;
