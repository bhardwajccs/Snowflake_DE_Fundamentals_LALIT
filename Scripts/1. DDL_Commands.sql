-- DDL 
-- Handled entirely by the Cloud Services layer, which is the metadata manager of the platform. 
-- DDL only update metadata and do not require raw compute power.

Create Database SnowflakeDB_LALIT

Create Schema Raw_Data


-- =============================================
-- 1. Create Customers Table
-- =============================================

DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers
(
    CustomerID      INT IDENTITY(1,1) PRIMARY KEY,
    FirstName       VARCHAR(50) NOT NULL,
    LastName        VARCHAR(50) NOT NULL,
    Email           VARCHAR(100) UNIQUE,
    Phone           VARCHAR(20),
    City            VARCHAR(50),
    State           VARCHAR(50),
    Country         VARCHAR(50),
    DateOfBirth     DATE,
    RegistrationDate DATE,
    CustomerStatus  VARCHAR(20),
    CreditLimit     DECIMAL(12,2),
    Gender          VARCHAR(10)
);


-- =============================================
-- 2. Insert 50 Customers
-- =============================================

INSERT INTO Customers
(
    FirstName,
    LastName,
    Email,
    Phone,
    City,
    State,
    Country,
    DateOfBirth,
    RegistrationDate,
    CustomerStatus,
    CreditLimit,
    Gender
)
VALUES
('John','Smith','john.smith@gmail.com','555-1001','New York','NY','USA','1985-02-15','2021-01-10','Active',10000,'Male'),
('Emma','Johnson','emma.johnson@gmail.com','555-1002','Chicago','IL','USA','1990-06-21','2021-02-15','Active',15000,'Female'),
('Michael','Brown','michael.brown@gmail.com','555-1003','Dallas','TX','USA','1982-11-10','2021-03-20','Active',12000,'Male'),
('Sophia','Davis','sophia.davis@gmail.com','555-1004','Houston','TX','USA','1993-04-18','2021-04-05','Active',8000,'Female'),
('William','Miller','william.miller@gmail.com','555-1005','Seattle','WA','USA','1979-09-25','2021-05-12','Inactive',7000,'Male'),

('Olivia','Wilson','olivia.wilson@gmail.com','555-1006','Boston','MA','USA','1988-12-12','2021-06-18','Active',20000,'Female'),
('James','Moore','james.moore@gmail.com','555-1007','Denver','CO','USA','1984-03-14','2021-07-22','Active',11000,'Male'),
('Ava','Taylor','ava.taylor@gmail.com','555-1008','Miami','FL','USA','1995-08-30','2021-08-10','Active',9000,'Female'),
('Robert','Anderson','robert.anderson@gmail.com','555-1009','Atlanta','GA','USA','1980-01-19','2021-09-15','Inactive',6000,'Male'),
('Isabella','Thomas','isabella.thomas@gmail.com','555-1010','Phoenix','AZ','USA','1992-05-27','2021-10-20','Active',13000,'Female'),

('David','Jackson','david.jackson@gmail.com','555-1011','San Diego','CA','USA','1986-07-11','2021-11-08','Active',17000,'Male'),
('Mia','White','mia.white@gmail.com','555-1012','Los Angeles','CA','USA','1994-02-28','2021-12-12','Active',16000,'Female'),
('Joseph','Harris','joseph.harris@gmail.com','555-1013','Austin','TX','USA','1983-10-16','2022-01-14','Active',10000,'Male'),
('Charlotte','Martin','charlotte.martin@gmail.com','555-1014','Portland','OR','USA','1991-09-03','2022-02-20','Active',14000,'Female'),
('Thomas','Thompson','thomas.thompson@gmail.com','555-1015','Las Vegas','NV','USA','1978-06-17','2022-03-18','Inactive',5000,'Male'),

('Amelia','Garcia','amelia.garcia@gmail.com','555-1016','San Jose','CA','USA','1996-01-22','2022-04-11','Active',12000,'Female'),
('Charles','Martinez','charles.martinez@gmail.com','555-1017','San Antonio','TX','USA','1981-12-05','2022-05-19','Active',9000,'Male'),
('Harper','Robinson','harper.robinson@gmail.com','555-1018','Orlando','FL','USA','1997-03-09','2022-06-23','Active',15000,'Female'),
('Christopher','Clark','christopher.clark@gmail.com','555-1019','Philadelphia','PA','USA','1985-05-13','2022-07-15','Active',18000,'Male'),
('Evelyn','Rodriguez','evelyn.rodriguez@gmail.com','555-1020','Columbus','OH','USA','1990-11-29','2022-08-21','Inactive',7500,'Female'),

('Daniel','Lewis','daniel.lewis@gmail.com','555-1021','Charlotte','NC','USA','1987-04-07','2022-09-10','Active',11000,'Male'),
('Abigail','Lee','abigail.lee@gmail.com','555-1022','Indianapolis','IN','USA','1993-07-18','2022-10-17','Active',12500,'Female'),
('Matthew','Walker','matthew.walker@gmail.com','555-1023','Nashville','TN','USA','1982-02-11','2022-11-25','Active',14000,'Male'),
('Emily','Hall','emily.hall@gmail.com','555-1024','Memphis','TN','USA','1995-10-01','2022-12-14','Active',10000,'Female'),
('Anthony','Allen','anthony.allen@gmail.com','555-1025','Baltimore','MD','USA','1977-08-24','2023-01-20','Inactive',6500,'Male'),

