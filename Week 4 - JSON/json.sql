/*  https://frostyfriday.org/blog/2022/07/15/week-4-hard/

    Frosty Friday Consultants has been hired by the University of Frost’s history department; 
    they want data on monarchs in their data warehouse for analysis. Your job is to take the JSON file,
    ingest it into the data warehouse, and parse it into a table

    Create a table that lists all the files in our stage that contain any of the keywords in the keywords.csv file.

    The S3 bucket’s URI is: s3://frostyfridaychallenges/challenge_3/
*/

--Setup environment
CREATE DATABASE IF NOT EXISTS frosty_friday;
CREATE SCHEMA IF NOT EXISTS frosty;
DROP SCHEMA IF EXISTS public;

CREATE OR REPLACE TABLE raw_source (
  SRC VARIANT);
  
--Load Raw data into a table
COPY INTO raw_source
FROM '@FROSTY_FRIDAY.FROSTY.INTERNAL_STAGE/Spanish_Monarchs.json'
FILE_FORMAT = (TYPE = JSON);

SELECT * FROM raw_source;

CREATE OR REPLACE TABLE spanish_monarchs AS
SELECT ROW_NUMBER() OVER (ORDER BY monarchs.value:Birth::date) AS ID,
       ROW_NUMBER() OVER (PARTITION BY houses.value:House ORDER BY monarchs.index) as INTER_HOUSE_ID,
       src.value:Era::varchar as ERA,
       houses.value:House::varchar as HOUSE,
       monarchs.value:Name::varchar as NAME,
       monarchs.value:Nickname[0]::varchar AS NICKNAME_1,
       monarchs.value:Nickname[1]::varchar AS NICKNAME_2,
       monarchs.value:Nickname[2]::varchar AS NICKNAME_3,
       monarchs.value:Birth::date as BIRTH,
       monarchs.value:"Place of Birth"::varchar AS PLACE_OF_BIRTH,
       monarchs.value:"Start of Reign"::date AS START_OF_REIGN,
       COALESCE(monarchs.value:"Consort\/Queen Consort"[0],monarchs.value:"Consort\/Queen Consort")::varchar AS QUEEN_OR_QUEEN_CONSORT_1,
       monarchs.value:"Consort\/Queen Consort"[1]::varchar AS QUEEN_OR_QUEEN_CONSORT_2,
       monarchs.value:"Consort\/Queen Consort"[2]::varchar AS QUEEN_OR_QUEEN_CONSORT_3,
       monarchs.value:"End of Reign"::date AS END_OF_REIGN,
       monarchs.value:Duration::varchar AS DURATION,
       monarchs.value:Death::date AS DEATH,
       TRIM(REPLACE(LOWER(monarchs.value:"Age at Time of Death"),'years',''))::int AS AGE_AT_THE_TIME_OF_DEATH_YEARS,
       monarchs.value:"Place of Death"::varchar AS PLACE_OF_DEATH,
       monarchs.value:"Burial Place"::varchar AS BURIAL_PLACE
FROM raw_source,
LATERAL FLATTEN( INPUT => src ) src,
LATERAL FLATTEN( INPUT => src.value:Houses) houses,
LATERAL FLATTEN( INPUT => houses.value:Monarchs) monarchs
ORDER BY ID;

SELECT * FROM spanish_monarchs;