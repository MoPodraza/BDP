--zad 3
create index idx_intersects_rast_gist ON rasters..uk_250k using gist (ST_ConvexHull(rast));
select AddRasterConstraints('rasters'::name, 'uk_250k'::name,'rast'::name);

CREATE TABLE tmp_out1 AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM rasters.uk_250k;

SELECT lo_export(loid, 'C:\bdp\lab7\result.tiff')
FROM tmp_out1;

SELECT lo_unlink(loid)
  FROM tmp_out1;
  
--zad 6 & 7
SELECT UpdateGeometrySRID('national_parks','geom',4277);

CREATE TABLE uk_lake_district AS
SELECT a.rid, ST_Clip(a.rast, b.geom, true) as rast
FROM rasters.uk_250k AS a, national_parks AS b
where b.gid = 1 and ST_Intersects(b.geom, a.rast);

select * from uk_lake_district;
 
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM uk_lake_district;

SELECT lo_export(loid, 'C:\bdp\lab7\result\zad7.tiff') 
FROM tmp_out;

SELECT lo_unlink(loid)
FROM tmp_out; 


--zad 10
create index  idx_rast_sentinel_gist on rasters.sentinel 
using gist(ST_ConvexHull(rast));

select AddRasterConstraints('rasters'::name, 'sentinel'::name, 'rast'::name);


create or replace function ndvi(
    value double precision [] [] [],
    pos integer [][],
    VARIADIC userargs text []
)
returns double precision as
$$
begin
    return (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value [1][1][1]);
end;
$$
language 'plpgsql' immutable cost 1000;

create table ndvi as
with r as (
    select * from rasters.sentinel
)

select r.rid,ST_MapAlgebra(
    r.rast, ARRAY[1,4],
    'ndvi(double precision[], integer[],text[])'::regprocedure,
    '32BF'::text
) as rast
from r;


create table intersect_sentinel as 
select a.rid, ST_CLIP(a.rast, b.geom, true) as rast
from ndvi as a, national_parks as b
where b.gid=1 and st_intersects(b.geom, a.rast)

select * from intersect_sentinel;

--zad 11
CREATE TABLE tmp_out4 AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM ndvi;

SELECT lo_export(loid, 'C:\bdp\lab7\result\zad11.tiff') 
FROM tmp_out4;

SELECT lo_unlink(loid)
FROM tmp_out4; 
