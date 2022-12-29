/*highest principal pay*/
select country_name, indicator_code, debt, indicator_name FROM 
world_bank
WHERE indicator_code = 'DT.AMT.DLXF.CD'
ORDER BY debt DESC