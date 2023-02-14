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
---Find out which of these tables have related columns
WITH
  all_columns AS (
    SELECT table_name, column_name
    FROM information_schema.columns
    WHERE table_name IN ('bottles', 'calcofi_cast', 'stationorder')
  ),
  all_columns_counts AS (
    SELECT column_name, count(column_name)
    FROM all_columns
    GROUP BY column_name
  ),
  common_columns AS (
    SELECT column_name
    FROM all_columns_counts
    WHERE count >= 2
  )
SELECT
  table_name,
  column_name
FROM
  all_columns
WHERE
  column_name IN (SELECT column_name FROM common_columns)
ORDER BY
  column_name, table_name
------close out from above query.
--checking all of line 667050 from bottles and cast table. GOOD QUERY
SELECT calcofi_cast.sta_id, bottles.sta_id, calcofi_cast.date, calcofi_cast.year, calcofi_cast.ship_name, calcofi_cast.lat_dec, calcofi_cast.lon_dec, bottles.negative_r_depth, bottles."O2ml_L"
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.sta_id = '066.7 050.0'
AND bottles.sta_id = '066.7 050.0'
ORDER BY bottles.negative_r_depth ASC;

select * from calcofi_cast
--trying to add years 1998-2021 to coincide more with paper.  GOOD QUERY I Need to find a way to ask some question to create a query to display these in a meaninful way.
SELECT calcofi_cast.sta_id, bottles.sta_id, calcofi_cast.date, calcofi_cast.year, calcofi_cast.distance, calcofi_cast.ship_name, calcofi_cast.lat_dec, calcofi_cast.lon_dec, bottles.negative_r_depth, bottles."O2ml_L"
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.sta_id = '066.7 050.0'
AND bottles.sta_id = '066.7 050.0'
AND calcofi_cast.year BETWEEN 1998 AND 2020
ORDER BY bottles.negative_r_depth ASC;

---O2ml_L and average distance from shore for each unique value of the negative_r_depth, the lat and long of station, order the results by negative_r_depth asc order. Visualize with the lat and long representing the station and avg_O2ml_L & avg_distance_from_shore.
--SENT to OUTPUT as a csv and imported into qgis to arcPro-Note this contains an average distance from shore calc.
SELECT calcofi_cast.sta_id, calcofi_cast.Dry_T, calcofi_cast.geom, bottles.negative_r_depth, AVG(calcofi_cast.distance) as avg_distance_from_shore, AVG(bottles."O2ml_L") as avg_O2ml_L, calcofi_cast.lat_dec, calcofi_cast.lon_dec
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.sta_id = '066.7 050.0'
AND bottles.sta_id = '066.7 050.0'
AND calcofi_cast.year BETWEEN 1998 AND 2020
GROUP BY calcofi_cast.sta_id, calcofi_cast.Dry_T, bottles.negative_r_depth, calcofi_cast.lat_dec, calcofi_cast.lon_dec, calcofi_cast.geom
ORDER BY bottles.negative_r_depth ASC;
--Group the data based on the depth_intervals and distance_intervals
SELECT depth_intervals, distance_intervals, AVG("O2ml_L"), lat_dec, lon_dec, geom
FROM (
  SELECT ROUND(negative_r_depth) AS depth_intervals, ROUND(distance) AS distance_intervals, "O2ml_L", lat_dec, lon_dec, geom
  FROM calcofi_cast
  JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
  WHERE calcofi_cast.sta_id = '066.7 050.0'
    AND bottles.sta_id = '066.7 050.0'
    AND calcofi_cast.year BETWEEN 1998 AND 2020
) AS subquery
GROUP BY depth_intervals, distance_intervals, lat_dec, lon_dec, geom
ORDER BY depth_intervals ASC, distance_intervals ASC;


--calculate distint column-IM getting a lot of NULL, not sure but don't use for now
SELECT DISTINCT ROUND(distance) as distint
FROM calcofi_cast;
select distint from calcofi_cast


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
select * FROM bottles

