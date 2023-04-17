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

SELECT bottles.Sta_id, calcofi_cast.sta_id
FROM bottles
JOIN calcofi_cast
ON bottles.sta_id = calcofi_cast.sta_id;
--There are 31 cast cnt
Select sta_id, negative_r_depth, cst_cnt, "Depth_ID", "O2ml_L"
FROM bottles
WHERE
bottles.sta_id LIKE '066.7%'
AND cst_cnt = 31318
ORDER BY "O2ml_L" ASC;
---There is one cast_id
Select sta_id, cst_cnt, cast_id, bottom_d
FROM calcofi_cast
WHERE
calcofi_cast.sta_id LIKE '066.7%'
AND cst_cnt = 31318

SELECT b.sta_id, b.negative_r_depth, b.cst_cnt, b."Depth_ID", b."O2ml_L", c.cast_id, c.bottom_d, c.year, c.distance, c.geom
FROM bottles b
INNER JOIN calcofi_cast c ON b.sta_id = c.sta_id AND b.cst_cnt = c.cst_cnt
WHERE b.sta_id LIKE '066.7%'
AND c.year BETWEEN 1998 AND 2020
ORDER BY b."O2ml_L" ASC;

--- average decline in O2ml over time, distance, and depth for each year, 
SELECT c.year, c.distance, c.geom, b.negative_r_depth, AVG(b."O2ml_L") AS avg_o2ml
FROM bottles b
INNER JOIN calcofi_cast c ON b.sta_id = c.sta_id AND b.cst_cnt = c.cst_cnt
WHERE b.sta_id LIKE '066.7%'
AND c.year BETWEEN 1998 AND 2020
GROUP BY c.year, c.distance, c.geom, b.negative_r_depth
ORDER BY c.year, c.distance, b.negative_r_depth;

SELECT c.year, c.geom, c.sta_id, b.negative_r_depth, MIN(b."O2ml_L") AS min_o2ml
FROM bottles b
INNER JOIN calcofi_cast c ON b.sta_id = c.sta_id AND b.cst_cnt = c.cst_cnt
WHERE b.sta_id LIKE '066.7%'
AND c.year BETWEEN 1998 AND 2020
GROUP BY c.year, b.negative_r_depth, c.geom, c.sta_id
ORDER BY c.year, b.negative_r_depth;

SELECT "Depth_ID", cst_cnt, "O2ml_L"
FROM bottles
WHERE "Depth_ID" LIKE '19-98%' OR
      "Depth_ID" LIKE '19-99%' OR
      "Depth_ID" LIKE '20-__%' AND
      sta_id LIKE '066.7%'
	  AND
	  "O2ml_L" IS NOT null;




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
INNER JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.sta_id = '066.7 050.0'
AND bottles.sta_id = '066.7 050.0'
ORDER BY bottles.negative_r_depth ASC;
---want to isolate line 667--I want to do a depth for each GOOD query
SELECT calcofi_cast.sta_id, bottles.sta_id, calcofi_cast.cst_cnt, bottles.cst_cnt, calcofi_cast.month, calcofi_cast.year, calcofi_cast.distance, calcofi_cast.ship_name, calcofi_cast.geom, calcofi_cast.lat_dec, calcofi_cast.lon_dec, bottles.negative_r_depth, bottles."O2ml_L"
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.sta_id LIKE '066.7%'
AND bottles.sta_id LIKE '066.7%'
ORDER BY bottles.negative_r_depth ASC;

SELECT * FROM calcofi_cast WHERE Sta_ID LIKE '066.7%';
SELECT * FROM bottles WHERE Sta_ID LIKE '066.7%'
ORDER BY negative_r_depth ASC;

