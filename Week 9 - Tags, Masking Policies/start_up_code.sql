--CREATE DATA
CREATE OR REPLACE TABLE data_to_be_masked(first_name varchar, last_name varchar,hero_name varchar);
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Eveleen', 'Danzelman','The Quiet Antman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Harlie', 'Filipowicz','The Yellow Vulture');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Mozes', 'McWhin','The Broken Shaman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Horatio', 'Hamshere','The Quiet Charmer');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Julianna', 'Pellington','Professor Ancient Spectacle');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Grenville', 'Southouse','Fire Wonder');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Analise', 'Beards','Purple Fighter');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Darnell', 'Bims','Mister Majestic Mothman');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Micky', 'Shillan','Switcher');
INSERT INTO data_to_be_masked (first_name, last_name, hero_name) VALUES ('Ware', 'Ledstone','Optimo');

--CREATE ROLE
CREATE ROLE foo1;
CREATE ROLE foo2;
GRANT ROLE foo1 TO USER <ENTER USERNAME HERE>;
GRANT ROLE foo2 TO USER <ENTER USERNAME HERE>;