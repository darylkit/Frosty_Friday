/* https://frostyfriday.org/blog/2022/09/16/week-14-basic/

   This week we’re going to be undoing what people usually do and we’re going to be 
   turning a table into a JSON VARIANT object.
   
   Here we have a table with info on a set of superheroes, your job is to turn this 
   table into a JSON VARIANT object.

 */
select to_json(
       object_construct('country_of_residence', country_of_residence, 
                        'superhero_name', superhero_name,
                        'superpowers', array_construct_compact(
                                            superpower, 
                                            second_superpower, 
                                            third_superpower))) as superhero_json
from week_14;