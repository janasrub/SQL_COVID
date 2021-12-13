#PROJEKT ENGETO DATOVA AKADEMIE 2021 - ZPRACOVANI DAT O COVIDU


#Nejdøíve vytvoøit jednotlivé tabulky

#vytvoøení první tabulky  t_01_day_season
#èasové promìnné dohromady s tabulkou covid pøírùstky
#nový sloupec season znaèí roèní období (0 jaro......)
#nový sloupec weekend: 1 víkend, 0 pracovní den;		

CREATE OR REPLACE TABLE t_01_day_season as
SELECT 
	DISTINCT date, 
	CASE
		WHEN date_format(`date`, '%m-%d') BETWEEN '03-21' AND '06-20' THEN '0'
		WHEN date_format(`date`, '%m-%d') BETWEEN '06-21' AND '09-20' THEN '1'
		WHEN date_format(`date`, '%m-%d') BETWEEN '09-21' AND '12-19' THEN '2'
		ELSE '3'
		END AS season,
	CASE 
		WHEN weekday(`date`) IN (5,6) THEN '1'
		ELSE '0'
		END AS weekend
FROM covid19_basic_differences
ORDER BY `date` 
;


##############################################################################


#vytvoøení druhé tabulky t_02_tests
#spojení s testy, výpoèet, hustota obyvatel, prùmìrný vìk 2018
#nový sloupec percentagge_confirmed, procentuální podíl nakažených v populaci
#nový sloupec percentage_tests_performed, procentuální podíl uzdravených v populaci
#nìkteré zemì v tabulce covid19_tests mají jiný název než v tabulce covid19_basic_differences


CREATE OR REPLACE TABLE t_02_tests AS 
SELECT
	cbd.`date`,
	cbd.country,
	cbd.confirmed,
	cbd.confirmed/c.population*100 AS percentagge_confirmed, 
	ct.tests_performed,
	ct.tests_performed/c.population*100 AS percentage_tests_performed,
	c.median_age_2018,
	c.iso3 ,
	ct.ISO ,
	c.capital_city 
FROM covid19_basic_differences cbd 
LEFT JOIN country_codes cc 
	ON cbd.country = cc.country 
LEFT JOIN countries c 
	ON cc.iso3 = c.iso3 
LEFT JOIN covid19_tests ct 
	ON cc.iso3 = ct.ISO  	
	AND cbd.`date` = ct.`date` 
WHERE c.population IS NOT NULL 
;


#################################################


#vytvoøení tøetí tabulky t_03_demo_economics
#country, rok, hustota zalidneni, GDP, GINI, dìtská umrtnost,life_expectancy_diff
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

	
##########################################################

	
# vytvoøení ètvrté tabulky t_04_pocasi  pozor hlavní mìsta
CREATE OR REPLACE TABLE t_04_pocasi AS
SELECT 
	date(w.`date`) AS datum,
	w.city ,
	c.country ,
	round(avg(cast ((REPLACE (w.temp,'°c',' ')) AS integer)),2) AS temperature,
	max(CAST((REPLACE (w.gust,'km/h',''))AS integer)) AS max_naraz,
	count(CAST((REPLACE (w.rain,' mm',''))AS float)) AS prselo
FROM weather w
JOIN cities c 
	ON w.city = c.city 
WHERE (w.city IS NOT NULL AND CAST((REPLACE (w.rain,' mm',''))AS float) > 0)
OR (w.city IS NOT NULL AND w.`time` BETWEEN '06:00' AND '21:00')
OR (w.city IS NOT NULL AND CAST((REPLACE (w.rain,' mm',''))AS float) > 0)
GROUP BY w.city, date(w.`date`)		


######################################################	
	

#vytvoøení VIEW v_nabozenstvi 
#vytvoøím pohled ve kterém budou v jednotlivých sloupcích poèty obyvatel 
#hlásících s k urèitému naboženství, z tabulky religion vybírám rok 2020, který je nejblíže covidovým datùm.

CREATE OR REPLACE view v_nabozenstvi as
SELECT
	r.country ,
	round(sum(CASE WHEN r.religion = 'Christianity' THEN r.population 
	END)/sum(r.population)*100,2) AS Christianity, 
	round(sum(CASE WHEN r.religion = 'Islam' THEN r.population 
	END)/sum(r.population)*100,2) AS Islam,
	round(sum(CASE WHEN r.religion = 'Buddhism' THEN r.population 
	END)/sum(r.population)*100,2) AS Buddhism,
	round(sum(CASE WHEN r.religion = 'Hinduism' THEN r.population 
	END)/sum(r.population)*100,2) AS Hinduism,
	round(sum(CASE WHEN r.religion = 'Judaism' THEN r.population 
	END)/sum(r.population)*100,2) AS Judaism,
	round(sum(CASE WHEN r.religion = 'Folk Religions' THEN r.population 
	END)/sum(r.population)*100,2) AS Folk_Religions,
	round(sum(CASE WHEN r.religion = 'Other Religions' THEN r.population 
	END)/sum(r.population)*100,2) AS Other_Religions,
	round(sum(CASE WHEN r.religion = 'Unaffiliated Religions' THEN r.population 
	END)/sum(r.population)*100,2) AS Unaffiliated_Religions
FROM religions r
WHERE `year` = 2020
GROUP BY country	
	


#vytvoøení finální tabulky
CREATE OR REPLACE TABLE covid_final AS
SELECT 
	tt.`date` ,
	tds.weekend ,
	tds.season ,
	tt.country ,
	tt.confirmed ,
	tt.percentagge_confirmed ,
	tt.tests_performed ,
	tt.percentage_tests_performed ,
	tde.population_density ,
	tde.GDP ,
	tde.gini ,
	tde.mortaliy_under5 ,
	tt.median_age_2018 ,
	tde.life_expectancy_diff,
	vn.Christianity ,
	vn.Islam ,
	vn.Buddhism ,
	vn.Hinduism ,
	vn.Judaism ,
	vn.Folk_Religions ,
	vn.Other_Religions ,
	vn.Unaffiliated_Religions ,
	tp.temperature ,
	tp.prselo AS rain,
	tp.max_naraz AS max_gust
FROM t_02_tests tt 
LEFT JOIN t_01_day_season tds 
	ON tt.`date` = tds.`date` 
LEFT JOIN t_03_demo_economics tde 
	ON tde.iso3 = tt.iso3 
LEFT JOIN t_04_pocasi tp 
	ON tp.country = tt.country 
	AND tp.datum = tds.`date` 
LEFT JOIN v_nabozenstvi vn 
	ON vn.country = tde.country 
	
	
SELECT * FROM covid_final cf 

