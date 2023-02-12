CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
--checking coordinate systems
select st_srid(geom) from neighborhood_map_wgs
-- SRID to tell which spatial reference system will be used to interpret each spatial object. 
select updateGeometrySRID('bike_racks','geom', 4326)
select updateGeometrySRID('collisions','geom', 4326)
select updateGeometrySRID('collisions2','geom', 4326)
select updateGeometrySRID('existing_bike_facilities','geom', 4326)
select updateGeometrySRID('seattle_streets','geom', 4326)
select updateGeometrySRID('traffic_signalswgs','geom', 4326)
select updateGeometrySRID('multi-use_trails_(seattle_only)','geom', 4326)
select updateGeometrySRID('neighborhood_map_wgs','geom', 4326)



select * FROM collisions
select * FROM collisions2
select * FROM existing_bike_facilities
select * FROM seattle_streets
select * FROM seattle_streets_ac
select * FROM traffic_signalswgs
select * FROM multiuse_trails_seattle_only
select * FROM neighborhood_map_wgs
select * FROM public_feedback


--this is just giving me 2 column totals for collisions and total signals
SELECT COUNT(*) as total_collision, COUNT(DISTINCT traffic_signals.gid) as total_signals 
FROM collisions 
JOIN traffic_signals 
ON collisions.intkey = traffic_signals.intkey;

SELECT column_name, data_type, character_maximum_length
FROM information_schema.columns
WHERE table_name = 'seattle_streets'
AND table_catalog = 'seattle_transportation'
ORDER BY ordinal_position;

SELECT ST_IsValid(geom)
FROM seattle_streets;

SELECT ST_IsValid(geom)
FROM collisions
ORDER by st_IsValid DESC;

SELECT ST_IsValid(geom)
FROM collisions2
ORDER by st_IsValid DESC;


---collisions that occur at each traffic signal
---this gives me full geom, total collisions, & total signals. Connected to QGIS to visualize. ITrying to group by geom, & count total number 
---I think I can also change this to group my signal_mai in traffic signals -saved as totalcol_sigratio later SENt TO OUTPUT
SELECT collisions2.geom, COUNT(*) as total_collisions, COUNT(DISTINCT traffic_signalswgs.unitid) as total_signals 
FROM collisions2 
JOIN traffic_signalswgs 
ON collisions2.intkey = traffic_signalswgs.intkey
GROUP BY collisions2.geom; 
--I am checking for null values in my collisions
SELECT COUNT(*)
FROM collisions2
WHERE geom IS NULL;
--I got rid of the NULL values from collision2 and now we are running more quickly. 
DELETE FROM collisions2
WHERE geom IS NULL;

select  gid, geom
FROM collisions2
ORDER BY geom desc;

--find streets with most colliosions. SENT to OUTPUT
SELECT seattle_streets.stname_ord, seattle_streets.unitdesc, seattle_streets.geom, COUNT(collisions2.gid) AS collision_count
FROM seattle_streets
JOIN collisions2
ON ST_DWithin(seattle_streets.geom, collisions2.geom, 0.0001)
GROUP BY seattle_streets.stname_ord, seattle_streets.unitdesc, seattle_streets.geom
ORDER BY collision_count DESC

--find traffic signals with most colliosions. i dropped NULLs- NOT WORKING
SELECT traffic_signalswgs.compkey, seattle_streets.compkey, traffic_signalswgs.gid
FROM traffic_signalswgs, seattle_streets
WHERE ST_Intersects(traffic_signalswgs.geom, seattle_streets.geom, 1);

SELECT seattle_streets.compkey, traffic_signalswgs.gid
FROM traffic_signalswgs
JOIN seattle_streets
ON ST_Intersects(traffic_signalswgs.geom::geometry, seattle_streets.geom::geometry, 1);

--find out about weather and road conditions SENT to output
SELECT ROADCOND, geom, WEATHER, COUNT(*) as Frequency
FROM COLLISIONS2
GROUP BY ROADCOND, geom, WEATHER
ORDER BY Frequency DESC


---This shows colliosions with hour, weather, road cond. SEND TO oUTPUT
SELECT 
   roadcond, weather, incdttm, geom, EXTRACT(HOUR FROM incdttm::timestamp) AS hour, 
    COUNT(*) AS count
FROM 
    collisions2
GROUP BY 
    hour, roadcond, weather, incdttm, geom
ORDER BY 
    count DESC

--Analyzing the relationship between the number of collisions and the type of road surface: cannot aggregate by geometry
SELECT seattle_streets.stname_ord, seattle_streets.geom, seattle_streets.SURFACETYP, COUNT(*) 
FROM seattle_streets 
left JOIN traffic_signalswgs ON seattle_streets.compkey = traffic_signalswgs.compkey 
left JOIN collisions2 ON traffic_signalswgs.intkey = collisions2.intkey 
GROUP BY seattle_streets.SURFACETYP, seattle_streets.geom,  seattle_streets.stname_ord 
ORDER BY COUNT(*) DESC;

--redo for above- sent to table, because i cant show geom
SELECT seattle_streets.SURFACETYP, COUNT(*) as total_collisions
FROM seattle_streets 
left JOIN traffic_signalswgs ON seattle_streets.compkey = traffic_signalswgs.compkey 
left JOIN collisions2 ON traffic_signalswgs.intkey = collisions2.intkey 
GROUP BY seattle_streets.SURFACETYP
ORDER BY total_collisions DESC;


