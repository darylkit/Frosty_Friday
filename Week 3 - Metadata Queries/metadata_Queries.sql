/*  https://frostyfriday.org/blog/2022/07/15/week-3-basic/

    Frosty Friday Inc., your benevolent employer, has an S3 bucket that was filled with .csv data dumps. 
    These dumps aren’t very complicated and all have the same style and contents. All of these files 
    should be placed into a single table.

    Create a table that lists all the files in our stage that contain any of the keywords in the keywords.csv file.

    The S3 bucket’s URI is: s3://frostyfridaychallenges/challenge_3/
*/

--Setup environment
create database if not exists frosty_friday;
create schema if not exists frosty;
drop schema if exists public;

--create s3 external stage
create or replace stage data_dumps 
	url = 's3://frostyfridaychallenges/challenge_3/' 
	directory = ( enable = true );

create table if not exists stage_table as 
--retrieve file names and row count. deduct 1 for the header.
select metadata$filename as filename, 
       count(metadata$file_row_number)-1 as number_of_rows
from @data_dumps d
where exists (--subselect to filter keywords
              select $1 as keyword
                from @data_dumps k
               where metadata$filename = 'challenge_3/keywords.csv'
                 and metadata$file_row_number > 1
                 and d.metadata$filename like '%'||$1||'%' 
             )
group by filename;

select *
from stage_table;
