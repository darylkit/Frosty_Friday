/*  https://frostyfriday.org/blog/2022/07/14/week-1/

    FrostyFriday Inc., your benevolent employer, has an S3 bucket that is filled with .csv data dumps. 
    This data is needed for analysis. Your task is to create an external stage, and load the csv files 
    directly from that stage into a table.
    
    The S3 bucket’s URI is: s3://frostyfridaychallenges/challenge_1/
*/

--Setup environment
CREATE DATABASE IF NOT EXISTS frosty_friday;
CREATE SCHEMA IF NOT EXISTS frosty;
DROP SCHEMA IF EXISTS public;

--Create S3 External Stage
CREATE OR REPLACE STAGE data_dumps 
	URL = 's3://frostyfridaychallenges/challenge_1/' 
	DIRECTORY = ( ENABLE = true );

LIST @data_dumps;

--Create Table
CREATE TABLE IF NOT EXISTS data_dump AS 
SELECT $1 AS val FROM @data_dumps;

SELECT * FROM data_dump;