/*  https://frostyfriday.org/blog/2022/07/15/week-4-hard/

    Frosty Friday Consultants has been hired by the University of Frost’s history department; 
    they want data on monarchs in their data warehouse for analysis. Your job is to take the JSON file,
    ingest it into the data warehouse, and parse it into a table

    Create a table that lists all the files in our stage that contain any of the keywords in the keywords.csv file.

    The S3 bucket’s URI is: s3://frostyfridaychallenges/challenge_3/
*/

--Setup environment
create database if not exists frosty_friday;
create schema if not exists frosty;
drop schema if exists public;

create or replace table raw_source (
  src variant);
  
--load raw data into a table
copy into raw_source
from '@frosty_friday.frosty.internal_stage/spanish_monarchs.json'
file_format = (type = json);

select * from raw_source;

create or replace table spanish_monarchs as
 select row_number() over (order by monarchs.value:Birth::date) as ID,
        row_number() over (partition by houses.value:House ORDER by monarchs.index) as INTER_HOUSE_ID,
        src.value:Era::varchar as ERA,
        houses.value:House::varchar as HOUSE,
        monarchs.value:Name::varchar as NAME,
        monarchs.value:Nickname[0]::varchar as NICKNAME_1,
        monarchs.value:Nickname[1]::varchar as NICKNAME_2,
        monarchs.value:Nickname[2]::varchar as NICKNAME_3,
        monarchs.value:Birth::date as BIRTH,
        monarchs.value:"Place of Birth"::varchar as PLACE_OF_BIRTH,
        monarchs.value:"Start of Reign"::date as START_OF_REIGN,
        coalesce(monarchs.value:"Consort\/Queen Consort"[0],monarchs.value:"Consort\/Queen Consort")::varchar as QUEEN_OR_QUEEN_CONSORT_1,
        monarchs.value:"Consort\/Queen Consort"[1]::varchar as QUEEN_OR_QUEEN_CONSORT_2,
        monarchs.value:"Consort\/Queen Consort"[2]::varchar as QUEEN_OR_QUEEN_CONSORT_3,
        monarchs.value:"End of Reign"::date as END_OF_REIGN,
        monarchs.value:Duration::varchar as DURATION,
        monarchs.value:Death::date as DEATH,
        trim(replace(lower(monarchs.value:"Age at Time of Death"),'years',''))::int as AGE_AT_THE_TIME_OF_DEATH_YEARS,
        monarchs.value:"Place of Death"::varchar as PLACE_OF_DEATH,
        monarchs.value:"Burial Place"::varchar as BURIAL_PLACE
   from raw_source,
lateral flatten( input => src ) src,
lateral flatten( input => src.value:Houses) houses,
lateral flatten( input => houses.value:Monarchs) monarchs
  order by id;

select * from spanish_monarchs;