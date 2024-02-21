/*
    https://frostyfriday.org/blog/2022/09/30/week-16-intermediate/
    Tis Friday and what a wonderful day for flexing those JSON-parsing muscles!
 */

--Test Script
select *
from (
    select word,
           url,
           meanings.value:partOfSpeech::string  part_of_speech,
           meanings.value:antonyms::string      general_synonyms,
           meanings.value:synonyms::string      general_antonyms,
           definitions.value:definition::string definition,
           definitions.value:example::string    example_if_applicable,
           definitions.value:synonyms::string   definitional_synonyms,
           definitions.value:antonyms::string   definitional_antonyms
      from week16,
   lateral flatten( input => definition ) definition,
   lateral flatten( input => definition.value:meanings) meanings,   
   lateral flatten( input => meanings.value:definitions) definitions
) sub
where word like 'l%';

--Count Check
select count(word), count(distinct word)
from (
    select word,
           url,
           meanings.value:partOfSpeech::string  part_of_speech,
           meanings.value:antonyms::string      general_synonyms,
           meanings.value:synonyms::string      general_antonyms,
           definitions.value:definition::string definition,
           definitions.value:example::string    example_if_applicable,
           definitions.value:synonyms::string   definitional_synonyms,
           definitions.value:antonyms::string   definitional_antonyms
      from week16,
   lateral flatten( input => definition ) definition,
   lateral flatten( input => definition.value:meanings) meanings,   
   lateral flatten( input => meanings.value:definitions) definitions
) sub;