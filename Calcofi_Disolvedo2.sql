CREATE EXTENSION postgis;
select * from bottles
select * from calcofi_cast
select * from stationorder
ALTER TABLE calcofi_cast ADD COLUMN geom geometry(Point, 4326);
SELECT AddGeometryColumn ('calcofi_cast','geom',4326,'POINT',2);
alter table calcofi_cast add column geog geography;
alter table calcofi_cast add geom geometry(point, 4326);

UPDATE calcofi_cast SET geom = ST_SetSRID(ST_MakePoint(lon_dec, lat_dec), 4326);
UPDATE stationorder SET geom = ST_SetSRID(ST_MakePoint(lon_dd, lat_dd), 4326);

SELECT "bottles.Sta_ID", calcofi_cast.sta_id
FROM bottles
JOIN calcofi_cast
ON "bottles.Sta_ID" = calcofi_cast.sta_id;

SELECT "bottles.Sta_ID"
FROM bottles

UPDATE calcofi_cast
SET object_id = DEFAULT;

ALTER TABLE calcofi_cast
ALTER COLUMN object_id OID SET DEFAULT nextval('calcofi_cast_object_id_seq');
--select the station id Ive been interested in
--adding serial object ID
BEGIN;
ALTER TABLE calcofi_cast ADD COLUMN object_id SERIAL;
UPDATE calcofi_cast SET object_id = DEFAULT;
COMMIT;

BEGIN;
ALTER TABLE bottles ADD COLUMN object_id SERIAL;
UPDATE bottlest SET object_id = DEFAULT;
COMMIT;

ALTER TABLE calcofi_cast
DROP COLUMN object_id;


SELECT * FROM calcofi_cast WHERE Sta_ID IN ('066.7 050.0');
--I imported this query into QGIS and turned it into a layer. 
-- trying to narrow down bottles because below queries showing duplicates-result was 1396
SELECT * FROM bottles WHERE sta_id IN ('066.7 050.0')


select updateGeometrySRID('sql_outputcast066750', 'geom', 4326)


--then try the above query, but use the sql_outpustcast006 file and cst_cnt column. Saved csv as testjoin.csv to import
SELECT sql_outputcast066750.*, bottles.* 
FROM sql_outputcast066750 
JOIN bottles 
ON sql_outputcast066750.cst_cnt = bottles.cst_cnt;

--running to see if I can sort on depth. The result 
SELECT sql_outputcast066750.*, bottles.* 
FROM sql_outputcast066750 
JOIN bottles ON sql_outputcast066750.cst_cnt = bottles.cst_cnt
WHERE bottles.negative_r_depth < -300
ORDER BY sql_outputcast066750.year;

---I want to add a new column that turns the r_depth column into a new negative colum. To do my analysis, I think I need to find the depth ranges for years
--and look at disolved o2 over time. I need to turn02ml_l to a numeric field in arcmap
ALTER TABLE bottles
ADD negative_r_depth NUMERIC;
UPDATE bottles
SET negative_r_depth = -r_depth;

select bottles.O2ml_L
FROm bottles

--I am sending the above query to qgis


