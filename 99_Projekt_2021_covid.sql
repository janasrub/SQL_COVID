#----------------------------------------------------------------------
#projekt
	
# ?asov? prom?nn? - bin?rn? prom?nn? pro v?kend / pracovn? den

CREATE OR REPLACE VIEW v_den_vikend as
/*
SELECT *, 
	CASE 
		WHEN dayname(`date`) BETWEEN 'Monday' AND 'Friday' THEN 'pracovn?_den'
		ELSE 'v?kend'
		END AS pracovni_den_vikend
FROM covid19_basic_differences cbd
*/

#druh? verze:
CREATE OR REPLACE VIEW v_den_vikend as
SELECT *, 
	CASE 
		WHEN weekday(`date`) IN (5,6) THEN '1'
		ELSE '0'
		END AS vikend
FROM covid19_basic_differences cbd


SELECT *
FROM v_den_vikend vdv 

#--------------------------------------------------------------------------


#ro?n? obdob? ro?n? obdob? dan?ho dne (zak?dujte pros?m jako 0 a? 3)
/* zji?t?n? ?asov?ho obdob? tabulky
SELECT min(`date`),max(`date`) 
FROM covid19_basic_differences cbd; 
*/
# m??u vytvo?it i tabulku
CREATE TABLE rocni_obdobi AS
	SELECT 
		date, country ,
		CASE
		WHEN `date` BETWEEN '2020-01-22' AND '2020-03-19' THEN '3 zima'
		WHEN `date` BETWEEN '2020-03-20' AND '2020-06-20' THEN '0 jaro'
		WHEN `date` BETWEEN '2020-06-21' AND '2020-09-20' THEN '1 leto'
		WHEN `date` BETWEEN '2020-09-22' AND '2020-12-20' THEN '2 podzim'
		WHEN `date` BETWEEN '2020-12-21' AND '2021-03-19' THEN '3 zima'
		WHEN `date` BETWEEN '2021-03-20' AND '2020-06-20' THEN '0 jaro'
		ELSE 'error'
		END AS rocni_obdobi
	FROM covid19_basic_differences
	ORDER BY `date` 
	;
#-----------------------------------------------------------------------------	
SELECT *
FROM rocni_obdobi ro 

#------------------------------------------------------------------------------
#eventueln? existuje tabulka seasons, kde je jaro 1, leto 2, podzim 3 a zima 0
#zde ov??en?, ?e 3 je podzim
SELECT max(s.`date`),  min(s.`date`)
FROM covid19_basic_differences cbd 
JOIN seasons s 
	ON cbd.`date` = s.`date` 
	WHERE s.seasons = '3'	
	;
#------------------------------------------------------------------------------	

CREATE OR REPLACE VIEW v_rocni_obd AS
	SELECT 
		date, country ,
		CASE
		WHEN `date` BETWEEN '2020-01-22' AND '2020-03-19' THEN '3 zima'
		WHEN `date` BETWEEN '2020-03-20' AND '2020-06-20' THEN '0 jaro'
		WHEN `date` BETWEEN '2020-06-21' AND '2020-09-20' THEN '1 leto'
		WHEN `date` BETWEEN '2020-09-22' AND '2020-12-20' THEN '2 podzim'
		WHEN `date` BETWEEN '2020-12-21' AND '2021-03-19' THEN '3 zima'
		WHEN `date` BETWEEN '2021-03-20' AND '2020-06-20' THEN '0 jaro'
		ELSE 'error'
		END AS rocni_obdobi
	FROM covid19_basic_differences
	

# pohled - ro?n? obdob?	- kontrola zima
SELECT *
FROM v_rocni_obd vro 
WHERE rocni_obdobi LIKE '3%'


# hotovo 
SELECT vdv.*, vro.rocni_obdobi 
FROM v_den_vikend vdv 
JOIN v_rocni_obd vro 
 	ON vdv.`date` = vro.`date` 
 	AND vdv.country = vro.country 
 	
 	
 	 	
#dohromady,fin?lni select, nazvy sloupc? anglicky
SELECT *, 
CASE 
	WHEN weekday(`date`) IN (5,6) THEN '1'
	ELSE '0'
	END AS weekend,
CASE
	WHEN `date` BETWEEN '2020-01-22' AND '2020-03-19' THEN '3'
	WHEN `date` BETWEEN '2020-03-20' AND '2020-06-20' THEN '0'
	WHEN `date` BETWEEN '2020-06-21' AND '2020-09-20' THEN '1'
	WHEN `date` BETWEEN '2020-09-22' AND '2020-12-20' THEN '2'
	WHEN `date` BETWEEN '2020-12-21' AND '2021-03-19' THEN '3'
	WHEN `date` BETWEEN '2021-03-20' AND '2020-06-20' THEN '0'
	ELSE 'error'
	END AS seasons
