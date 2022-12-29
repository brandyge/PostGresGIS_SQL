/*most common debt indicator*/

SELECT indicator_code,
COUNT(indicator_code) AS indicator_count
FROM world_bank
GROUP BY indicator_code
ORDER BY indicator_count DESC
