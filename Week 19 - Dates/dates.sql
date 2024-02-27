/*
    https://frostyfriday.org/blog/2022/10/21/week-19-basic/

    This week we’re looking at something quirky but useful: date dimension together with a 
    UDF that calculates the number of business days between 2 dates (and because it’s an easy 
    challenge, we’re not excluding holidays).
 */

create or replace table date_dimension as 
select dateadd(day, (row_number() over(order by seq4())) - 1, date('2020-01-01')) as date,
       year(date) as year,
       monthname(date) as month,
       to_char(date,'MMMM') as full_month_name,
       dayofmonth(date) day_of_month,
       dayofweek(date) day_of_week,
       weekofyear(date) week_of_year,
       dayofyear(date) date_of_year
  from table(generator(rowcount => 1500)); 


--Create Function
create or replace function calculate_business_days (start_date date, end_date date, including boolean)
returns int
language python
runtime_version = '3.11'
handler='calculate_business_days'
as
$$
def calculate_business_days(start_date, end_date, including):
    difference = end_date - start_date;
    return difference.days + int(including)
$$;

--Test
create or replace table testing_data (
       id int,
       start_date date,
       end_date date
);
insert into testing_data (id, start_date, end_date) values (1, '11/11/2020', '9/3/2022');
insert into testing_data (id, start_date, end_date) values (2, '12/8/2020', '1/19/2022');
insert into testing_data (id, start_date, end_date) values (3, '12/24/2020', '1/15/2022');
insert into testing_data (id, start_date, end_date) values (4, '12/5/2020', '3/3/2022');
insert into testing_data (id, start_date, end_date) values (5, '12/24/2020', '6/20/2022');
insert into testing_data (id, start_date, end_date) values (6, '12/24/2020', '5/19/2022');
insert into testing_data (id, start_date, end_date) values (7, '12/31/2020', '5/6/2022');
insert into testing_data (id, start_date, end_date) values (8, '12/4/2020', '9/16/2022');
insert into testing_data (id, start_date, end_date) values (9, '11/27/2020', '4/14/2022');
insert into testing_data (id, start_date, end_date) values (10, '11/20/2020', '1/18/2022');
insert into testing_data (id, start_date, end_date) values (11, '12/1/2020', '3/31/2022');
insert into testing_data (id, start_date, end_date) values (12, '11/30/2020', '7/5/2022');
insert into testing_data (id, start_date, end_date) values (13, '11/28/2020', '6/19/2022');
insert into testing_data (id, start_date, end_date) values (14, '12/21/2020', '9/7/2022');
insert into testing_data (id, start_date, end_date) values (15, '12/13/2020', '8/15/2022');
insert into testing_data (id, start_date, end_date) values (16, '11/4/2020', '3/22/2022');
insert into testing_data (id, start_date, end_date) values (17, '12/24/2020', '8/29/2022');
insert into testing_data (id, start_date, end_date) values (18, '11/29/2020', '10/13/2022');
insert into testing_data (id, start_date, end_date) values (19, '12/10/2020', '7/31/2022');
insert into testing_data (id, start_date, end_date) values (20, '11/1/2020', '10/23/2021');

select id,
       start_date, 
       end_date,
       calculate_business_days(start_date, end_date, true) as including,
       calculate_business_days(start_date, end_date, false) as excluding
  from testing_data
 order by id;