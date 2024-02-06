/*  https://frostyfriday.org/blog/2022/08/05/week-8-basic/

    Whilst, as of the time of writing, the Snowflake-Streamlit integration isn’t
    here yet, FrostyFriday sees that as only more reason to get ahead of the curve 
    and start developing those Streamlit skills.
 */

create database if not exists frosty_friday;
create schema if not exists frosty;
drop schema if exists public;

grant usage on database frosty_friday to role public;
grant usage on schema frosty_friday.frosty to role public;
grant create streamlit on schema frosty_friday.frosty to role public;
grant create stage on schema frosty_friday.frosty to role public;
grant usage on warehouse xsmallw to role public;

--

create or replace file format payments_csv
   type = 'CSV'
   field_delimiter = ','
   skip_header = 1
   field_optionally_enclosed_by = '"';
create or replace table payments as 
select $1::int id,
       $2::datetime payment_date,
       $3::varchar card_type,
       $4::numeric(8,2) amount_spent
  from @internal_stage/payments.csv
       (file_format => 'payments_csv');
create or replace table payments_by_date as
select payment_date::date as payment_date, 
       sum(amount_spent) as amount_spent
  from payments 
 group by payment_date::date;

