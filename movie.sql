CREATE DATABASE movie;

USE movie;

SHOW TABLES FROM movie;

SELECT * FROM movies

SELECT DISTINCT genre FROM movies;
SELECT COUNT(DISTINCT genre) FROM movies;

SELECT name,genre FROM movies 
WHERE genre LIKE 'Action' OR genre LIKE 'Adventure' OR genre LIKE 'Thriller'

SELECT year FROM movies;
SELECT COUNT(DISTINCT year) FROM movies;
SELECT DISTINCT year FROM movies;

/* Find Out Highest Grossing Movies in Each Year */
/*SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY','')); */
/* SELECT @@GLOBAL.sql_mode; */

/* Highest Grossers Year Wise */
SELECT year, name, MAX(gross) AS highest_grosser
FROM movies
GROUP BY year;

/* Most Critically Acclaimed films Year Wise */
SELECT year, name, MAX(score) AS best_review
FROM movies
GROUP BY year;

ALTER TABLE movies ADD COLUMN profit DECIMAL(15,2) DEFAULT 0;
UPDATE movies SET profit = gross - budget;

/* Find Out Highest Profit Movies in Each Year */
SELECT year, name, MAX(profit) AS highest_profit
FROM movies
GROUP BY year;

/*Which stars have given HGOTY each year */
SELECT year,star,name,MAX(gross) as HGOTY
FROM movies
GROUP BY year
ORDER BY year;

SELECT DISTINCT company FROM movies;
SELECT COUNT(DISTINCT company) FROM movies;

SELECT DISTINCT star FROM movies
ORDER BY star;
SELECT COUNT(DISTINCT star) FROM movies;

/* Which Production House has the highest Gross collection overall? */
SELECT company,AVG(gross)
FROM movies
GROUP BY company
ORDER BY AVG(gross) DESC;

/* Which actors have given most no of HGOTY? */
CREATE TABLE HGOTY
AS
SELECT year,star,name,MAX(gross) as HGOTY
FROM movies
GROUP BY year
ORDER BY year;

SELECT * FROM HGOTY

SELECT star,COUNT(*) AS num_HGOTY
FROM HGOTY
GROUP BY star
ORDER BY num_HGOTY DESC 

/* WHich genre has collected highest profit? */
SELECT genre,SUM(profit)
FROM movies
GROUP BY genre
ORDER BY SUM(profit) DESC;

/* Which Director has highest profit average wise? */
SELECT director,AVG(profit)
FROM movies
GROUP BY director
ORDER BY AVG(profit) DESC;

/* Show the most expensive movies */
SELECT name,budget,director,year
FROM movies
GROUP BY name
ORDER BY budget DESC;

/* Show the most expensive movies each year*/
SELECT year,MAX(budget),name,director
FROM movies
GROUP BY year
ORDER BY year DESC;

/* Most profitable actor-director duo? */
SELECT star,director,SUM(profit)
FROM movies
GROUP BY star,director
ORDER BY SUM(profit) DESC;

/* Most profitable actor-genre combo? */
SELECT star,genre,SUM(profit)
FROM movies
GROUP BY star,genre
ORDER BY SUM(profit) DESC;

/* Which actors have most no of Movies? */
SELECT star,COUNT(*) as num_movies
FROM movies
GROUP BY star
ORDER BY num_movies DESC;

/* Check data of Sylvester Stallone */
CREATE TABLE SLY
AS
SELECT * FROM movies
WHERE star = 'Sylvester Stallone';
SELECT * FROM SLY

/* Highest profit movies of Stallone? */
SELECT name,profit FROM SLY
ORDER BY profit DESC; 
/* Critically acclaimed movies of stallone */
SELECT name,score FROM SLY
ORDER BY score DESC;
/* Does Stallone have any HGOTY? */
SELECT * FROM HGOTY
WHERE star = "Sylvester Stallone";

SELECT * FROM movies
WHERE star= 'Leonardo DiCaprio';

/* Does Di Caprio have any HGOTY? */
SELECT * FROM HGOTY
WHERE star = "Leonardo DiCaprio";

/* Let's check country wise */
SELECT DISTINCT(country) FROM movies
ORDER BY country;
SELECT COUNT(DISTINCT country) FROM movies;
SELECT country,COUNT(*) as num_coun
FROM movies
GROUP BY country
ORDER BY num_coun DESC;

/* Let's Check Indian Movies */
SELECT * FROM movies
WHERE country = "India";

SELECT * FROM movies
WHERE budget = 0;

SELECT name,score,
CASE
	WHEN score>=7.5 THEN "VERY GOOD"
    WHEN score>=6 AND score<7.5 THEN "GOOD"
    WHEN score>=5 AND score<6 THEN "AVERAGE"
    ELSE "POOR"
END AS one_word_review
FROM movies;

/* WHich country gave highest grosser every year? */
SELECT year,country,name,MAX(gross)
FROM movies
GROUP BY year;