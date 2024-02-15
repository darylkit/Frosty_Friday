/*  https://frostyfriday.org/blog/2022/09/09/week-13-basic-snowflake-intermediate-non-snowflake/
    
    This week we’ve got a bit of a deceptive problem that’s very easy to understand but tricky to execute in SQL.
    The inventory management has been a bit spotty with irregular checks on different dates, and an inventory system 
    that can really use some TLC.

    We can easily extrapolate that the stock amount hasn’t been filled out because it hasn’t changed and that the previous 
    value that HAS been filled out still applies.

    Translating this into SQL however, is your challenge for today.
 */

--Retrieve dates with missing stock amount
 with spot_dates as (
    select product,
           date_of_check
      from testing_data
     where stock_amount is null
)
--Get the last date with stock amount before the spot dates
, last_date_before_spot as (
    select s.product,
           s.date_of_check,
           max(t.date_of_check) as last_date_of_check
      from spot_dates s
      left join testing_data t
        on s.product = t.product
       and t.date_of_check <= s.date_of_check
       and t.stock_amount is not null
     group by s.product,
           s.date_of_check
)
--Get the stock amount from the last date before the spot dates occurred
select distinct 
       t.id,
       t.product,
       t.stock_amount,
       coalesce(t.stock_amount,t2.stock_amount) as stock_amount_filled_out,
       t.date_of_check
  from testing_data t
  left join last_date_before_spot l
    on t.product = l.product
   and t.date_of_check = l.date_of_check
  left join testing_data t2
    on t2.product = l.product
   and t2.date_of_check = l.last_date_of_check
 where stock_amount_filled_out is not null
 order by t.product,
       t.date_of_check;

--The snowflake way using last_value()
select id,
       product,
       stock_amount,
       last_value(stock_amount ignore nulls) over (partition by product order by date_of_check rows between unbounded preceding and current row ) stock_amount_filled_out,
       date_of_check
  from testing_data;