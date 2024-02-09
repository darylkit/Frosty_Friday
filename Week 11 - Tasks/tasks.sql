/* https://frostyfriday.org/blog/2022/08/26/week-11-basic/
   
   This week FrostyFarms are looking to create a set of chained tasks – two to be exact! 
   The farms have plenty of cows who produce milk for us, and from there, some of that milk 
   will be converted into skim/skimmed milk. We want our data to be edited to reflect the 
   fact that the fat percentage of the milk will determine how the data should look.

   Skim milk goes through the process of fat reduction in a centrifuge, therefore, whole milky 
   rows won’t need columns relating to that process, but the skim milky rows will.

   Create a parent and child task that will perform different actions on the different rows of 
   data depending on the fat percentage of the milk.
*/

-- Set the database and schema
use database frosty_friday;
use schema frosty;

create or replace file format whole_milk_csv
type = 'CSV'
field_optionally_enclosed_by = '"'
skip_header = 1;

-- Create the stage that points at the data.
create stage week_11_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_11/'
    file_format = whole_milk_csv;

-- Create the table as a CTAS statement.
create or replace table frosty_friday.frosty.week11 as
select m.$1 as milking_datetime,
        m.$2 as cow_number,
        m.$3 as fat_percentage,
        m.$4 as farm_code,
        m.$5 as centrifuge_start_time,
        m.$6 as centrifuge_end_time,
        m.$7 as centrifuge_kwph,
        m.$8 as centrifuge_electricity_used,
        m.$9 as centrifuge_processing_time,
        m.$10 as task_used
from @week_11_frosty_stage (file_format => whole_milk_csv, pattern => '.*milk_data.*[.]csv') m;


-- TASK 1: Remove all the centrifuge dates and centrifuge kwph and replace them with NULLs WHERE fat = 3. 
-- Add note to task_used.
create or replace task whole_milk_updates
    schedule = '1400 minutes'
    warehouse = xsmallw
as
    update frosty_friday.frosty.week11
       set centrifuge_start_time = NULL,
           centrifuge_end_time = NULL,
           centrifuge_kwph = NULL,
           centrifuge_electricity_used = NULL,
           centrifuge_processing_time = NULL,
           task_used = 'FROSTY_FRIDAY.FROSTY.WHOLE_MILK_UPDATES at '||current_timestamp()
     where fat_percentage = 3;
    
-- TASK 2: Calculate centrifuge processing time (difference between start and end time) WHERE fat != 3. 
-- Add note to task_used.
create or replace task skim_milk_updates
    warehouse = xsmallw
    after frosty_friday.frosty.whole_milk_updates
as
    update frosty_friday.frosty.week11
       set centrifuge_processing_time = DATEDIFF(MINUTE, centrifuge_start_time, centrifuge_end_time),
           centrifuge_electricity_used = (DATEDIFF(HOUR, centrifuge_start_time, centrifuge_end_time) * centrifuge_kwph)::numeric(8,2),
           task_used = 'FROSTY_FRIDAY.FROSTY.SKIM_MILK_UPDATES at '||current_timestamp()
     where fat_percentage != 3;


-- Manually execute the task.
alter task skim_milk_updates resume;
alter task whole_milk_updates resume;
execute task whole_milk_updates;

-- Check that the data looks as it should.
select * from week11;

-- Check that the numbers are correct.
select task_used, count(*) as row_count from week11 group by task_used;