--collisions occur most frequently under this weather and road cond. THis is just showing road condition.
SELECT roadcond, COUNT(DISTINCT roadcond) 
FROM collisions2 GROUP BY roadcond;


--trying to add geom -SEND to OUTPUT
SELECT roadcond, weather, COUNT(*) as Frequency, geom
FROM COLLISIONS2
GROUP BY roadcond, weather, geom
ORDER BY Frequency DESC


SELECT ROADCOND, COUNT(*) 
FROM collisions GROUP BY ROADCOND;

SELECT weather, COUNT(*) 
FROM collisions GROUP BY weather;

--find neighborhoods with most colliosions.  SENt TO OUTPUT
SELECT neighborhood_map_wgs.s_hood, neighborhood_map_wgs.geom, count(collisions2.gid) as collision_count
FROM neighborhood_map_wgs, collisions2
WHERE ST_Intersects(neighborhood_map_wgs.geom, collisions2.geom)
GROUP BY neighborhood_map_wgs.s_hood, neighborhood_map_wgs.geom
ORDER BY collision_count DESC

--find neighborhoods that have a multiuse trail running through them---SEND TO OUTPUT
SELECT neighborhood_map_wgs.s_hood, neighborhood_map_wgs.geom
FROM neighborhood_map_wgs, multiuse_trails_seattle_only
WHERE ST_Intersects(neighborhood_map_wgs.geom, multiuse_trails_seattle_only.geom)
GROUP BY neighborhood_map_wgs.s_hood, neighborhood_map_wgs.geom;

--I also want to explore bike paths with collisions--NOT WORKING?? waiting
SELECT multiuse_trails_seattle_only.ord_stname, collisions2.geom
FROM collisions2
JOIN multiuse_trails_seattle_only
ON ST_DWithin(collisions2.geom, multiuse_trails_seattle_only.geom, 5)

--I also want to explore bike paths with collisions--NOT WORKING?? waiting
SELECT multiuse_trails_seattle_only.ord_stname, multiuse_trails_seattle_only.geom
FROM multiuse_trails_seattle_only
JOIN collisions2
ON ST_DWithin(multiuse_trails_seattle_only.geom, collisions2.geom, 5)

--trying to index above. However, the query doesnt seem to work still. 
CREATE INDEX trailsInd
ON multiuse_trails_seattle_only
USING GIST (geom);

CREATE INDEX coll2ind
ON collisions2
USING GIST (geom);


--created indexes, but they were already there. 
CREATE INDEX multiuse_trails_seattle_geom_idx ON multiuse_trails_seattle USING GIST (geom);
CREATE INDEX seattle_streets_geom_idx ON seattle_streets USING GIST (geom);


--breaking down the big streets shapefile to see if query will actually run. 
select updateGeometrySRID('seattle_streets_ac','geom', 4326)
select updateGeometrySRID('seattle_streets_acac','geom', 4326)
select updateGeometrySRID('seattle_streets_acpcc','geom', 4326)
select updateGeometrySRID('seattle_streets_gravel','geom', 4326)
select updateGeometrySRID('seattle_streets_pc','geom', 4326)
select updateGeometrySRID('seattle_streets_st','geom', 4326)
select updateGeometrySRID('public_feedback','geom', 4326)
--now I want to explore streets with the most collisions


--send this down as later task-this is to create new tables for further analysis. Create more columns to relate to existing data. WHat do I want to know? 
--USE seattle_transportation;

CREATE TABLE Public_Feedback (
Public_ID SERIAL PRIMARY KEY,
trail_conditions VARCHAR(255),
repair_dates DATE,
public_feedback VARCHAR(255),
gid INT,
a_hood INT,
FOREIGN KEY (gid) REFERENCES multiuse_trails_seattle(gid))

--now select a column from the public feedback table that matches the gid of the multiuse_trails_seattle table
SELECT trail_conditions
FROM Public_Feedback
WHERE compkey IN (
SELECT gid
FROM multiuse_trails_seattle
WHERE gid = Public_Feedback.compkey

ALTER TABLE Public_Feedback
ADD COLUMN s_hood TEXT

	select * from public_feedback
SELECT public_feedback.s_hood, neighborhood_map_wgs.gid, neighborhood_map_wgs.geom
FROM public_feedback
JOIN neighborhood_map_wgs
ON public_feedback.s_hood_gid = neighborhood_map_wgs.gid;

SELECT public_feedback, neighborhood_map_wgs, multiuse_trails_seattle.*
FROM public_feedback
JOIN neighborhood_map_wgs
ON public_feedback.s_hood_gid = neighborhood_map_wgs.gid
JOIN multiuse_trails_seattle
ON public_feedback.gid = multiuse_trails_seattle.gid;
	
--Future considerations

select * FROM seattle_streets
	
CREATE TABLE bicycle_accidents (
  accident_id serial PRIMARY KEY,
  gid INTEGER REFERENCES seattle_streets(gid),
  date TIMESTAMP NOT NULL,
  weather VARCHAR(255) NOT NULL,
  road_condition VARCHAR(255) NOT NULL,
  injury_severity VARCHAR(255) NOT NULL,
  bike_count INTEGER NOT NULL);
	
--insert data into the table
INSERT INTO bicycle_accidents (gid, date, weather, road_condition, injury_severity, bike_count)
VALUES (1, '2020-01-01 10:00:00', 'rainy', 'wet', 'fatal', 2),
       (2, '2020-01-02 12:00:00', 'sunny', 'dry', 'serious', 1),
       (3, '2020-01-03 14:00:00', 'cloudy', 'wet', 'minor', 1);

	


