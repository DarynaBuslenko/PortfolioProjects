
-- Let's take a look at the average annual budget of Paramount Pictures 

SELECT name, budget, year, company, 
       ROUND (avg (budget) OVER (PARTITION BY year ORDER BY year)) as AvgBudget
FROM movies
WHERE company = 'Paramount Pictures' AND budget IS NOT NULL;


-- I'd like to have the information on the maximum budgets that Paramount Pictures allocated for their movies in 2018, 2019, and 2020, along with the names of the respective films

SELECT name, year, company, budget, 
  MAX (budget) OVER (PARTITION BY year)
FROM movies
WHERE year in ('2019', '2020', '2018') and company = 'Paramount Pictures';


-- Let's check avg budget and avg gross for each company starting from the 2011 year

SELECT company, year, AVG (budget) as AvgBudget, AVG (gross) as AvgGros
FROM movies
WHERE budget IS NOT NULL and gross IS NOT NULL and year > 2010
GROUP BY company, year
ORDER BY year;
--graph here

-- Here we can see the highest and the lowest budgets among companies per year starting from 2016

SELECT company, budget, year, FIRST_VALUE (budget) OVER (PARTITION BY year ORDER BY budget DESC) AS highest_budget, 
LAST_VALUE(budget) OVER(PARTITION BY year ORDER BY budget DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as lowest_budget
FROM movies
WHERE budget is not null and year > 2015;

-- I would like to view information about movies that have a score of 8.5 or higher

SELECT name, company, year, budget, gross, score
FROM movies
WHERE score >= 8.5
ORDER BY score DESC;

-- The following list displays the top-ranked companies based on their gross from the years 2013-2015

WITH ranking AS (
SELECT company, name, gross, year, RANK () OVER (PARTITION BY company ORDER BY gross DESC) as rank
FROM movies)
SELECT company, name, gross, year
FROM ranking
WHERE rank = 1 and year BETWEEN 2013 and 2015
ORDER BY year;

-- Let's ranking movies by genre based on their average score

SELECT name, genre, AVG(score) as AvgScore,
  DENSE_RANK () OVER (PARTITION BY genre ORDER BY AVG(score) DESC)
FROM movies
WHERE score is not null and score > 8
GROUP BY name, genre;




