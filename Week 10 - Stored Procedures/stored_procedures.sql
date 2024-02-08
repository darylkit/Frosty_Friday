/*  https://frostyfriday.org/blog/2022/08/19/week-10-hard/
    Frosty Consulting has a client who wants to be able to load data from a stage in a manual
    but dynamic fashion. To be more specific they want to be able to:
     
        - execute a single command (stored procedure)
        - do so manually, meaning it won’t be scheduled and there won’t be any Snowpipes
        - dynamically determine the warehouse size, if a file is over 10KB they want to use a
          small warehouse, anything under that size should be handled by an xsmall warehouse.

*/
-- Create the warehouses
create warehouse if not exists my_xsmall_wh 
    with warehouse_size = XSMALL
    auto_suspend = 120;
    
create warehouse if not exists my_small_wh 
    with warehouse_size = SMALL
    auto_suspend = 120;

-- Create the table
create or replace table transaction_amount
(
    date_time datetime,
    trans_amount double
);

-- Create the fileformat
create or replace file format transaction_amount_csv
type = 'CSV'
field_optionally_enclosed_by = '"'
skip_header = 1;

-- Create the stage
create or replace stage week_10_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_10/'
    file_format = transaction_amount_csv;

-- Create the stored procedure
create or replace procedure dynamic_warehouse_data_load(stage_name string, table_name string)
returns number
language python
runtime_version = '3.8'
packages = ('snowflake-snowpark-python==0.7.0')
handler = 'main'
as
$$
from snowflake.snowpark import Session
from snowflake.snowpark.types import StructType, StructField, IntegerType, DateType, TimestampType
    
# Get File List
def list_files(session: Session, stage_name: str) -> list:
    list_query = f"list @{stage_name}"
    results = session.sql(list_query).collect()
    return results

# Alter warehouse size
def alter_warehouse_size(session: Session, warehouse_size: str):
    # warehouse_size: 'X-SMALL', 'SMALL', 'MEDIUM', 'LARGE'
    sql_command = f"ALTER WAREHOUSE SET WAREHOUSE_SIZE = '{warehouse_size}'"
    session.sql(sql_command).collect()
    
# Insert Records function (Call change warehouse function)
def insert_records_from_file(session: Session, file_path: str, table_name:str, file_size: int) -> int:
    file_schema = StructType([
        StructField("date_time", TimestampType()),
        StructField("trans_amount", IntegerType())
    ])

    if file_size > 10000:
        alter_warehouse_size(session, 'SMALL')
    else:
        alter_warehouse_size(session, 'X-SMALL')
        
    df = session.read.schema(file_schema).option("skip_header", 1).csv(file_path) 
    df.write.mode("append").save_as_table(table_name)   
    return df.count()

# main
def main(session: Session, stage_name: str, table_name: str) -> int:

    files = list_files(session, stage_name)
    total_inserted = 0
    for file in files:
        file_name = file['name'].replace("s3://frostyfridaychallenges/challenge_10/","")
        file_path = f"@{stage_name}/{file_name}"
        file_size = file[1]
        total_inserted += insert_records_from_file(session, file_path, table_name, file_size, )
    return total_inserted
$$;

-- Call the stored procedure.
call dynamic_warehouse_data_load('week_10_frosty_stage', 'transaction_amount');