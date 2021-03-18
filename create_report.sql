-- find event attended by each country in each season 
SELECT 'summer' AS season, 
country, COUNT(DISTINCT event) AS events
FROM summer_games AS s
JOIN countries AS c
ON s.country_id=c.id
GROUP BY country
UNION ALL 
SELECT 'winter' AS season, 
country, COUNT(DISTINCT event) AS events
FROM winter_games AS w
JOIN countries AS c
ON w.country_id=c.id
GROUP BY country
ORDER BY events DESC;


-- find event attended by each country in each season 
-- using union then join query
SELECT season, country, COUNT(DISTINCT event) AS events
FROM 
	(SELECT 'summer' AS season, 
	country_id, event 
	FROM summer_games 
	UNION ALL 
	SELECT 'winter' AS season, 
	country_id, event 
	FROM winter_games) AS subquery
JOIN countries AS c 
ON c.id=subquery.country_id
-- when using this approach we must group it using season too 
GROUP BY country, season
ORDER BY events DESC;


-- create a segments in athlete tables
-- there are three segments: Tall Female, Tall Male, Other
-- Tall Female: a female that is at least 175 centimeters tall 
-- Tall Male: a male that is at least 190 centimeters tall
-- Other: other than the two categories 
SELECT name, 
CASE WHEN height>=175 AND gender='F' THEN 'Tall Female'
WHEN height >= 190 AND gender='M' THEN 'Tall Male'
ELSE 'Other' END AS segment
FROM athletes;


-- understand how BMI differs by each summer sports 
SELECT sport, 
CASE WHEN 100*weight/POWER(height,2) < 0.25 THEN '<.25'
WHEN 100*weight/POWER(height,2) BETWEEN 0.25 AND 0.3 THEN '.25-.30'
WHEN 100*weight/POWER(height,2) > 0.3 THEN '>.30' END AS bmi_bucket,
COUNT(DISTINCT athlete_id) AS athletes
FROM summer_games AS s 
JOIN athletes AS a
ON s.athlete_id=a.id
GROUP BY sport, bmi_bucket
ORDER BY sport, athletes DESC;
-- this result will indicate that there are some null statement. 
-- lets investigate it in future query


-- troubleshooting CASE statement 
-- show height, weight, and bmi where bmi is null values for all athletes
SELECT height, weight, weight/height^2*100 AS bmi
FROM athletes 
WHERE weight/height^2*100 IS NULL;
-- as you can see from the result, there are numerous null weight values
-- this will calculate null bmi values 


-- revise the case statement query 
SELECT sport, 
CASE WHEN weight/height^2*100 <.25 THEN '<.25'
WHEN weight/height^2*100 <=.30 THEN '.25-.30'
WHEN weight/height^2*100 >.30 THEN '>.30'
ELSE 'no weight recorded' END AS bmi_bucket, 
COUNT(DISTINCT athlete_id) AS athletes
FROM summer_games AS s
JOIN athletes AS a
ON s.athlete_id=a.id
GROUP BY sport, bmi_bucket
ORDER BY sport, athletes DESC;


-- count the total number of medals with atletes age 16 or under 
SELECT COUNT(bronze) AS bronze_medals, 
COUNT(silver) AS silver_medals, 
COUNT(gold) AS gold_medals
FROM summer_games AS s
JOIN athletes AS a 
ON s.athlete_id=a.id
WHERE a.age<=16


-- count the total number of medals with atletes age 16 or under 
-- with subquery technique
SELECT COUNT(bronze) AS bronze_medals,
COUNT(silver) AS silver_medals, 
COUNT(gold) AS gold_medals
FROM summer_games 
WHERE athlete_id IN 
	(SELECT id
	FROM athletes
	WHERE age<=16)


-- top athletes in nobel-prized countries 
SELECT event, 
CASE WHEN event LIKE '%Women%' THEN 'female'
ELSE 'male' END AS gender, 
COUNT(DISTINCT athlete_id) AS athletes
FROM summer_games
WHERE country_id IN 
	(
	SELECT country_id
	FROM country_stats
	WHERE nobel_prize_winners > 0
	)
GROUP BY event
ORDER BY COUNT(DISTINCT athlete_id);
UNION
SELECT event, 
CASE WHEN event LIKE '%Women%' THEN 'female'
ELSE 'male' END AS gender, 
COUNT(DISTINCT athlete_id) AS athletes
FROM winter_games
WHERE country_id IN 
 	(
 	SELECT country_id
 	FROM country_stats
 	WHERE nobel_prize_winners > 0
 	)
GROUP BY event
ORDER BY athletes DESC 
LIMIT 10; 