select * from calcofi_cast
--trying to add years 1998-2021 to coincide more with paper.  GOOD QUERY I Need to find a way to ask some question to create a query to display these in a meaninful way.
SELECT calcofi_cast.sta_id, bottles.sta_id, calcofi_cast.date, calcofi_cast.cst_cnt, bottles.cst_cnt, calcofi_cast.year, calcofi_cast.distance, calcofi_cast.ship_name, calcofi_cast.lat_dec, calcofi_cast.lon_dec, bottles.negative_r_depth, bottles."O2ml_L"
FROM calcofi_cast
FULL OUTER JOIN bottles ON calcofi_cast.cst_cnt = bottles.cst_cnt
WHERE calcofi_cast.sta_id LIKE '066.7%'
AND bottles.sta_id LIKE '066.7%'
AND calcofi_cast.year BETWEEN 1998 AND 2020
ORDER BY bottles.negative_r_depth ASC;

---O2ml_L and average distance from shore for each unique value of the negative_r_depth, the lat and long of station, order the results by negative_r_depth asc order. Visualize with the lat and long representing the station and avg_O2ml_L & avg_distance_from_shore.
--SENT to OUTPUT as a csv and imported into qgis to arcPro-Note this contains an average distance from shore calc.
SELECT calcofi_cast.sta_id, calcofi_cast.geom, bottles.negative_r_depth, AVG(calcofi_cast.distance) as avg_distance_from_shore, bottles."O2ml_L", calcofi_cast.year, calcofi_cast.distance, calcofi_cast.cst_cnt, calcofi_cast.ship_name, calcofi_cast.lat_dec, calcofi_cast.lon_dec
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.sta_id LIKE '066.7%'
AND bottles.sta_id LIKE '066.7%'
AND calcofi_cast.year BETWEEN 1998 AND 2020
GROUP BY calcofi_cast.sta_id, bottles.negative_r_depth, calcofi_cast.year, calcofi_cast.distance, calcofi_cast.cst_cnt, bottles."O2ml_L", calcofi_cast.ship_name, calcofi_cast.lat_dec, calcofi_cast.lon_dec, calcofi_cast.geom
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


--what is the average o2 concentration at different depths and distances. Maybe graph this? -ArcPro already graphs but this should confirm.
SELECT depth_intervals, distance_intervals, AVG("O2ml_L") as avg_oxygen_concentration
FROM (
SELECT ROUND(negative_r_depth) AS depth_intervals, ROUND(distance) AS distance_intervals, "O2ml_L"
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.sta_id = '066.7 050.0'
AND bottles.sta_id = '066.7 050.0'
AND calcofi_cast.year BETWEEN 1998 AND 2020
) AS subquery
GROUP BY depth_intervals, distance_intervals
ORDER BY depth_intervals ASC, distance_intervals ASC;
--same as above but geom included
SELECT depth_intervals, distance_intervals, AVG("O2ml_L") as avg_oxygen_concentration, lat_dec, lon_dec, geom
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

--adding month into this question
SELECT depth_intervals, distance_intervals, AVG("O2ml_L") as avg_oxygen_concentration, month
FROM (
SELECT ROUND(negative_r_depth) AS depth_intervals, ROUND(distance) AS distance_intervals, "O2ml_L", month
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.sta_id = '066.7 050.0'
AND bottles.sta_id = '066.7 050.0'
AND calcofi_cast.year BETWEEN 1998 AND 2020
) AS subquery
GROUP BY depth_intervals, distance_intervals, month
ORDER BY depth_intervals ASC, distance_intervals ASC;


---I want to add a new column that turns the r_depth column into a new negative colum. To do my analysis, I think I need to find the depth ranges for years
--and look at disolved o2 over time. I need to turn02ml_l to a numeric field in arcmap
ALTER TABLE bottles
ADD negative_r_depth NUMERIC;
UPDATE bottles
SET negative_r_depth = -r_depth;

select bottles.O2ml_L
FROm bottles


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

--All of line 667
SELECT * FROM calcofi_cast WHERE Sta_ID LIKE '066.7%';


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

