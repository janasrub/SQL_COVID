# SQL_COVID
SQL_COVID_ENGETO - my first projekt in SQL

## Zadání: 

Od Vašeho kolegy statistika jste obdrželi následující email:

#############################################################################

Dobrý den,

snažím se určit faktory, které ovlivňují rychlost šíření koronaviru na úrovni jednotlivých států. Chtěl bych Vás, coby datového analytika, požádat o pomoc s přípravou dat, která potom budu statisticky zpracovávat. Prosím Vás o dodání dat podle požadavků sepsaných níže.

Výsledná data budou panelová, klíče budou stát (country) a den (date). Budu vyhodnocovat model, který bude vysvětlovat denní nárůsty nakažených v jednotlivých zemích. Samotné počty nakažených mi nicméně nejsou nic platné - je potřeba vzít v úvahu také počty provedených testů a počet obyvatel daného státu. Z těchto tří proměnných je potom možné vytvořit vhodnou vysvětlovanou proměnnou. Denní počty nakažených chci vysvětlovat pomocí proměnných několika typů. Každý sloupec v tabulce bude představovat jednu proměnnou. Chceme získat následující sloupce:

Časové proměnné
binární proměnná pro víkend / pracovní den
roční období daného dne (zakódujte prosím jako 0 až 3)
Proměnné specifické pro daný stát
hustota zalidnění - ve státech s vyšší hustotou zalidnění se nákaza může šířit rychleji
HDP na obyvatele - použijeme jako indikátor ekonomické vyspělosti státu
GINI koeficient - má majetková nerovnost vliv na šíření koronaviru?
dětská úmrtnost - použijeme jako indikátor kvality zdravotnictví
medián věku obyvatel v roce 2018 - státy se starším obyvatelstvem mohou být postiženy více
podíly jednotlivých náboženství - použijeme jako proxy proměnnou pro kulturní specifika. Pro každé náboženství v daném státě bych chtěl procentní podíl jeho příslušníků na celkovém obyvatelstvu
rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015 - státy, ve kterých proběhl rychlý rozvoj mohou reagovat jinak než země, které jsou vyspělé už delší dobu
Počasí (ovlivňuje chování lidí a také schopnost šíření viru)
průměrná denní (nikoli noční!) teplota
počet hodin v daném dni, kdy byly srážky nenulové
maximální síla větru v nárazech během dne
Napadají Vás ještě nějaké další proměnné, které bychom mohli použít? Pokud vím, měl(a) byste si vystačit s daty z následujících tabulek: countries, economies, life_expectancy, religions, covid19_basic_differences, covid19_testing, weather, lookup_table.

V případě nejasností se mě určitě zeptejte.

S pozdravem, Student (a.k.a. William Gosset)

#############################################################################

Výstup: Pomozte Vašemu kolegovi s daným úkolem. Výstupem by měla být tabulka na databázi, ze které se požadovaná data dají získat jedním selectem. Tabulku pojmenujte t_{jméno}_{příjmení}_projekt_SQL_final. Na svém GitHub účtu vytvořte repozitář (může být soukromý), kam uložíte všechny informace k projektu - hlavně SQL skript generující výslednou tabulku, popis mezivýsledků, informace o výstupních datech (například kde chybí hodnoty apod.). 

##########################################################################################################################################################

# Návod jak vytvořit požadovanou tabulku

V souboru **final table** jsou uloženy všechny potřebné dotazy k vytvoření finální tabulky.

Postupně vytvořit tabulky a view:

**t_01_day_season**

**t_02_tests**

**t_03_demo_economics**

**t_04_pocasi**

**v_nabozenstvi**

a pak vytvořit celkovou tabulku **covid_final** se všemi požadovanými sloupci





#############################################################################



# Postup mé práce

## Časové proměnné

1. Binární proměnná pro víkend / pracovní den
2. Roční období daného dne (zakódujte prosím jako 0 až 3)

--------------------------------------------------------------------------------

Jako základ jsem použila tabulku **covid19_basic_differences cbd**



Binární proměnná pro víkend / pracovní den

Nejdříve jsem pomocí funkce weekday vytvořila nový sloupec **weekend**, kde víkendové dny jsou označené jako 1 a pracovní dny 0

