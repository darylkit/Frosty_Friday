/*
    https://frostyfriday.org/blog/2022/10/07/week-17-intermediate/

    Brooklyn is having issues with a particular supergang : The rectangles.

    They focus on controlling busy points within the city and carve out a particularly shaped area of influence: 
    a rectangle. 1 point of interest, or node, is central to their operation, they control every other node within 
    750 meters.

    They only seem to settle down if a node has at least 3 other nodes within 750 of a central node and they’ve also 
    got a strange fascination with electronic stores. This means that there will be at least 4 nodes in a group.

    Data is contained within the OpenStreetMap New York (by Sonra) on the Snowflake Marketplace
*/
-- If 3 nodes are within 750 meters of another central node, group these together.
with group_nodes as (
    select e.id, 
           e.shop, 
           e.name,
           e.coordinates,
           n.id as node_reached,
           ST_CENTROID(n.coordinates) as coordinates_reached,
           count(*) over (partition by e.id, e.shop, e.name) node_count
      from v_osm_ny_shop_electronics e
      join v_osm_ny_shop_electronics n
        on ST_DISTANCE(ST_CENTROID(e.coordinates),ST_CENTROID(n.coordinates)) <= 750
       and e.addr_city = n.addr_city
     where e.addr_city = 'Brooklyn'
   qualify node_count >= 3
),
node_aggregate AS (
    SELECT v.id,
           MIN(ST_X(v.coordinates_reached)) AS min_x,
           MAX(ST_X(v.coordinates_reached)) AS max_x,
           MIN(ST_Y(v.coordinates_reached)) AS min_y,
           MAX(ST_Y(v.coordinates_reached)) AS max_y
      FROM group_nodes v
     group by v.id
),
-- Build a rectangle containing these groups , 1 rectangle per group
node_box as (
    select id, 
           ST_COLLECT(TO_GEOGRAPHY('POLYGON((' ||
                min_x || ' ' || min_y || ', ' ||
                min_x || ' ' || max_y || ', ' ||
                max_x || ' ' || max_y || ', ' ||
                max_x || ' ' || min_y || ', ' ||
                min_x || ' ' || min_y || 
            '))')) AS bounding_box,
           st_area(bounding_box)
    from node_aggregate
   group by id  
)
SELECT ST_COLLECT(n.bounding_box)
  FROM node_box n;