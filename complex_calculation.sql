-- average gdp across all year per country 
SELECT country_id, 
year, gdp, 
AVG(gdp) OVER(PARTITION BY country_id) AS country_avg_gdp
FROM country_stats;

-- average total country medals by region 
SELECT region, AVG(total_golds) AS avg_total_golds
FROM
(-- total golds by region and country
SELECT country_id,
region, SUM(COALESCE(gold, 0)) AS total_golds
FROM summer_games AS s
JOIN countries AS c
ON s.country_id=c.id
GROUP BY country_id, region) AS subquery
GROUP BY region
ORDER BY avg_total_golds DESC; 


-- percent of gdp per country

-- select country_gdp by region and country
SELECT region, country, 
SUM(gdp) AS country_gdp,
-- calculate global gdp 
SUM(SUM(gdp)) OVER() AS global_gdp,
-- calculate percent of global gdp 
SUM(gdp) / SUM(SUM(gdp)) OVER() AS perc_global_gdp,
-- calculate percent of gdp relative to its region
SUM(gdp) / SUM(SUM(gdp)) OVER(PARTITION BY region) AS perc_region_gdp
FROM country_stats AS cs
JOIN countries AS c
ON cs.country_id=c.id 
WHERE gdp IS NOT NULL 
GROUP BY region, country
ORDER BY country_gdp DESC;


-- gdp per capita performance index 

SELECT region, country,
SUM(gdp) / SUM(CAST(pop_in_millions AS float)) AS gdp_per_million,
SUM(SUM(gdp)) OVER() / SUM(SUM(CAST(pop_in_millions AS float))) OVER() AS gdp_per_million_total,
-- performance index 
(SUM(gdp) / SUM(CAST(pop_in_millions AS float))) 
/ 
(SUM(SUM(gdp)) OVER() / SUM(SUM(CAST(pop_in_millions AS float))) OVER()) AS performance_index
FROM country_stats AS cs 
JOIN countries AS c
ON cs.country_id=c.id 
-- calculate it since 2016
WHERE year='2016-01-01' AND gdp IS NOT NULL 
GROUP BY region, country
ORDER BY gdp_per_million DESC;


-- tallest athletes and % GDP by region 

-- see the country_id and height and number the height of each country's athletes
SELECT region, 
AVG(height) AS avg_tallest,
-- region's percent of world gdp
SUM(gdp) / SUM(SUM(gdp)) OVER() AS perc_world_gdp
FROM countries AS c 
JOIN (SELECT country_id, height, 
ROW_NUMBER() OVER(PARTITION BY country_id ORDER BY height DESC) AS row_num
FROM winter_games AS w
JOIN athletes AS a
ON w.athlete_id=a.id
GROUP BY country_id, height 
ORDER BY country_id, height DESC) AS subquery
ON c.id=subquery.country_id
JOIN country_stats AS cs 
ON cs.country_id=c.id 
-- only include the tallest height for each country
WHERE row_num=1
GROUP BY region; 