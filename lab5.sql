create EXTENSION postgis;

--zad1
create table objects(
	id int primary key, 
	name varchar(10),
	geom geometry
)
--a
insert into objects values(1, 'objekt1', ST_Collect(Array['LINESTRING(0 1, 1 1)',
														  'CIRCULARSTRING(1 1, 2 0, 3 1)',
														  'CIRCULARSTRING(3 1, 4 2, 5 1)',
														  'LINESTRING(5 1, 6 1)']));
--b
insert into objects values(2, 'objekt2', ST_Collect(Array['LINESTRING(10 6, 10 2)',
														  'CIRCULARSTRING(10 2, 12 0, 14 2)',
														  'CIRCULARSTRING(14 2, 16 4, 14 6)',
														  'LINESTRING(14 6, 10 6)', 
														  'CIRCULARSTRING(11 2, 12 3, 13 2)',
														  'CIRCULARSTRING(13 2, 12 1, 11 2)']));
														  
--c
insert into objects values (3, 'object3', 'POLYGON((10 17, 12 13, 7 15, 10 17))');

--d
insert into objects values (4, 'object4', ST_Collect(Array['LINESTRING(20 20, 25 25)',
														   'LINESTRING(25 25, 27 24)',
														   'LINESTRING(27 24, 25 22)',
														   'LINESTRING(25 22, 26 21)',
														   'LINESTRING(26 21, 22 19)',
														   'LINESTRING(22 19, 20.5 19.5)']));
														  
--e
insert into objects values (5, 'object5',  ST_Collect('POINT(30 30 59)', 'POINT(38 32 234)'));

--f
insert into objects values (6, 'object6',  ST_Collect('LINESTRING(1 1, 3 2)', 'POINT(4 2)'));

--zad2
select st_area(st_buffer(st_shortestline(obj3.geom, obj4.geom), 5))
from
(select geom from objects where id = 3) as obj3,
(select geom from objects where id = 4) as obj4;

--zad3
--pierwszy i ostatni punkt - takie same 
update objects
set geom =  st_geomfromtext('POLYGON((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20))')
where id = 4;

--zad4
insert into objects values (7, 'obiekt7', 
							( select st_collect(obj3.geom, obj4.geom)
							from 
							(select geom from objects where id = 3) as obj3,
							(select geom from objects where id = 4) as obj4));
							
							
--zad5
select  id, name, st_area(st_buffer(geom, 5))
from objects
where ST_HasArc(geom) = false;


														  