--I am sending the above query to qgis
select * FROM bottles

--depths 98-2020 avg o2 for depth intervals--I want to run this query on line 67 only
SELECT ROUND(bottles.negative_r_depth) AS depth, AVG(bottles."O2ml_L") AS avg_o2ml_l, calcofi_cast.lat_dec, calcofi_cast.lon_dec, bottles."O2ml_L", calcofi_cast.geom, calcofi_cast.year
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE ROUND(bottles.negative_r_depth) IN (-500)
AND calcofi_cast.year BETWEEN 1998 AND 2020
GROUP BY ROUND(bottles.negative_r_depth), calcofi_cast.lat_dec, bottles."O2ml_L", calcofi_cast.lon_dec, calcofi_cast.geom, calcofi_cast.year;


--minumum averger o2 concentations at each depth. 2/20/23 
SELECT negative_r_depth AS depth, MIN("O2ml_L") AS min_oxygen_concentration, calcofi_cast.year, calcofi_cast.sta_id, lat_dec, lon_dec
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.year BETWEEN 1998 AND 2020
AND calcofi_cast.sta_id LIKE '066.7%'
AND negative_r_depth IN (-50, -100, -200, -300, -400, -500, -1000)
GROUP BY negative_r_depth, calcofi_cast.year, calcofi_cast.sta_id, lat_dec, lon_dec;

--avg at each depth
SELECT negative_r_depth AS depth, calcofi_cast.year, AVG("O2ml_L") AS avg_oxygen_concentration
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.year BETWEEN 1998 AND 2020
AND calcofi_cast.sta_id LIKE '066.7%'
AND negative_r_depth IN (-50, -100, -200, -300, -400, -500, -1000)
GROUP BY negative_r_depth, calcofi_cast.year;

--min at each depth
SELECT negative_r_depth AS depth, calcofi_cast.year, MIN("O2ml_L") AS min_oxygen_concentration
FROM calcofi_cast
JOIN bottles ON calcofi_cast.sta_id = bottles.sta_id
WHERE calcofi_cast.year BETWEEN 1998 AND 2020
AND calcofi_cast.sta_id LIKE '066.7%'
AND negative_r_depth IN (-50, -100, -200, -300, -350, -400, -500, -1000)
GROUP BY negative_r_depth, calcofi_cast.year;





---I addedd a query to check all of these just on line 667.  for some reason,  I think the other data is just too much. 

--bring in final data98-2020
CREATE TABLE calcofi98_2020 (
    OID_ integer,
    sta_id_X integer,
    month integer,
    year integer,
    distance numeric,
    ship_name text,
    geom geometry(Point,4326),
    lat_dec numeric,
    lon_dec numeric,
    negative_r integer,
    O2ml_L numeric
 );


COPY calcofi98_2020(OID_, sta_id_X, month, year, distance, ship_name, geom, lat_dec, lon_dec, negative_r, O2ml_L) 
FROM 'E:/NOAA/CalCofi_SQL/Calcofi66798_2021.csv' DELIMITER ',' CSV HEADER;

select * FROM calcofi98_2020

SELECT year, ROUND(negative_r / 50) * 50 AS depth, MIN(O2ml_L) AS lowest_O2ml_L, lat_dec, lon_dec
FROM calcofi98_2020
GROUP BY year, depth, lat_dec, lon_dec
ORDER BY depth ASC, lowest_O2ml_L ASC;

SELECT year, ROUND(negative_r / 100) * 100 AS depth, MIN(O2ml_L) AS lowest_O2ml_L, lat_dec, lon_dec
FROM calcofi98_2020
GROUP BY year, depth, lat_dec, lon_dec
ORDER BY depth ASC, lowest_O2ml_L ASC;

SELECT year, AVG(O2ml_L) AS avg_O2ml_L
FROM calcofi98_2020
GROUP BY year
ORDER BY year ASC





