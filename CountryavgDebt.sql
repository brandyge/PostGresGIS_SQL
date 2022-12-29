/*find the average debt*/

SELECT indicator_code, indicator_name, AVG(debt) AS debt_avg
FROM world_bank
GROUP BY indicator_code, indicator_name
ORDER BY debt_avg DESC



