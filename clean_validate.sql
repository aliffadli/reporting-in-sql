-- see a country_stats column data types 
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_name='country_stats';


-- testing date function to gain decade
-- using date_part and date_trunc 
SELECT year, DATE_PART('decade', CAST(year AS date)) AS decade, 
DATE_TRUNC('decade', CAST(year AS date)) AS decade_truncated,
SUM(gdp) AS world_gdp
FROM country_stats
GROUP BY year
ORDER BY year DESC;
-- decade_trunc is a timestamp with date, while decade is a double precision or numeric


-- convert country to lower case
SELECT country, LOWER(country) AS country_altered
FROM countries
GROUP BY country; 

-- convert country to proper case
SELECT country, 
INITCAP(country) AS country_altered
FROM countries 
GROUP BY country; 

-- Output the left 3 characters of country
SELECT country,
LEFT(country, 3) AS country_altered
FROM countries
GROUP BY country; 

-- Output all characters starting with position 7
SELECT country, 
SUBSTRING(country FROM 7) AS country_altered
FROM countries
GROUP BY country;

-- replacing and removing substring 
SELECT region, 
REPLACE(region, '&', 'and') AS character_swap,
REPLACE(region, '.', '') AS character_remove,
REPLACE(REPLACE(region, '&', 'and'), '.', '') AS character_swap_and_remove
FROM countries
WHERE region = 'LATIN AMER. & CARIB'
GROUP BY region; 


-- show total gold_medals by country and filter null values
-- using WHERE
SELECT country, SUM(gold) AS gold_medals
FROM winter_games AS w
JOIN countries AS c
ON w.country_id=c.id
WHERE gold IS NOT NULL
GROUP BY country
ORDER BY gold_medals DESC;

-- show total gold_medals by country and filter null values
-- using HAVING
SELECT country, SUM(gold) AS gold_medals
FROM winter_games AS w
JOIN countries AS c
ON w.country_id=c.id
GROUP BY country
HAVING SUM(GOLD) IS NOT NULL
ORDER BY gold_medals DESC;


-- replace all null gold values with 0 
SELECT athlete_id, 
AVG(COALESCE(gold, 0)) AS avg_golds,
COUNT(event) AS total_events,
SUM(COALESCE(gold, 0)) AS gold_medals 
FROM summer_games 
GROUP BY athlete_id
ORDER BY total_events DESC, athlete_id;


-- identifying duplication

-- total golds from winter sports 
SELECT SUM(gold) AS gold_medals 
FROM winter_games;

-- show gold_medals and avg_gdp by country_id
SELECT w.country_id, 
SUM(gold) AS gold_medals,
AVG(gdp) AS	avg_gdp
FROM winter_games AS w
JOIN country_stats AS c
ON c.country_id=w.country_id
GROUP BY w.country_id;

-- see the total of the query
SELECT SUM(gold_medals)
FROM (
	SELECT w.country_id, 
	SUM(gold) AS gold_medals, 
	AVG(gdp) AS avg_gdp
	FROM winter_games AS w
	JOIN country_stats AS c
	ON c.country_id=w.country_id
	GROUP BY w.country_id
) AS subquery; 
-- the result is not the same as the first query (indicating there is a duplicate)
-- we will investigate it in the next query


-- fixing duplcicate
SELECT SUM(gold_medals) AS gold_medals
FROM
	(SELECT 
     	w.country_id, 
     	SUM(gold) AS gold_medals, 
     	AVG(gdp) AS avg_gdp
    FROM winter_games AS w
    JOIN country_stats AS c
    -- Update the subquery to join on a second field in year
	-- when we investigate it, we must also joining year
    ON c.country_id = w.country_id AND CAST(c.year AS date)=w.year
    GROUP BY w.country_id) AS subquery;


-- country with high medal rate 
SELECT LEFT(REPLACE(UPPER(TRIM(c.country)), '.',''),3) AS country_code,
pop_in_millions, 
SUM(COALESCE(gold, 0) + COALESCE(silver, 0) + COALESCE(bronze, 0)) AS medals,
SUM(COALESCE(gold, 0) + COALESCE(silver, 0) + COALESCE(bronze, 0)) /
CAST(pop_in_millions AS float) AS medals_per_million
FROM summer_games AS s
JOIN countries AS c
ON s.country_id=c.id
JOIN country_stats AS cs
ON c.id=cs.country_id AND s.year=CAST(cs.year AS date)
WHERE pop_in_millions IS NOT NULL
GROUP BY c.country, pop_in_millions
ORDER BY medals_per_million DESC
LIMIT 25;