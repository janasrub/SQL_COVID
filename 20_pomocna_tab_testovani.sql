 	
#spojení s covid test pøes country codes, protože napø. v tabulce covid test mìlo èesko jiný název a došlo by ke ztracení datu

/*	
SELECT * FROM country_codes cc 
WHERE country LIKE 'Cz%'	
;

SELECT * FROM covid19_tests ct  
WHERE country LIKE 'Cz%'
;

SELECT * FROM covid19_basic_differences cbd 
WHERE country LIKE 'Cz%'
;
*/




SELECT
	cbd.`date`,
	cbd.country,
	cbd.confirmed,
	ct.tests_performed 
FROM covid19_basic_differences cbd 
LEFT JOIN country_codes cc 
	ON cbd.country = cc.country 	
LEFT JOIN covid19_tests ct 
	ON cc.iso3 = ct.ISO  	
	AND cbd.`date` = ct.`date` 
WHERE cbd.country LIKE 'Cz%'	

# pokus s napojením èasových promìnných
/*
CREATE OR REPLACE TABLE t_1_cast AS
SELECT 
	cbd.`date` ,
	cbd.country,
	cbd.confirmed ,
	ct.tests_performed , 
	# YEAR (cbd.`date`) AS rok, >>>>>>>>>> proè tady mám ten rok?
CASE 
	WHEN weekday(cbd.`date`) IN (5,6) THEN '1'
	ELSE '0'
	END AS weekend,
CASE
	WHEN cbd.`date` BETWEEN '2020-01-22' AND '2020-03-19' THEN '3'
	WHEN cbd.`date` BETWEEN '2020-03-20' AND '2020-06-20' THEN '0'
	WHEN cbd.`date` BETWEEN '2020-06-21' AND '2020-09-20' THEN '1'
	WHEN cbd.`date` BETWEEN '2020-09-22' AND '2020-12-20' THEN '2'
	WHEN cbd.`date` BETWEEN '2020-12-21' AND '2021-03-19' THEN '3'
	WHEN cbd.`date` BETWEEN '2021-03-20' AND '2020-06-20' THEN '0'
	ELSE 'error'
	END AS seasons
FROM covid19_basic_differences cbd
JOIN country_codes cc 
	ON cbd.country = cc.country 	
JOIN covid19_tests ct 
	ON cc.iso3 = ct.ISO  	

SELECT * FROM t_1_cast tc 
*/

SELECT #kontrola pres sloupce zemì, jsou tam všechny èeské?
	cbd.`date` ,
	cbd.country,
	ct.country ,
	cc.country ,
	cbd.confirmed,
	ct.tests_performed,
	ct.ISO ,
	cc.iso3 
FROM covid19_basic_differences cbd 
LEFT JOIN country_codes cc 
	ON cbd.country = cc.country 
LEFT JOIN covid19_tests ct 
	ON cc.iso3 = ct.ISO 
	AND ct.`date` = cbd.`date` 
WHERE cbd.country LIKE 'Cz%'	
ORDER BY `date` 

	
	
	
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