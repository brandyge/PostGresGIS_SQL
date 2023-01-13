SELECT ST_GeomFromText('LINESTRING(1 2, 3 4, 5 6)');
SELECT ST_GeomFromText('POLYGON((1 1, 1 2, 2 2, 2 1, 1 1))');
SELECT school_nam, ST_X(geom) 
AS x, ST_Y(geom) 
AS y FROM publicschools;

SELECT fename,fetype,  ST_GeometryType(geom) 
AS type, ST_NumGeometries(geom) 
AS num_parts FROM pgroads;

SELECT geodesc,  ST_GeometryType(geom) 
AS type, ST_NumGeometries(geom) 
AS num_parts FROM pgcensustract;