FROM covid19_basic_differences cbd


 	
 	
 	
#spojen? s covid test p?es country codes, proto?e nap?. v tabulce covid test m?lo ?esko jin? n?zev a ne?lo by spojit podle country jen ty dv? 
SELECT
	count(cbd.`date`)
	#cbd.country,
	#cbd.confirmed
	#ct.tests_performed 
FROM covid19_basic_differences cbd 
LEFT JOIN country_codes cc 
	ON cbd.country = cc.country 	
LEFT JOIN covid19_tests ct 
	ON cc.iso3 = ct.ISO  	
	AND cbd.`date` = ct.`date` 
	
 	
#spojen? obou
	
CREATE OR REPLACE VIEW v_1_cast AS
SELECT 
	cbd.`date` ,
	cbd.country,
	cbd.confirmed ,
	ct.tests_performed , 
	YEAR (cbd.`date`) AS rok,
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
	
#tabulka	
CREATE OR REPLACE TABLE t_1_cast AS
SELECT 
	cbd.`date` ,
	cbd.country,
	cbd.confirmed ,
	ct.tests_performed , 
	YEAR (cbd.`date`) AS rok,
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
	END AS seasons,
	ct.ISO ,
	cc.iso3 
FROM covid19_basic_differences cbd
LEFT JOIN country_codes cc 
	ON cbd.country = cc.country 	
LEFT JOIN covid19_tests ct 
	ON cc.iso3 = ct.ISO  	
 	AND ct.`date` = cbd.`date` 
 	
 	
SELECT * FROM t_1_cast tc 
WHERE country = 'Austria'
ORDER BY `date` 


 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	
 	

# pohled 2 prom?nn? specifick? pro dan? st?t
 	
# hustota zalidn?n? - ve st?tech s vy??? hustotou zalidn?n? se n?kaza m??e ???it rychleji


#hustota zalidneni v jednotliv?ch letech
CREATE OR REPLACE VIEW v_2_cast AS
SELECT
	d.country ,
	'd.`year`',
	d.population ,
	round(d.population / c.surface_area,2) AS hustota_zalidneni,
	e.GDP ,
	e.gini ,
	d.mortaliy_under5 ,
	ma.median_age_2018 
FROM demographics d 
	JOIN countries c 
	ON d.country = c.country 
	JOIN median_age ma 
	ON c.iso_numeric = ma.iso_numeric 
	JOIN economies e 
	ON d.country = e.country 
	AND d.`year` = e.`year` 
	WHERE d.population IS NOT NULL AND c.region_in_world IS NOT NULL
	
CREATE OR REPLACE TABLE t_2_cast AS
SELECT 
	e.population ,
	e.country ,
	e.`year` ,
	round(e.population / c.surface_area,2) AS hustota_zalidneni,
	e.GDP ,				#?daje z roku 2020
	e.gini ,			#hodn? ?daj? chyb?
	d.mortaliy_under5 , #?daje z roku 2019
	c.median_age_2018 
FROM economies e 
JOIN countries c 
	ON e.country = c.country
JOIN demographics d 
	ON d.country = e.country 
	AND d.`year` = 2019
WHERE e.`year` = 2020
	
	
	

SELECT 
	tc1.country,
	tc1.`date` ,
	tc1.weekend ,
	tc1.seasons ,
	tc1.confirmed ,
	tc1.tests_performed ,
	round(tc1.confirmed / tc2.population * 100,4) AS confirmed_proc ,
	round(tc1.tests_performed / tc2.population * 100,4) AS tests_performed_proc ,
	tc2.population ,
	tc2.GDP ,
	tc2.gini ,
	tc2.mortaliy_under5 ,
	tc2.median_age_2018 
	FROM t_1_cast 
	tc1
JOIN t_2_cast tc2 
	ON tc1.country = tc2.country 
	AND tc1.rok = tc2.`year` 

 
	
	
	

	
#nabozenstvi
SELECT r. country , r.religion, round(population /relig_suma.celkem_pop*100,2) 
FROM religions r 
JOIN 
	(SELECT r.country , r.`year` ,sum(r.population) AS celkem_pop 						#vnoren?m selektem po??t?m sumu jednotliv?ch n?bo?enstv? v roce 2020, abych ji pak mohla pou??t pro procentu?ln? pod?l jednotliv?ch n?bo?enstv?
		FROM religions r 
		WHERE `year` = '2020'
		GROUP BY r.country 
	) AS relig_suma
