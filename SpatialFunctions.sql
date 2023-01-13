select * from pgroads
SELECT length, fename 
FROM pgroads 
WHERE fename = 'Fenno';
select * 
FROM pgcensustract

SELECT sum(ST_NPoints(geom) 
FROM pgcensustract;
		   
SELECT geodesc, ST_Area(geom) as area, ST_Perimeter(geom) as perimeter
FROM pgcensustract 
WHERE geodesc = '8004.02';


		   
SELECT ST_AsText(geom) 
		   
FROM pgcensustract;	
		   
SELECT ST_AsText(geom) 
As polygon_vertices 
FROM pgcensustract;
