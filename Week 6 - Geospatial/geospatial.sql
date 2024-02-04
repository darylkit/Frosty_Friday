/*  https://frostyfriday.org/blog/2022/07/22/week-6-hard/

    This week we’re going to play with spatial functions. Frosty Lobbying is thinking of supporting
    some candidates in the next UK General Election. What they need is to understand the geographic 
    spread of candidates by nation/region of the UK.

    Your job is to build both the nations/regions and parliamentary seats into polygons, and then work
    out how many Westminster seats intersect with region polygons. 

    Be wary that some seats may sit within two different regions, some may not sit within any (Northern Ireland 
    is not included in the data provided) and some may just be awkward.

    Note: Within the data, the ‘part’ column is an integer given to each landmass that makes up that 
    region/nation/constituency – for example, the Isle of Mull could be ‘part 34’ of Scotland, and 
    ‘part 12’ of the Argyll and Bute constituency.
*/
--Setup environment
create database if not exists frosty_friday;
create schema if not exists frosty;
drop schema if exists public;

alter session set geography_output_format = 'WKT';

create or replace file format geospatial_csv
   type = 'CSV'
   field_delimiter = ','
   skip_header = 1
   field_optionally_enclosed_by = '"';

create or replace table nations_and_regions as
select $1 as nation_or_region_name,
       $2 as type,
       $3 as sequence_num,
       $4::real as longitude,
       $5::real as latitude,
       $6::int as part,
       st_makepoint(longitude,latitude) as coordinates
  from @internal_stage/nations_and_regions.csv
       (file_format => 'geospatial_csv');

create or replace table westminster_constituency_points as 
select $1 as constituency, 
       $2 as sequence_num,
       $3::varchar as longitude,
       $4::varchar as latitude, 
       $5::int as part,
       st_makepoint(longitude,latitude) as coordinates
  from @internal_stage/westminster_constituency_points.csv
       (file_format => 'geospatial_csv');

create or replace view vw_nations_and_regions as
with collect as (
    with starting_point as (
        select nation_or_region_name,
               type,
               part,
               coordinates as starting_coordinates
          from nations_and_regions
         where sequence_num = 0),
coordinates as (
        select nr.nation_or_region_name,
               nr.type,
               nr.part,
               st_collect(nr.coordinates) as coordinates
          from nations_and_regions nr
         group by nation_or_region_name, type, part)
        select nr.nation_or_region_name,
               nr.type,
               nr.part,
               st_makepolygon(st_makeline(starting_coordinates, coordinates)) as polygon
          from coordinates nr
         inner join starting_point sp
            on sp.nation_or_region_name = nr.nation_or_region_name
           and nr.type = sp.type
           and nr.part = sp.part
         order by nr.part)
select nation_or_region_name,
       st_collect(polygon) as polygon
  from collect
 group by nation_or_region_name;

create or replace view vw_westminster_constituency_points as
with collect as (
    with starting_point as (
        select constituency,
               part,
               coordinates as starting_coordinates
          from westminster_constituency_points
         where sequence_num = 0),
    coordinates as (
        select constituency,
               part,
               st_collect(coordinates) as coordinates
          from westminster_constituency_points 
         group by constituency, part)
    select nr.constituency,
           nr.part,
           st_makepolygon(st_makeline(starting_coordinates, coordinates)) as polygon
      from coordinates nr
     inner join starting_point sp
        on sp.constituency = nr.constituency
       and nr.part = sp.part
     order by nr.part)
select constituency,
       st_collect(polygon) as polygon
  from collect
 group by constituency;


select nation_or_region_name as nation_or_region, 
       count(wc.constituency) as intersecting_constituencies
  from vw_nations_and_regions nr
 inner join vw_westminster_constituency_points wc
    on st_intersects(wc.polygon, nr.polygon)
 group by nation_or_region_name
 order by 2 desc;


