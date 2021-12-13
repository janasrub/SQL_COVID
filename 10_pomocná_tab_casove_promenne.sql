# �asov� prom�nn� - bin�rn� prom�nn� pro v�kend / pracovn� den
SELECT DISTINCT date,
	CASE 
		WHEN weekday(`date`) IN (5,6) THEN '1'
		ELSE '0'
		END AS weekend
FROM covid19_basic_differences cbd
;


#ro�n� obdob� ro�n� obdob� dan�ho dne (zak�dujte pros�m jako 0 a� 3)
SELECT 
	DISTINCT date, 
	CASE
	WHEN `date` BETWEEN '2020-01-22' AND '2020-03-19' THEN '3'
	WHEN `date` BETWEEN '2020-03-20' AND '2020-06-20' THEN '0'
	WHEN `date` BETWEEN '2020-06-21' AND '2020-09-20' THEN '1'
	WHEN `date` BETWEEN '2020-09-22' AND '2020-12-20' THEN '2'
	WHEN `date` BETWEEN '2020-12-21' AND '2021-03-19' THEN '3'
	WHEN `date` BETWEEN '2021-03-20' AND '2020-06-20' THEN '0'
	ELSE 'error'
	END AS seison
FROM covid19_basic_differences
ORDER BY `date` 
;

#�asov� prom�nn� dohromady
CREATE OR REPLACE TABLE t_01_day_season as
SELECT 
	DISTINCT date, 
	CASE
	WHEN `date` BETWEEN '2020-01-22' AND '2020-03-19' THEN '3'
	WHEN `date` BETWEEN '2020-03-20' AND '2020-06-20' THEN '0'
	WHEN `date` BETWEEN '2020-06-21' AND '2020-09-20' THEN '1'
	WHEN `date` BETWEEN '2020-09-22' AND '2020-12-20' THEN '2'
	WHEN `date` BETWEEN '2020-12-21' AND '2021-03-19' THEN '3'
	WHEN `date` BETWEEN '2021-03-20' AND '2020-06-20' THEN '0'
	ELSE 'error'
	END AS season,
	CASE 
		WHEN weekday(`date`) IN (5,6) THEN '1'
		ELSE '0'
		END AS weekend
FROM covid19_basic_differences
ORDER BY `date` 
;

/*
#ro�n� obdob� - lep�� verze
jako rozhoduj�c� datumy pro za��tek ro�n�ho obdob� jsem dle m�ho z�kladn�ho �koln�ho vzd�l�n� pro zjednodu�en� stanovila takto:
jaro 21.3.
l�to 21.6	
podzim 22.9
zima 21.12.
*/


SELECT 
	DISTINCT date,
	CASE
		WHEN date_format(`date`, '%m-%d') BETWEEN '03-21' AND '06-20' THEN '0'
		WHEN date_format(`date`, '%m-%d') BETWEEN '06-21' AND '09-20' THEN '1'
		WHEN date_format(`date`, '%m-%d') BETWEEN '09-21' AND '12-19' THEN '2'
		ELSE '3'
		END AS seison
FROM covid19_basic_differences cbd 


#�asov� prom�nn� dohromady s lep�� verz� ro�n�ch obdob�

CREATE OR REPLACE TABLE t_01_day_season as
SELECT 
	DISTINCT date, 
	CASE
		WHEN date_format(`date`, '%m-%d') BETWEEN '03-21' AND '06-20' THEN '0'
		WHEN date_format(`date`, '%m-%d') BETWEEN '06-21' AND '09-20' THEN '1'
		WHEN date_format(`date`, '%m-%d') BETWEEN '09-21' AND '12-19' THEN '2'
		ELSE '3'
		END AS seison,
	CASE 
		WHEN weekday(`date`) IN (5,6) THEN '1'
		ELSE '0'
		END AS weekend
FROM covid19_basic_differences
ORDER BY `date` 
;


