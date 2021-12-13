#nabozenstvi
/*
Nejd��ve vytvo��m pohled ve kter�m budou v jednotliv�ch sloupc�ch po�ty obyvatel 
hl�s�c�ch s k ur�it�mu nabo�enstv�, z tabulky religion vyb�r�m rok 2020, kter� je nejbl�e covidov�m dat�m.
*/

#nabozenstvi

#SELECT DISTINCT `year` FROM religions

SELECT r. country , r.religion, round(population /relig_suma.celkem_pop*100,2) 
FROM religions r 
JOIN 
	(SELECT r.country , r.`year` ,sum(r.population) AS celkem_pop 						#vnoren�m selektem po��t�m sumu jednotliv�ch n�bo�enstv� v roce 2020, abych ji pak mohla pou��t pro procentu�ln� pod�l jednotliv�ch n�bo�enstv�
		FROM religions r 
		WHERE `year` = '2020'
		GROUP BY r.country 
	) AS relig_suma
ON r.country = relig_suma.country
AND r.`year` = relig_suma.`year`
AND r.population > 0


#p�evod na sloupce
CREATE OR REPLACE view v_nabozenstvi as
SELECT
	r.country ,
	sum(r.population),
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

SELECT * FROM v_nabozenstvi vn 






























