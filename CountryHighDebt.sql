/*country with the highest debt*/

SELECT country_name, SUM(debt) AS debt_total
FROM world_bank
GROUP BY country_name
ORDER BY debt_total DESC



