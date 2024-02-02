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
CREATE DATABASE IF NOT EXISTS frosty_friday;
CREATE SCHEMA IF NOT EXISTS frosty;
DROP SCHEMA IF EXISTS public;

ALTER SESSION SET geography_output_format = 'WKT';

CREATE OR REPLACE FILE FORMAT geospatial_csv
   TYPE = 'CSV'
   FIELD_DELIMITER = ','
   SKIP_HEADER = 1
   FIELD_OPTIONALLY_ENCLOSED_BY = '"';

CREATE OR REPLACE TABLE nations_and_regions AS
select $1 as nation_or_region_name,
       $2 as type,
       $3 as sequence_num,
       $4::real as longitude,
       $5::real as latitude,
       $6::int as part,
       ST_MAKEPOINT(longitude,latitude) as coordinates
from @internal_stage/nations_and_regions.csv
(file_format => 'geospatial_csv');

CREATE OR REPLACE TABLE westminster_constituency_points AS 
select $1 as constituency, 
       $2 as sequence_num,
       $3::varchar as longitude,
       $4::varchar as latitude, 
       $5::int as part,
       ST_MAKEPOINT(longitude,latitude) as coordinates
from @internal_stage/westminster_constituency_points.csv
(file_format => 'geospatial_csv');

CREATE OR REPLACE VIEW vw_nations_and_regions AS
WITH collect AS (
    WITH starting_point AS (
        SELECT 
            nation_or_region_name,
            type,
            part,
            coordinates AS starting_coordinates
        FROM nations_and_regions
        WHERE sequence_num = 0),
    coordinates AS (
        SELECT 
            nr.nation_or_region_name,
            nr.type,
            nr.part,
            st_collect(nr.coordinates) as coordinates
        FROM nations_and_regions nr
        GROUP BY nation_or_region_name, type, part)
    select nr.nation_or_region_name,
            nr.type,
            nr.part,
            st_makepolygon(st_makeline(starting_coordinates, coordinates)) AS polygon
    FROM coordinates nr
    INNER JOIN starting_point sp
    ON sp.nation_or_region_name = nr.nation_or_region_name
    AND nr.type = sp.type
    AND nr.part = sp.part
    ORDER BY nr.part)
SELECT nation_or_region_name,
       ST_COLLECT(polygon) as polygon
FROM collect
GROUP BY nation_or_region_name;

CREATE OR REPLACE VIEW vw_westminster_constituency_points AS
WITH collect AS (
    WITH starting_point AS (
        SELECT 
            constituency,
            part,
            coordinates AS starting_coordinates
        FROM westminster_constituency_points
        WHERE sequence_num = 0),
    coordinates AS (
        SELECT 
            constituency,
            part,
            st_collect(coordinates) as coordinates
        FROM westminster_constituency_points 
        GROUP BY constituency, part)
    select nr.constituency,
            nr.part,
            st_makepolygon(st_makeline(starting_coordinates, coordinates)) AS polygon
    FROM coordinates nr
    INNER JOIN starting_point sp
    ON sp.constituency = nr.constituency
    AND nr.part = sp.part
    ORDER BY nr.part)
SELECT constituency,
       ST_COLLECT(polygon) as polygon
FROM collect
GROUP BY constituency;


SELECT nation_or_region_name as NATION_OR_REGION, 
       COUNT(wc.constituency) as INTERSECTING_CONSTITUENCIES
FROM vw_nations_and_regions nr
INNER JOIN vw_westminster_constituency_points wc
ON ST_INTERSECTS(wc.polygon, nr.polygon)
GROUP BY nation_or_region_name
ORDER BY 2 DESC;


