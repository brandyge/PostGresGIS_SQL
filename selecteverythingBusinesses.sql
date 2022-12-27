/* I am selecting everything and then sorting by most most common categories for the oldest businesses on each continent */ 

SELECT bus.business, bus.year_founded, bus.country_code, bus.category_code, countries.continent,  countries.country,  cat.category
FROM businesses AS bus
INNER JOIN countries
ON bus.country_code = countries.country_code
INNER JOIN categories AS cat
ON bus.category_code = cat.category_code

ORDER BY cat.category


