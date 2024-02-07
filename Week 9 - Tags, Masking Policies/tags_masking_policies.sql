/* https://frostyfriday.org/blog/2022/08/12/week-9-intermediate/
    It’s not just bad guys that need to guard their secrets!
    Superheroes are our first line of defence against those evil-doers so we really 
    need to protect their information.

    Running a superhero organisation however is a big job so we’ve got a lot of people
    that have access to our systems and we need to make sure that the true identity of
    our heroes is never revealed!

    HR is advocating for a more personal touch to our business though and has requested
    that some staff should be able to see the first names of the superheroes to connect 
    on a more basic level. Higher ups should still be able to see everything !
    
    With the constant changing roles within the organisation , we’d really like 
    something that’s dynamic and can handle roles that haven’t been created yet.
*/
create tag confidential_info comment = 'confidential_info';

 alter table data_to_be_masked
modify column first_name
   set tag confidential_info = 'first';
  
 alter table data_to_be_masked
modify column last_name
   set tag confidential_info = 'last';
  
create or replace masking policy super_mask as (val string) returns string ->
  case when system$get_tag_on_current_column('confidential_info') in ('first')
        and is_role_in_session('foo1')
       then val
       when system$get_tag_on_current_column('confidential_info') in ('first','last')
        and is_role_in_session('foo2')
       then val
       else '******'
  end;

alter tag confidential_info set masking policy super_mask;

USE ROLE foo1;
SELECT * FROM data_to_be_masked;
USE ROLE foo2;
SELECT * FROM data_to_be_masked;
USE ROLE accountadmin;
SELECT * FROM data_to_be_masked;
