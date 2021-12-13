
#vytvoøení tøetí tabulky t_03_demo_economics
#country, rok, hustota zalidneni, GDP, GINI, dìtská umrtnost,life_expectancy_diff
	
SELECT
	d.country ,
	d.`year` ,
	d.population ,
	round(d.population / c.surface_area,2) AS hustota_zalidneni,
	e.GDP , 			#údaje z roku 2020
	e.gini ,			#hodnì údajù chybí
	d.mortaliy_under5 , #údaje z roku 2019
	FROM demographics d 
	JOIN countries c 
	ON d.country = c.country 
	JOIN economies e 
	ON d.country = e.country 
	AND d.`year` = e.`year` 
	WHERE d.population IS NOT NULL AND c.region_in_world IS NOT NULL	




#finální tabulka 
	CREATE OR REPLACE TABLE t_03_demo_economics as
SELECT
	d.country ,
	d.`year`,
	round(d.population / c.surface_area,2) AS population_density,
	e.GDP ,
	e.gini ,
	d.mortaliy_under5, 
	led.life_expectancy_diff,
	c.iso3 
FROM demographics d 
JOIN countries c 
	ON d.country = c.country 
JOIN economies e 
	ON d.country = e.country 
	AND d.`year` = e.`year`
JOIN life_expectyncy_diff led 
	ON led.country = e.country 
WHERE
	d.population IS NOT NULL
	AND c.region_in_world IS NOT NULL
	AND d.`year` = 2019
	AND led.country IS NOT NULL 