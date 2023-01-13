SELECT name
FROM geometries
WHERE ST_Equals(geom, ST_GeometryFromText('Point(0 0)', 4326))

SELECT * from pgcensustract where ST_Intersects(geom, ST_GeomFromText('POLYGON((406286 124178, 406286 125000, 416286 125000,
416286 124178, 406286 124178))', 26985))

SELECT * FROM publicschools
ORDER BY School_nam ASC

--used the below query to show the text of where this one school 

SELECT school_nam, ST_AsText(geom, 0) 
FROM Publicschools
WHERE ST_Contains(ST_ASText(geom, 0), 'POINT(418175 122896)');

--used the below query to show the text of where this one school and all scools in 1k


SELECT school_nam
FROM publicschools
WHERE ST_DWithin(geom, (SELECT geom
					   FROM publicschools
					   WHERE school_nam = 'Marlton'),1600)

--used the below query to show the text of census tract 
SELECT geodesc, ST_AsText(geom, 0) 
FROM pgcensustract
WHERE ST_Contains(ST_ASText(geom, 0), 'POINT(417108 129547)');

-- write query to find all road segments within 5000m to the point
--id the point first, and nothing pops up QUESTION 4
SELECT fename, ST_AsText(geom, 0) 
FROM pgroads
WHERE ST_Contains(ST_ASText(geom, 0), 'POINT(406286 124178)');

SELECT pgroads.*
FROM pgroads, new_shapefile
WHERE ST_DWithin(pgroads.geom, new_shapefile.geom, 5000);

SELECT * FROM pgroads
WHERE ST_DWithin(geom, ST_MakePoint(406286, 124178)::geography, 5000);

SELECT * FROM pgroads 
WHERE ST_DWithin(pgroads.geom, ST_SetSRID(ST_MakePoint(406286, 124178), 4326), 5000);

SELECT ST_SRID(geom) FROM pgroads

--Write a query to find the roads within 1000 meters to the school Baden which is in the city of Brandywine. Return the road name and type.

SELECT fename, fetype
FROM pgroads
WHERE ST_DWithin(geom, (SELECT geom
					   FROM publicschools
					   WHERE school_nam = 'Baden'),1000) 

--Homework Question 6 Write a query to find the total number of schools in each census tract, 
--return the tract ID (geodesc) and the corresponding total number of schools.

SELECT pgcensustract.geodesc, COUNT(publicschools.geodesc) as total_schools
FROM pgcensustract
JOIN publicschools ON pgcensustract.geodesc = publicschools.geodesc
GROUP BY pgcensustract.geodesc, pgcensustract.geodesc
ORDER BY total_schools DESC;

--use 3 tables to implement a question .tray query below-NOT working-Result is blank
----
SELECT pgcensustract.geodesc, publicschools.school_nam, COUNT(pgroads.gid) as road_seg_count
FROM publicschools 
JOIN pgcensustract  ON ST_Within(publicschools.geom, pgcensustract.geom)
JOIN pgroads ON ST_Within(publicschools.geom, pgroads.geom)
GROUP BY pgcensustract.geodesc, publicschools.school_nam
ORDER BY road_seg_count DESC;
---working query for Q7. schools in censustracts and nearby roads within 500 meters.
SELECT pgcensustract.geodesc as census_tract_name, 
COUNT(DISTINCT publicschools.geom) as num_schools, COUNT(DISTINCT pgroads.geom) as num_road_segments
FROM pgcensustract
JOIN publicschools ON ST_Within(publicschools.geom, pgcensustract.geom)
JOIN pgroads ON ST_DWithin(pgroads.geom, publicschools.geom, 500)
GROUP BY census_tract_name
ORDER BY num_schools DESC, num_road_segments DESC






select updateGeometrySRID('new_shapefile','geom', 26985)