('Elizabeth','Young','elizabeth.young@gmail.com','555-1026','Washington','DC','USA','1989-01-16','2023-02-12','Active',16000,'Female'),
('Mark','Hernandez','mark.hernandez@gmail.com','555-1027','Fort Worth','TX','USA','1984-06-08','2023-03-15','Active',13000,'Male'),
('Sofia','King','sofia.king@gmail.com','555-1028','Tucson','AZ','USA','1998-09-12','2023-04-19','Active',9000,'Female'),
('Donald','Wright','donald.wright@gmail.com','555-1029','Fresno','CA','USA','1975-03-22','2023-05-21','Inactive',5500,'Male'),
('Ella','Lopez','ella.lopez@gmail.com','555-1030','Sacramento','CA','USA','1994-12-31','2023-06-18','Active',14500,'Female'),

('Steven','Hill','steven.hill@gmail.com','555-1031','Kansas City','MO','USA','1983-11-05','2023-07-14','Active',10000,'Male'),
('Grace','Scott','grace.scott@gmail.com','555-1032','Omaha','NE','USA','1996-04-25','2023-08-22','Active',12000,'Female'),
('Paul','Green','paul.green@gmail.com','555-1033','Raleigh','NC','USA','1980-09-17','2023-09-16','Active',13500,'Male'),
('Chloe','Adams','chloe.adams@gmail.com','555-1034','Cleveland','OH','USA','1992-06-14','2023-10-10','Active',11000,'Female'),
('Andrew','Baker','andrew.baker@gmail.com','555-1035','Pittsburgh','PA','USA','1986-01-29','2023-11-20','Inactive',7000,'Male'),

('Lily','Nelson','lily.nelson@gmail.com','555-1036','Cincinnati','OH','USA','1997-05-06','2023-12-15','Active',9500,'Female'),
('Joshua','Carter','joshua.carter@gmail.com','555-1037','St. Louis','MO','USA','1981-07-23','2024-01-18','Active',15500,'Male'),
('Scarlett','Mitchell','scarlett.mitchell@gmail.com','555-1038','Richmond','VA','USA','1993-03-30','2024-02-21','Active',12500,'Female'),
('Kenneth','Perez','kenneth.perez@gmail.com','555-1039','New Orleans','LA','USA','1979-10-09','2024-03-19','Inactive',6000,'Male'),
('Victoria','Roberts','victoria.roberts@gmail.com','555-1040','Tampa','FL','USA','1991-12-17','2024-04-22','Active',17000,'Female'),

('Kevin','Turner','kevin.turner@gmail.com','555-1041','Jacksonville','FL','USA','1985-08-15','2024-05-12','Active',10000,'Male'),
('Aria','Phillips','aria.phillips@gmail.com','555-1042','Salt Lake City','UT','USA','1998-02-04','2024-06-16','Active',11500,'Female'),
('Brian','Campbell','brian.campbell@gmail.com','555-1043','Boise','ID','USA','1982-05-20','2024-07-18','Active',13000,'Male'),
('Nora','Parker','nora.parker@gmail.com','555-1044','Honolulu','HI','USA','1995-11-13','2024-08-20','Active',15000,'Female'),
('George','Evans','george.evans@gmail.com','555-1045','Anchorage','AK','USA','1976-04-28','2024-09-14','Inactive',5000,'Male'),

('Riley','Edwards','riley.edwards@gmail.com','555-1046','Albuquerque','NM','USA','1996-07-07','2024-10-18','Active',10500,'Female'),
('Edward','Collins','edward.collins@gmail.com','555-1047','El Paso','TX','USA','1980-12-21','2024-11-22','Active',14000,'Male'),
('Layla','Stewart','layla.stewart@gmail.com','555-1048','Birmingham','AL','USA','1994-03-16','2024-12-10','Active',12500,'Female'),
('Ronald','Sanchez','ronald.sanchez@gmail.com','555-1049','Louisville','KY','USA','1978-09-02','2025-01-15','Inactive',6500,'Male'),
('Zoey','Morris','zoey.morris@gmail.com','555-1050','Milwaukee','WI','USA','1999-06-26','2025-02-20','Active',18000,'Female');


-- =============================================
-- 3. Verify Records
-- =============================================

-- Initially first time

-- Query Time = Query Compilation time + WH Provisioning Time + Query Execution Time

Select * from customers -- 15 Million Records -- 01c3840b-0001-36d6-0000-001a18e38449

-- If same  Query executed again

-- Query time = Only Query Execution time.

Select * from customers -- 01c3840d-0001-35af-0000-001a18e3c301


-- In Python Notebooks we can write Python SNOWPARK Code.
-- In Notebooks we can write Jupyter Notebook code in Python / SQL.

SHOW WAREHOUSES;


-- Table 2

Create table Employee
(
    Eid int,
    Name varchar(30),
    Address Varchar(50),
    Phone int
)


-- Kind == PERMANENT Tables -- By DEFAULT

-- PERMANENT Tables have "Retention_time == 1 Day =  24 Hours"

show tables;

-- See metadata of table
Desc table employee


Create or Replace table Employee
(
    Eid int primary key,
    Name varchar(30) not null,
    Address Varchar, -- Varchar(max)
    Phone int DEFAULT 9999
)

desc table Employee;

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
