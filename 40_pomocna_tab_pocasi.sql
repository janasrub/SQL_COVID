
##############################
# 3x view a pak jedna tabulka

/*Po?as?
pr?m?rn? denn? (nikoli no?n?!) teplota
*/
###############################################
CREATE OR REPLACE view v_prum_denni_teplota AS
SELECT 
	city ,
	round(avg(cast ((REPLACE (temp,'?c',' ')) AS integer)),2) AS temperature,
	date(`date`) AS datum
FROM weather w 
WHERE city IS NOT NULL AND `time` BETWEEN '06:00' AND '21:00'
GROUP BY city, `date`


/*Po?as?
po?et hodin v dan?m dni, kdy byly sr??ky nenulov?
*/
##############################################

CREATE OR REPLACE VIEW v_prsi AS	
SELECT
	city ,
	date(`date`) AS datum,
	count(CAST((REPLACE (rain,' mm',''))AS float)) AS prselo
	#count(CAST(rain as float)) AS prselo
FROM weather w
WHERE city IS NOT NULL AND CAST((REPLACE (rain,' mm',''))AS float) > 0
GROUP BY city, `date`
	

/*Po?as?
maxim?ln? s?la v?tru v n?razech b?hem dne
*/
################################################
CREATE OR REPLACE view v_sila_vetru AS
SELECT 
	city,
	`date` ,
	max(CAST((REPLACE (gust,'km/h',''))AS integer)) AS max_naraz
FROM weather w 
WHERE city IS NOT null
GROUP BY `date` , city 


################################################

# cel? po?as? spojen? do jednoho selectu
# tabulka  ze t?? view
CREATE OR REPLACE TABLE t_05_weather as
SELECT vpdt.datum, vpdt.city, vpdt.temperature ,vp.prselo , vsv.max_naraz
FROM v_prum_denni_teplota vpdt 
LEFT JOIN v_prsi vp 
	ON vpdt.city = vp.city 
	AND vpdt.datum = vp.datum 
LEFT JOIN v_sila_vetru vsv 
	ON vsv.city = vp.city 
	AND vsv.`date` = vp.datum 

/*	
SELECT * FROM t_05_weather tw 	
*/
SELECT * FROM t_05_weather tw 	
	
	
#Tady v?echno dohromady	
CREATE OR REPLACE view v_pocasi AS
SELECT 
	date(`date`) AS datum,
	city ,
	round(avg(cast ((REPLACE (temp,'?c',' ')) AS integer)),2) AS temperature,
	max(CAST((REPLACE (gust,'km/h',''))AS integer)) AS max_naraz,
	count(CAST((REPLACE (rain,' mm',''))AS float)) AS prselo
FROM weather w
WHERE (city IS NOT NULL AND CAST((REPLACE (rain,' mm',''))AS float) > 0)
OR (city IS NOT NULL AND `time` BETWEEN '06:00' AND '21:00')
OR (city IS NOT NULL AND CAST((REPLACE (rain,' mm',''))AS float) > 0)
GROUP BY city, date(`date`)		

SELECT *
FROM v_pocasi vp 

#vytvo?en? tabulky
CREATE OR REPLACE TABLE t_04_pocasi AS
SELECT 
	date(w.`date`) AS datum,
	w.city ,
	c.country ,
	round(avg(cast ((REPLACE (w.temp,'?c',' ')) AS integer)),2) AS temperature,
	max(CAST((REPLACE (w.gust,'km/h',''))AS integer)) AS max_naraz,
	count(CAST((REPLACE (w.rain,' mm',''))AS float)) AS prselo
FROM weather w
JOIN cities c 
	ON w.city = c.city 
WHERE (w.city IS NOT NULL AND CAST((REPLACE (w.rain,' mm',''))AS float) > 0)
OR (w.city IS NOT NULL AND w.`time` BETWEEN '06:00' AND '21:00')
OR (w.city IS NOT NULL AND CAST((REPLACE (w.rain,' mm',''))AS float) > 0)
GROUP BY w.city, date(w.`date`)		


	

	
