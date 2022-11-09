create EXTENSION postgis;

--Zad1
--shp2pgsql -D -I C:\bdp\Cw3_Karlsruhe_Germany_Shapefile\T2018_KAR_GERMANY\T2018_KAR_BUILDINGS.shp t2018_kar_buildings | psql -U postgres -h localhost -p 5432 -d lab3_bdp
--shp2pgsql -D -I C:\bdp\Cw3_Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_BUILDINGS.shp t2019_kar_buildings | psql -U postgres -h localhost -p 5432 -d lab3_bdp

with new_buildings as (
	select b19.polygon_id, b19.geom from t2019_kar_buildings b19
	left join t2018_kar_buildings b18 
	on b19.geom = b18.geom
	where b18.polygon_id is NULL
),

--Zad2

new_poi as (
	select p19.poi_id, p19.geom, p19.type from t2019_kar_poi_table p19
	left join t2018_kar_poi_table p18 
	on p19.geom = p18.geom
	where p18.poi_id is NULL
)

select count(poi_id), new_poi.type 
from new_poi
join new_buildings
on st_distance(new_poi.geom, new_buildings.geom) <= 500
group by new_poi.type;

--Zad3
create table streets_reprojected (
	gid serial4 NOT NULL,
	link_id float8 NULL,
	st_name varchar(254) NULL,
	ref_in_id float8 NULL,
	nref_in_id float8 NULL,
	func_class varchar(1) NULL,
	speed_cat varchar(1) NULL,
	fr_speed_l float8 NULL,
	to_speed_l float8 NULL,
	dir_travel varchar(1) NULL,
	geom geometry NULL
);

insert into streets_reprojected 
select gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, to_speed_l,
		dir_travel, ST_Transform(ST_SetSRID(geom,4326), 3068)
from t2019_kar_streets;

select * from streets_reprojected;

--Zad4
create table input_points (
	id integer PRIMARY KEY, 
	geometry geometry
);
	
insert into input_points values (1,'POINT(8.36093 49.03174)'), (2,'POINT(8.39876 49.00644)')

select * from input_points;

--Zad5
update input_points
set geometry = ST_Transform(ST_SetSRID(geometry,4326), 3068);
select * from input_points;

--Zad6
update t2019_kar_street_node
set geom = ST_Transform(ST_SetSRID(geom,4326), 3068);

with line1 as (
    select st_makeline(geometry) as line from input_points
)

select * from t2019_kar_street_node
join line1
on ST_Contains(ST_Buffer(line1.line, 0.002), t2019_kar_street_node.geom);

--Zad7
with sport_stores as (
    select poi_id, geom from t2019_kar_poi_table where type = 'Sporting Goods Store'
)

select count(distinct sport_stores.poi_id) from sport_stores
join t2019_kar_land_use_a as parks
on st_dwithin(sport_stores.geom, parks.geom, 300);


--Zad8
select ST_Intersection(railways.geom, waterlines.geom) as geometry
into T2019_KAR_BRIDGES
from t2019_kar_railways railways
join t2019_kar_water_lines waterlines
on ST_Intersects(railways.geom, waterlines.geom);

select * from T2019_KAR_BRIDGES

