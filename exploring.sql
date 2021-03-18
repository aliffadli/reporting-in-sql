-- find top 3 most athlete represent
SELECT sport, COUNT(DISTINCT athlete_id) AS athletes 
FROM summer_games 
GROUP BY sport 
ORDER BY athletes DESC 
LIMIT 3; 


-- base report of a scatter plot of number of events and number of athletes 
SELECT sport, 
COUNT(DISTINCT event) AS events, 
COUNT(DISTINCT athlete_id) AS athletes 
FROM summer_games 
GROUP BY sport; 


-- the age of the oldest athlete for each region 
SELECT region, MAX(age) AS age_of_oldest_athlete
FROM athletes
JOIN summer_games 
ON athletes.id=summer_games.athlete_id 
JOIN countries 
ON summer_games.country_id=countries.id 
GROUP BY region;


-- select number of event in each sports

-- summer sports 
SELECT sport, COUNT(DISTINCT event) AS events 
FROM summer_games
GROUP BY sport 
UNION 
-- winter sports
SELECT sport, COUNT(DISTINCT event) AS events 
FROM winter_games 
GROUP BY sport 
ORDER BY events DESC; 


-- validating a bronze medals

-- see total bronze medals in summer_games
SELECT SUM(bronze) AS total_bronze_medals 
FROM summer_games; 

-- show bronze medals by country 
SELECT country, SUM(bronze) AS bronze_medals 
FROM summer_games AS s
JOIN countries AS c
ON s.country_id=c.id
GROUP BY country;

-- validate using subquery 
SELECT SUM(bronze_medals)
FROM (
SELECT country, SUM(bronze) AS bronze_medals 
	FROM summer_games AS s
	JOIN countries AS c
	ON s.country_id=c.id
	GROUP BY country
) AS subquery;
-- the result is the same with the first query 


-- see the most decorated summer athletes 
SELECT a.name AS athlete_name, 
COUNT(gold) AS gold_medals
FROM summer_games AS s
JOIN athletes AS a
ON s.athlete_id=a.id
GROUP BY a.name 
HAVING COUNT(gold) >= 3
ORDER BY gold_medals DESC; 