Roční období daného dne (zakódujte prosím jako 0 až 3)

V prvním návrhu jsou vytvořila nový sloupec **season** a pomocí podmínek definovala roční období přesně podle data včetně roku a přiřadila čísla dle pořadí 0-jaro ....3-zima.

V druhém návrhu jsem tento sloupec vytvořila stejným způsobem ale aby dotaz fungoval i v příštích letech, tak jsem vliv roku odebrala pomocí funkce date_format a určila jsem rozhodují datumy pro začátek ročních období takto:

jaro 21.3.
léto 21.6	
podzim 22.9
zima 21.12.

Každou proměnou jsem tvořila zvlášt a pak jsem je zkombinovala v jednom dotazu.

Nakonec je vytvořena tabulka **t_01_day_season**

Dotaz je uložen v souboru **10_pomocná_tab_casove_promenne**



## Vytvoření tabulky s počty nakažených a testovaných

V zadání je požadavek na sledování denního přírustku nakažených v jednotlivých zemích, počty provedených testů a počet obyvatel daného státu. Z těchto tří proměnných vytvořit vhodnou proměnnou.

Jako vhodnou proměnnou mě napadlo vytvořit procentuální podíl nakažených a procentuální podíl testovaných v jednotlivých zemích.

Data o covidu jsou čerpána z tabulek: **covid19_basic_differences, covid19_tests**. Počet obyvatel daného státu **population** je z tabulky: **countries**

Protože v tabulce **covid19_basic_differences** a **covid19_tests** jména některých zemí rozdílná např. Czechia a Czech Republic použila jsem pro spojení pomocnou tabulku country_codes a k propojení použila sloupce ISO a ISO3. Do tabulky jsem připojila sloupec median_age_2018, který je tabulce **countries**.

Nakonec je vytvořena tabulka **t_02_tests**

Dotaz je uložen v souboru **20_pomocna_tab_testovani.sql**



## Vytvoření tabulky s demografickými a ekonomickými daty

Data jsou čerpána z tabulek: 

**demographics** - countries, year, population, mortality_under5 - vybírám rok 2019, v roce 2020 nejsou data k mortalitě

**countries** - rozloha > k vypočtení hustoty zalidnění

**economies** - z tabulky beru poslední údaje z roku 2020, GDP,  GINI - některé země neuváději, 

**life_expectyncy_diff**

Vzniká sloupec vypočítáný sloupec population_density

Nakonec je vytvořena tabulka **t_03_demo_economics**

Dotaz je uložen v souboru **30_pomocna_tab_demografy.sql**



## Vytvoření tabulky počasí

Data jsou čerpána z tabulky **weather**

Nejdříve jsem vytvořila dotazy pro jednotlivé sloupce: průměrná denní teplota, počet hodin bez srážek, maximální síla nárazu větru. 

Využila jsem funkce REPLACE a CAST. 

Pak jsem vytvořila z každého dotazu view, které jsem spojila do jedné tabulky.

Později jsem tuhle verzi opustila a vytvořila všechny tři sloupce jedním dotazem a uložila do tabulky.

Protože v tabulce waether chybí country a je pouze city spojila jsem weather s tabulkou cities, abych mohla doplnit sloupec country pro další spojování.

Nakonec je vytvořena tabulka  **t_04_pocasi**

Dotaz je uložen v souboru **40_pomocna_tab_pocasi**



## Vytvoření tabulky náboženství

Data jsou čerpána z tabulky **religions**. V tabulce jsou data za rok 2010, 2020, 2030, 2040, 2050. Zřejmě výhled do budoucna. Vybírám data současné 2020, které se mají nejblíže ke covidovým datům.

Nejdříve jsem vytvořila tabulku, kde jsem měla jednotlivé náboženstí v řádcích. 

Teprve při spojování tabulek mi docvaklo, že to takhle nespojím a pomocí CASE jsem vytvořila tabulku se sloupci.

Nakonec je vytvořeno view  **v_nabozenstvi**

Dotaz je uložen v souboru **50_pomocne_view_nabozenstvi**



## **Vytvoření závěrečné tabulky**

Spojila jsem všechny tabulky dohromady,

jako základní tabulku jsem použila t_02_tests, která obsahuje všechna covidová data a k ní jsem připojovala ostatní tabulky.





