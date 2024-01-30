/*  https://frostyfriday.org/blog/2022/07/15/week-2-intermediate/

    A stakeholder in the HR department wants to do some change-tracking but 
    is concerned that the stream which was created for them gives them too 
    much info they don’t care about. 
    
*/

--Setup environment
CREATE DATABASE IF NOT EXISTS frosty_friday;
CREATE SCHEMA IF NOT EXISTS frosty;
DROP SCHEMA IF EXISTS public;

--Create Internal Stage
CREATE STAGE IF NOT EXISTS internal_stage 
	DIRECTORY = ( ENABLE = true );

LIST @internal_stage;

-- Query the INFER_SCHEMA function.
SELECT *
  FROM TABLE(
    INFER_SCHEMA(
      LOCATION=>'@FROSTY_FRIDAY.FROSTY.INTERNAL_STAGE/employees.parquet'
      , FILE_FORMAT=>'frosty_parquet'
      , IGNORE_CASE=>TRUE
      )
    );
    
--Create table
CREATE OR REPLACE TABLE frosty_friday.frosty.employees 
(   employee_id NUMBER , 
    first_name VARCHAR , 
    last_name VARCHAR , 
    email VARCHAR , 
    street_num NUMBER , 
    street_name VARCHAR , 
    city VARCHAR , 
    postcode VARCHAR , 
    country VARCHAR , 
    country_code VARCHAR , 
    time_zone VARCHAR , 
    payroll_iban VARCHAR , 
    dept VARCHAR , 
    job_title VARCHAR , 
    education VARCHAR , 
    title VARCHAR , 
    suffix VARCHAR 
); 

--Create File Format
CREATE TEMP FILE FORMAT frosty_friday.frosty.frosty_parquet
	TYPE=PARQUET
    REPLACE_INVALID_CHARACTERS=TRUE
    BINARY_AS_TEXT=FALSE; 

--Load into employees table
COPY INTO frosty_friday.frosty.employees
FROM 
(   SELECT $1:employee_id::NUMBER, 
           $1:first_name::VARCHAR, 
           $1:last_name::VARCHAR, 
           $1:email::VARCHAR, 
           $1:street_num::NUMBER, 
           $1:street_name::VARCHAR, 
           $1:city::VARCHAR, 
           $1:postcode::VARCHAR, 
           $1:country::VARCHAR, 
           $1:country_code::VARCHAR, 
           $1:time_zone::VARCHAR, 
           $1:payroll_iban::VARCHAR, 
           $1:dept::VARCHAR, 
           $1:job_title::VARCHAR, 
           $1:education::VARCHAR, 
           $1:title::VARCHAR, 
           $1:suffix::VARCHAR
	FROM '@FROSTY_FRIDAY.FROSTY.INTERNAL_STAGE/employees.parquet') 
FILE_FORMAT = frosty_friday.frosty.frosty_parquet;

--Create view to only show dept and job_title in our stream
CREATE OR REPLACE VIEW vw_employees AS 
SELECT employee_id,
       dept,
       job_title
FROM frosty_friday.frosty.employees;

SELECT * FROM vw_employees;

--Create stream
CREATE OR REPLACE STREAM employeesStream ON VIEW frosty_friday.frosty.vw_employees;

--Test Update
UPDATE FROSTY_FRIDAY.FROSTY.employees SET COUNTRY = 'Japan' WHERE EMPLOYEE_ID = 8;
UPDATE FROSTY_FRIDAY.FROSTY.employees SET LAST_NAME = 'Forester' WHERE EMPLOYEE_ID = 22;
UPDATE FROSTY_FRIDAY.FROSTY.employees SET DEPT = 'Marketing' WHERE EMPLOYEE_ID = 25;
UPDATE FROSTY_FRIDAY.FROSTY.employees SET TITLE = 'Ms' WHERE EMPLOYEE_ID = 32;
UPDATE FROSTY_FRIDAY.FROSTY.employees SET JOB_TITLE = 'Senior Financial Analyst' WHERE EMPLOYEE_ID = 68;

--Check Stream Values
SELECT * FROM frosty_friday.frosty.employeesStream;

      