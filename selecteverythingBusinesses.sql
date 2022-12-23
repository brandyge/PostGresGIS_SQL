SELECT businesses.business, businesses.year_founded, businesses.country_code, businesses.category_code, countries.continent, countries.country, categories.category
FROM businesses 
INNER JOIN countries
ON businesses.country_code = countries.country_code
INNER JOIN categories 
ON businesses.category_code = categories.category_code
ORDER BY businesses.year_founded;

