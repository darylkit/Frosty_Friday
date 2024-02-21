create or replace file format json_ff
    type = json
    strip_outer_array = TRUE;
    
create or replace stage week_16_frosty_stage
    url = 's3://frostyfridaychallenges/challenge_16/'
    file_format = json_ff;

create or replace table <schema>.week16 as
select t.$1:word::text word, t.$1:url::text url, t.$1:definition::variant definition  
from @week_16_frosty_stage (file_format => 'json_ff', pattern=>'.*week16.*') t;