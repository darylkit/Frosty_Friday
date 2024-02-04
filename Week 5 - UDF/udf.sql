/*  https://frostyfriday.org/blog/2022/07/15/week-5-basic/

    This week, we’re using a feature that, at the time of writing, is pretty hot off the press :
    Python in Snowflake.

    To start out  create a simple table with a single column with a number, the size and amount are up to you, 
    After that we’ll start with a very basic function: multiply those numbers by 3.

    The challenge here is not ‘build a very difficult python function’ but to build and use the function in Snowflake.
    We can test the code with a simple select statement :

    SELECT timesthree(start_int)
    FROM FF_week_5
*/

--Setup environment
create database if not exists frosty_friday;
create schema if not exists frosty;
drop schema if exists public;

--create test table
create or replace table ff_week_5 (start_int int);
insert into ff_week_5 values (2),(42),(87);

--create function
create or replace function timesthree (start_int int)
returns integer
language python
runtime_version = '3.11'
handler='timesthree_py'
as
$$
def timesthree_py(start_int):
  return start_int*3
$$;

--Test Function
select start_int, 
       timesthree(start_int) as timesthree
  from ff_week_5

