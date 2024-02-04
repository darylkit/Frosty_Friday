/*  https://frostyfriday.org/blog/2022/07/15/week-2-intermediate/

    A stakeholder in the HR department wants to do some change-tracking but 
    is concerned that the stream which was created for them gives them too 
    much info they don’t care about. 
    
*/

--Setup environment
create database if not exists frosty_friday;
create schema if not exists frosty;
drop schema if exists public;

--create internal stage
create stage if not exists internal_stage 
	directory = ( enable = true );

list @internal_stage;

-- query the infer_schema function.
select *
  from table(
    infer_schema(
      location=>'@FROSTY_FRIDAY.FROSTY.INTERNAL_STAGE/employees.parquet'
      , FILE_FORMAT=>'frosty_parquet'
      , IGNORE_CASE=>TRUE
      )
    );
    
--Create table
create or replace table frosty_friday.frosty.employees 
(   employee_id number , 
    first_name varchar , 
    last_name varchar , 
    email varchar , 
    street_num number , 
    street_name varchar , 
    city varchar , 
    postcode varchar , 
    country varchar , 
    country_code varchar , 
    time_zone varchar , 
    payroll_iban varchar , 
    dept varchar , 
    job_title varchar , 
    education varchar , 
    title varchar , 
    suffix varchar 
); 

--create file format
create temp file format frosty_friday.frosty.frosty_parquet
	type=parquet
    replace_invalid_characters=true
    binary_as_text=false; 

--load into employees table
copy into frosty_friday.frosty.employees
from 
(   select $1:employee_id::number, 
           $1:first_name::varchar, 
           $1:last_name::varchar, 
           $1:email::varchar, 
           $1:street_num::number, 
           $1:street_name::varchar, 
           $1:city::varchar, 
           $1:postcode::varchar, 
           $1:country::varchar, 
           $1:country_code::varchar, 
           $1:time_zone::varchar, 
           $1:payroll_iban::varchar, 
           $1:dept::varchar, 
           $1:job_title::varchar, 
           $1:education::varchar, 
           $1:title::varchar, 
           $1:suffix::varchar
	from '@FROSTY_FRIDAY.FROSTY.INTERNAL_STAGE/employees.parquet') 
FILE_FORMAT = frosty_friday.frosty.frosty_parquet;

--create view to only show dept and job_title in our stream
create or replace view vw_employees as 
select employee_id,
       dept,
       job_title
from frosty_friday.frosty.employees;

select * from vw_employees;

--create stream
create or replace stream employeesstream on view frosty_friday.frosty.vw_employees;

--test update
update frosty_friday.frosty.employees set country = 'Japan' where employee_id = 8;
update frosty_friday.frosty.employees set last_name = 'Forester' where employee_id = 22;
update frosty_friday.frosty.employees set dept = 'Marketing' where employee_id = 25;
update frosty_friday.frosty.employees set title = 'Ms' where employee_id = 32;
update frosty_friday.frosty.employees set job_title = 'Senior Financial Analyst' where employee_id = 68;

--Check Stream Values
SELECT * FROM frosty_friday.frosty.employeesStream;

      