ON r.country = relig_suma.country
AND r.`year` = relig_suma.`year`
AND r.population > 0


#nabozenstvi
SELECT r. country , r.religion, round(population /relig_suma.celkem_pop*100,2) 
FROM religions r 
JOIN 
	(SELECT r.country , r.`year` ,sum(r.population) AS celkem_pop 						#vnoren?m selektem po??t?m sumu jednotliv?ch n?bo?enstv? v roce 2020, abych ji pak mohla pou??t pro procentu?ln? pod?l jednotliv?ch n?bo?enstv?
		FROM religions r 
		WHERE `year` = '2020'
		GROUP BY r.country 
	) AS relig_suma
ON r.country = relig_suma.country
AND r.`year` = relig_suma.`year`
AND r.population > 0

#3. pocasi
#Po?as? (ovliv?uje chov?n? lid? a tak? schopnost ???en? viru)

#pr?m?rn? denn? (nikoli no?n?!) teplota
/*
SELECT city , round(avg(cast ((REPLACE (temp,'?c',' ')) AS integer)),2) AS temperature, `date` 
FROM weather w 
WHERE city IS NOT NULL AND `time` BETWEEN '06:00' AND '21:00'
GROUP BY `date` , city
*/
/*ov??en? na Amsterdamu
SELECT city , cast ((REPLACE (temp,'?c',' ')) AS integer) AS temperature , `date` , `time` 
FROM weather w 
WHERE `time` BETWEEN '06:00' AND '21:00' AND city = 'Amsterdam'
ORDER BY `date`

pr?m?r:
SELECT city , round(avg(cast ((REPLACE (temp,'?c',' ')) AS integer)),2) AS temperature, `date` 
FROM weather w 
WHERE `time` BETWEEN '06:00' AND '21:00' AND city = 'Amsterdam'
GROUP BY `date` , city
*/


#po?et hodin v dan?m dni, kdy byly sr??ky nenulov?
/*
SELECT city , `date` , count(rain) AS pocet_hodin_prsi
FROM weather w 
WHERE rain > 0 AND city IS NOT NULL 
GROUP BY city, `date`
*/

/* ov??en?, V Amsterdamu pr?elo 3.1.2020 6x tj v ka?dou sledovanou hodinu byly sr??ky.
SELECT city , `date` , time, rain 
FROM weather w 
WHERE rain > 0 AND city = 'Amsterdam'
ORDER BY `date`
*/


#maxim?ln? s?la v?tru v n?razech b?hem dne
/*
SELECT city, `date` , max(gust) 
FROM weather w 
WHERE city IS NOT null
GROUP BY `date` , city 
*/

/* ov??en? na Amsterdamu
SELECT city , `date` , time, gust
FROM weather w 
WHERE city = 'Amsterdam'
ORDER BY `date` 
*/	

/*Po?as?
pr?m?rn? denn? (nikoli no?n?!) teplota
*/
CREATE OR REPLACE VIEW v_prum_denni_teplota AS
SELECT 
	city ,
	round(avg(cast ((REPLACE (temp,'?c',' ')) AS integer)),2) AS temperature,
	date(`date`) AS datum,
	count(rain) AS pocet_hodin_prsi
FROM weather w 
WHERE city IS NOT NULL AND `time` BETWEEN '06:00' AND '21:00'
GROUP BY city, `date`

/*Po?as?
po?et hodin v dan?m dni, kdy byly sr??ky nenulov?
*/
CREATE OR REPLACE VIEW v_kdyz_prselo AS
SELECT
	city , 
	`date` ,
	count(rain) AS pocet_hodin_prsi
FROM weather w 
WHERE rain > 0 AND city IS NOT NULL 
GROUP BY city, `date`

/*Po?as?
maxim?ln? s?la v?tru v n?razech b?hem dne
*/
CREATE OR REPLACE VIEW v_sila_vetru AS
SELECT 
	city,
	`date` ,
	max(gust) AS max_naraz
FROM weather w 
WHERE city IS NOT null
GROUP BY `date` , city 

# cel? po?as? spojen? do jednoho selectu

SELECT pt.datum, pt.city, pt.temperature ,vkp.pocet_hodin_prsi, vsv.max_naraz
FROM v_prum_denni_teplota pt 
JOIN v_kdyz_prselo vkp
	ON pt.city = vkp.city 
	AND pt.datum = vkp.`date` 
JOIN v_sila_vetru vsv 
	ON vsv.city = pt.city 
	AND vsv.`date` = pt.datum 
	
