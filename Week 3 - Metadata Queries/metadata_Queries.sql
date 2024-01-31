/*  https://frostyfriday.org/blog/2022/07/15/week-3-basic/

    Frosty Friday Inc., your benevolent employer, has an S3 bucket that was filled with .csv data dumps. 
    These dumps aren’t very complicated and all have the same style and contents. All of these files 
    should be placed into a single table.

    Create a table that lists all the files in our stage that contain any of the keywords in the keywords.csv file.

    The S3 bucket’s URI is: s3://frostyfridaychallenges/challenge_3/
*/

--Setup environment
CREATE DATABASE IF NOT EXISTS frosty_friday;
CREATE SCHEMA IF NOT EXISTS frosty;
DROP SCHEMA IF EXISTS public;

--Create S3 External Stage
CREATE OR REPLACE STAGE data_dumps 
	URL = 's3://frostyfridaychallenges/challenge_3/' 
	DIRECTORY = ( ENABLE = true );

CREATE TABLE IF NOT EXISTS stage_table AS 
--Retrieve file names and row count. Deduct 1 for the header.
SELECT METADATA$FILENAME as filename, 
       COUNT(METADATA$FILE_ROW_NUMBER)-1 as number_of_rows
FROM @data_dumps d
WHERE EXISTS (--Subselect to filter keywords
              SELECT $1 AS keyword
              FROM @data_dumps k
              WHERE METADATA$FILENAME = 'challenge_3/keywords.csv'
              AND METADATA$FILE_ROW_NUMBER > 1
              AND d.METADATA$FILENAME like '%'||$1||'%' 
             )
GROUP BY filename;

SELECT *
FROM stage_table;
