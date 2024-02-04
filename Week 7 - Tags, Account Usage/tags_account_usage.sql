
/*  https://frostyfriday.org/blog/2022/07/29/week-7-intermediate/

    Being a villain is hard enough as it is and data issues aren’t only a problem 
    for the good guys. Villains have got a lot of overhead and information to keep 
    track of and EVIL INC. has started using Snowflake for it’s needs. 

    However , you’ve noticed that the most important part of your superweapons have 
    been leaked :  The catch-phrase!

    Fortunately , you’ve set up tagging to allow you to keep track of who accessed 
    what information!

    Your challenge is to figure out who accessed data that was tagged with “Level Super 
    Secret A+++++++”

    Because it might be a bit too difficult to create users to access the data, 
    we’re using roles instead of users.
 */
use snowflake.account_usage;

 with tag_ref_columns as (
select tag_name,
       object_database||'.'||object_schema||'.'||object_name as table_name,
       column_name
  from table (FF_WEEK_7.information_schema.tag_references_all_columns ('FF_WEEK_7.SUPER_MONSTERS.MONSTER_INFORMATION', 'table'))
 union
select tag_name,
       object_database||'.'||object_schema||'.'||object_name as table_name,
       column_name
  from table (FF_WEEK_7.information_schema.tag_references_all_columns ('FF_WEEK_7.SUPER_VILLAINS.VILLAIN_INFORMATION', 'table'))
 union
select tag_name,
       object_database||'.'||object_schema||'.'||object_name as table_name,
       column_name
  from table (FF_WEEK_7.information_schema.tag_references_all_columns ('FF_WEEK_7.SUPER_WEAPONS.WEAPON_STORAGE_LOCATION', 'table'))
),
tag_info as (
select tag_name,
       tag_value,
       object_database||'.'||object_schema||'.'||object_name as table_name
  from tag_references
 where tag_value = 'Level Super Secret A+++++++'
),
queries as (
 select ah.query_id,
        doa.value:objectName::varchar as table_name,
        columns.value:columnName::varchar as column_name, 
        qh.role_name as role_name
   from access_history ah
   join query_history qh
     on qh.query_id = ah.query_id,
lateral flatten( input => direct_objects_accessed ) doa, 
lateral flatten( input => doa.value:columns ) columns
)
select th.tag_name,
       th.table_name,
       min(query_id),
       q.role_name
  from queries q
  join tag_ref_columns c
    on c.table_name = q.table_name
   and c.column_name = q.column_name
  join tag_info th
    on th.table_name = c.table_name
   and th.tag_name = c.tag_name
 group by th.tag_name,
       th.table_name,
       q.role_name
 order by th.table_name
;