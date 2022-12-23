SELECT bus.business, bus.year_founded, bus.country_code, bus.category_code, countries.continent,  countries.country, categories.category
FROM businesses AS bus
INNER JOIN countries
ON bus.country_code = countries.country_code
INNER JOIN categories 
ON bus.category_code = categories.category_code
ORDER BY year_founded; 

