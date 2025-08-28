CREATE DATABASE ENERGYCONSUMPTIONDB;
USE ENERGYCONSUMPTIONDB;

-- 1. country 


CREATE TABLE country(
Country VARCHAR(100) primary key,
CID VARCHAR(10)
);

SELECT * FROM country;
-- 2. emission table
CREATE TABLE emission (
    country VARCHAR(100),
    energytype VARCHAR(50),
    year INT,
    emission INT,
    percapitaemission DOUBLE,
    FOREIGN KEY(country) REFERENCES country(Country));
SELECT * FROM emission;

-- 3. population table
CREATE TABLE population(
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country));

SELECT * FROM population;


-- 4. production table
CREATE TABLE production(
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country));


SELECT * FROM production;

-- 5. gdp_3 table
CREATE TABLE gdp(
Country VARCHAR(100),
year INT,
Value DOUBLE,
FOREIGN KEY (Country) REFERENCES country(Country));

SELECT * FROM gdp;


-- 6. consumption table
CREATE TABLE consumption(
country VARCHAR(100),
energy VARCHAR(50),
year INT,
consumption INT,
FOREIGN KEY (country) REFERENCES country(Country));

SELECT * FROM consumption;
-- 1.what is the total emission per country for the most recent year avaialble?
SELECT country,SUM(emission) AS total_emission
FROM emission
WHERE year = (SELECT MAX(year) FROM emission)
GROUP BY country;

-- 2.what are the top 5 countries by  GDP in the most recent year?
SELECT Country,year,Value AS GDP_value
FROM gdp
WHERE year = (SELECT MAX(year) FROM gdp)
ORDER BY Value DESC
LIMIT 5;

-- 3.compare energy prduction and consumption by country and year
SELECT production.country,production.energy,production.year,
consumption.consumption,production.production FROM production
JOIN consumption ON production.country = consumption.country
AND production.year = consumption.year
AND production.energy = consumption.energy
ORDER BY production.production DESC;

-- 4.which energy types contribute most to emission across all countries?

SELECT energytype,sum(percapitaemission) AS total 
FROM emission
GROUP BY energytype
HAVING total = (
SELECT max(total)
FROM (SELECT energytype,sum(percapitaemission) AS total FROM emission
GROUP BY energytype) AS sub);

-- 5.Trend analysis overtime how have global emissions changed over year?
SELECT year,SUM(emission) AS emission_change
FROM emission
GROUP BY year
ORDER BY year DESC;

-- 6.what is the trend in GDP for each country over the given years?
SELECT Country,year,Value AS GDP
FROM gdp
ORDER BY Value desc,year;

-- 7.how has population growth effectedtotal emissions in each country?
SELECT population.countries,population.year,population.value,
SUM(emission.emission) AS population_count
FROM emission JOIN population ON emission.country = population.countries
AND emission.year = population.year
GROUP BY population.countries, population.year, population.value
ORDER BY population.countries, population.year;


-- 8.has energy consumption increased or decreased over the years for major economies?
SELECT major_economies.country,consumption.year,
SUM(consumption.consumption) AS total_consumption
FROM consumption
JOIN (SELECT gdp.country, SUM(gdp.value) AS total_gdp
FROM gdp GROUP BY gdp.country
ORDER BY total_gdp DESC LIMIT 5) AS major_economies
ON consumption.country = major_economies.country
GROUP BY consumption.year, major_economies.country
ORDER BY consumption.year DESC, major_economies.country;

-- 9.what is the average early change in emissions per capita for each country?

SELECT emission.country,emission.year,
ROUND(AVG(emission.percapitaemission), 6) AS avg_yearly_change
FROM emission
GROUP BY emission.country, emission.year;


-- 10.what is emission- to-GDP ratio for each country by year?

SELECT emission.country,emission.year,
ROUND(SUM(emission.emission) / gdp.value, 5) AS emission_to_gdp
FROM emission JOIN gdp ON emission.country = gdp.country
AND emission.year = gdp.year
GROUP BY emission.country, emission.year, gdp.value
ORDER BY emission.country, emission.year;

-- 11.How does energy production per capita vary across countries?
SELECT production.country,
ROUND(AVG(production.production / population.Value), 4) AS avg_productionpercapita
FROM production JOIN population ON production.country = population.countries
AND production.year = population.year
GROUP BY production.country
ORDER BY avg_productionpercapita DESC;

-- 12.Which countries have the highest energy consumption relative to GDP?
SELECT consumption.country,consumption.year,
SUM(consumption.consumption) / gdp.Value AS consumption_to_gdp_ratio
FROM consumption JOIN gdp ON consumption.country = gdp.Country AND consumption.year = gdp.year
GROUP BY consumption.country, consumption.year, gdp.Value
ORDER BY consumption_to_gdp_ratio DESC
LIMIT 10;


-- 13. What are the top 10 countries by population and how do their emissions compare?

SELECT population.countries,SUM(population.value) AS population,
ROUND(SUM(emission.emission), 4) AS emission
FROM population JOIN emission ON population.countries = emission.country
AND population.year = emission.year
GROUP BY population.countries
ORDER BY population DESC LIMIT 10;


-- 14.What is the global share (%) of emissions by country?
WITH total_emissions_by_country AS (SELECT emission.country, 
SUM(emission.emission) AS total_emission FROM emission
GROUP BY emission.country)
SELECT total_emissions_by_country.country,ROUND(total_emissions_by_country.total_emission * 100.0 / (SELECT SUM(emission.emission)
 FROM emission), 5) AS share
FROM total_emissions_by_country
ORDER BY share DESC;


