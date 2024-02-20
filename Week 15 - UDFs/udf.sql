/*
    https://frostyfriday.org/blog/2022/09/23/week-15-intermediate/

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
CREATE OR REPLACE FUNCTION get_bucket (price numeric(8,2), bin_ranges array)
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
SELECT sale_date,
       price,
       get_bucket(price,[[0,1]
                        ,[2,310000]
                        ,[310001,400000]
                        ,[400001,500000]
                        ]) AS BUCKET_SET1,
       get_bucket(price,[[0,1]
                        ,[210001,350000]]) AS BUCKET_SET2,
       get_bucket(price,[[0,250000]
                        ,[250001,290001]
                        ,[290002,320000]
                        ,[320001,360000]
                        ,[360001,410000]
                        ,[410001,470001]
                        ]) AS BUCKET_SET3
 from home_sales
order by sale_date;
