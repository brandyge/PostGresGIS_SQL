CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
--checking coordinate systems
select st_srid(geom) from bike_racks
---The SRID is used to tell which spatial reference system will be used to interpret each spatial object. A common SRID in use is 4326
select updateGeometrySRID('bike_racks','geom', 4326)
select updateGeometrySRID('collisions','geom', 4326)
select updateGeometrySRID('existing_bike_facilities','geom', 4326)
select updateGeometrySRID('seattle_streets','geom', 4326)
select updateGeometrySRID('traffic_signals','geom', 4326)
select updateGeometrySRID('multi-use_trails_(seattle_only)','geom', 4326)

---collisions that occur at each traffic signal
select * FROM collisions 
select * FROM seattle_streets
select * FROM traffic_signals
select * FROM multiuse_trails_seattle_only
--this is just giving me 2 column totals for collisions and total signals
SELECT COUNT(*) as total_collision, COUNT(DISTINCT traffic_signals.gid) as total_signals 
FROM collisions 
JOIN traffic_signals 
ON collisions.intkey = traffic_signals.intkey;
---this gives me the full geom, total collisions, and total signals.  Trying to connect to arcpro. to visualize. I am trying to group by geom, and count the total number of 
---I think I can also change this to group my signal_mai in traffic signals -saved as totalcol_sigratio later
SELECT collisions.geom, COUNT(*) as total_collisions, COUNT(DISTINCT traffic_signals.unitid) as total_signals 
FROM collisions 
JOIN traffic_signals 
ON collisions.intkey = traffic_signals.intkey
GROUP BY collisions.geom; 

---analysis of number of collisions and the road surface type. DOT_IT_GIS@seattle.gov None of queries working. Might be size, separating my streetclass


SELECT COUNT(collisions.gid) as num_collisions, seattle_streets.surfacetyp
FROM collisions
JOIN seattle_streets ON ST_DWithin(collisions.geom, seattle_streets.geom, 500) = true
GROUP BY seattle_streets.surfacetyp;

SELECT COUNT(collisions.gid) as num_collisions, seattle_streets.surfacetyp
FROM collisions
JOIN seattle_streets ON ST_Distance(collisions.geom, seattle_streets.geom) < 10000
GROUP BY seattle_streets.surfacetyp
--check if indexes are being used. 
EXPLAIN SELECT COUNT(collisions.gid) as num_collisions, seattle_streets.surfacetyp
FROM collisions
JOIN seattle_streets ON ST_DWithin(collisions.geom, seattle_streets.geom, 5000) = true
GROUP BY seattle_streets.surfacetyp


CREATE INDEX collisions_geom_idx ON collisions USING GIST (geom);
CREATE INDEX seattle_streets_geom_idx ON seattle_streets USING GIST (geom);

SELECT collisions.*
FROM collisions
JOIN seattle_streets_ac ON ST_DWithin(collisions.geom, seattle_streets_ac.geom, 50)

--breaking down the big streets shapefile to see if query will actually run. 
select updateGeometrySRID('seattle_streets_ac','geom', 4326)
select updateGeometrySRID('seattle_streets_acac','geom', 4326)
select updateGeometrySRID('seattle_streets_acpcc','geom', 4326)
select updateGeometrySRID('seattle_streets_gravel','geom', 4326)
select updateGeometrySRID('seattle_streets_pc','geom', 4326)
select updateGeometrySRID('seattle_streets_st','geom', 4326)
------Ill have to come back to the above queries.  they dont seem to work 
--now I want to explore streets with the most collisions
--I also want to explore bike paths with collisions

