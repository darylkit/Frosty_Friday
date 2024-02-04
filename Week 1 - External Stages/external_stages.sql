/*  https://frostyfriday.org/blog/2022/07/14/week-1/

    FrostyFriday Inc., your benevolent employer, has an S3 bucket that is filled with .csv data dumps. 
    This data is needed for analysis. Your task is to create an external stage, and load the csv files 
    directly from that stage into a table.
    
    The S3 bucket’s URI is: s3://frostyfridaychallenges/challenge_1/
*/

--Setup environment
create database if not exists frosty_friday;
create schema if not exists frosty;
drop schema if exists public;

--create s3 external stage
create or replace stage data_dumps 
	URL = 's3://frostyfridaychallenges/challenge_1/' 
	directory = ( enable = true );

list @data_dumps;

--create table
create table if not exists data_dump as 
select $1 as val from @data_dumps;

select * from data_dump;