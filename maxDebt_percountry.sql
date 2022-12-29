/* Find maximum debt per country */

SELECT country_name, MAX(debt) AS max_debt
From world_bank
GROUP BY country_name
ORDER BY max_debt DESC