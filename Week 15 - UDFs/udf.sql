/*
    https://frostyfriday.org/blog/2022/09/23/week-15-intermediate/
    This week we’re working with small dataset about house sales that needs to be categorized according 
    to certain sliding bins. The catch however , is that the sizes and the number of bins can change quickly.

    The challenge is to create a function with a single name that does the following:

    can handle uneven bin sizes
    the first parameter must be the column that will inform your bins (in this example, we categorise 
    according to [price])

    the second parameter should specify the ranges of your bins (remember, these are uneven bins, 
    bin 1 could be 1 – 400, and bin 2 401 – 708, while bin 3 is 709 – 3000) how you do this is up to you: 
    you can specify lower bounds, upper bounds, both, count within each bin….
    if using SQL, as a minimum, it should be able to handle 2-6 bins, if using other languages then you 
    will find them flexible enough to allow you to do any number of bins


*/

--Code Setup
create table home_sales (
sale_date date,
price number(11, 2)
);

insert into home_sales (sale_date, price) values
('2013-08-01'::date, 290000.00),
('2014-02-01'::date, 320000.00),
('2015-04-01'::date, 399999.99),
('2016-04-01'::date, 400000.00),
('2017-04-01'::date, 470000.00),
('2018-04-01'::date, 510000.00);

--Create Function
create or replace function get_bucket (price numeric(8,2), bin_ranges array)
returns int
language python
runtime_version = '3.11'
handler='get_bucket'
as
$$
def get_bucket(price, bin_ranges):
    for index, (start_range, end_range) in enumerate(bin_ranges):
        bin_number = index + 1
        if start_range <= price <= end_range:
            return bin_number
        
    return bin_number
$$;

--Test Function
select sale_date,
       price,
       get_bucket(price,[[0,1]
                        ,[2,310000]
                        ,[310001,400000]
                        ,[400001,500000]
                        ]) as bucket_set1,
       get_bucket(price,[[0,1]
                        ,[210001,350000]]) as bucket_set2,
       get_bucket(price,[[0,250000]
                        ,[250001,290001]
                        ,[290002,320000]
                        ,[320001,360000]
                        ,[360001,410000]
                        ,[410001,470001]
                        ]) as bucket_set3
 from home_sales
order by sale_date;
