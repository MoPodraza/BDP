CREATE DATABASE lab;


CREATE EXTENSION postgis;


CREATE TABLE buildings (
	id int PRIMARY KEY, 
	geom geometry, 
	name varchar(30)
);


INSERT into buildings VALUES 
	(1, 'POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))', 'BuildingA'),
	(2, 'POLYGON((6 5, 4 5, 4 7, 6 7, 6 5))', 'BuildingB'),
	(3, 'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))', 'BuildingC'),
	(4, 'POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))', 'BuildingD'),
	(5, 'POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))', 'BuildingF');


CREATE TABLE roads (
	id int PRIMARY KEY, 
	geom geometry, 
	name varchar(30)
);


INSERT into roads VALUES 
	(1, 'LINESTRING(0 4.5, 12 4.5)', 'RoadX'),
	(2, 'LINESTRING(7.5 10.5, 7.5 0)', 'RoadY');
	
	
CREATE TABLE poi (
	id int PRIMARY KEY, 
	geom geometry, 
	name varchar(30)
);


INSERT into poi VALUES 
	(1, 'POINT(1 3.5)', 'G'),
	(2, 'POINT(5.5 1.5)', 'H'),
	(3, 'POINT(9.5 6)', 'I'),
	(4, 'POINT(6.5 6)', 'J'),
	(5, 'POINT(6 9.5)', 'K');
	
	
/*a*/
SELECT sum(ST_Length(geom)) FROM roads;


/*b*/
SELECT ST_AsText(geom), 
	   ST_Area(geom),
	   ST_Perimeter(geom)
FROM buildings 
WHERE name = 'BuildingA';


/*c*/
SELECT name, ST_Area(geom) 
FROM buildings
ORDER BY name;


/*d*/
SELECT name, ST_Perimeter(geom) perimeter 
FROM buildings
ORDER BY ST_Area(geom) DESC
LIMIT 2;


/*e*/
SELECT ST_Distance(b.geom, p.geom)
FROM buildings b, poi p
WHERE b.name = 'BuildingC' 
AND p.name = 'K';


/*f*/
SELECT ST_Area(
	ST_Intersection(
		(SELECT geom FROM buildings WHERE name = 'BuildingC'), 
		ST_Buffer((SELECT geom FROM buildings WHERE name='BuildingB'), 0.5)
	)	
);


/*g*/
SELECT b.name
FROM buildings b, roads r
WHERE ST_Y(ST_Centroid(b.geom)) > ST_Y(ST_Centroid(r.geom))
AND r.name = 'RoadX';


/*8*/
SELECT ST_Area(
    ST_SymDifference(
        (SELECT geom FROM buildings WHERE name = 'BuildingC' ),
        'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'
    )
);