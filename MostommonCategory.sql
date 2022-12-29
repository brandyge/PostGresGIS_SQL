/* I am selecting everything and then sorting by most most common categories for the oldest businesses on each continent
Counting categories by continent (EXTRA CREDIT 1 point)
Which are the most common categories for the oldest businesses on each continent
 */ 

SELECT cnt.continent, cat.category, COUNT(cat.category) AS categorynumber
FROM businesses AS bus
INNER JOIN categories AS cat
ON bus.category_code = cat.category_code
INNER JOIN countries AS cnt
ON bus.country_code = cnt.country_code
GROUP BY cnt.continent, cat.category



