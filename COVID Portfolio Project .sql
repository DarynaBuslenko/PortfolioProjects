Select *
FROM "CovidDeaths"
WHERE continent is not null and continent != ''
ORDER BY 3,4;

Select *
FROM "CovidVaccinations"
WHERE continent is not null 
ORDER BY 3,4;

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM "CovidDeaths"
--Where location like '%states%'
--Group By date
ORDER BY 1,2;

--Select data that I am going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM "CovidDeaths"
ORDER BY 1,2;

--Looking at Total cases vs Total deaths 
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths::NUMERIC/total_cases)*100 as DeathPercentage
FROM "CovidDeaths"
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths::NUMERIC/total_cases)*100 as DeathPercentage
FROM "CovidDeaths"
WHERE date = '2020-03-22' and location = 'Afghanistan'
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths::NUMERIC/total_cases)*100 as DeathPercentage
FROM "CovidDeaths"
WHERE location = 'Ukraine'
ORDER BY 4 DESC;

--Total cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases::NUMERIC/population)*100 as percentOfPopulationInfected
FROM "CovidDeaths"
WHERE location = 'Ukraine'
ORDER BY 4;

--Looking at ountries with the highest infection rate compared to population 
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population::NUMERIC))*100 as PercentOfPopulationInfected
FROM "CovidDeaths"
WHERE continent is not null 
GROUP BY location, population
ORDER BY 4 DESC;

--Showing contries with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount FROM "CovidDeaths"
WHERE continent != '' and total_deaths is not null
GROUP BY location
ORDER BY 2 DESC;

--Let's break thigs down by CONTINENT
SELECT location, MAX(total_deaths) as TotalDeathCount 
FROM "CovidDeaths"
WHERE continent = '' and total_deaths is not null
GROUP BY 1
ORDER BY 2 DESC;

--Showing continents with the highest death count per population 
SELECT location, population, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population::NUMERIC))*100 as PercentOfPopulationDied
FROM "CovidDeaths"
WHERE continent = '' and total_deaths is not NULL
GROUP BY 1,2 
ORDER BY 3 DESC;

--GLOBAL numbers
SELECT date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, SUM(new_deaths)/SUM(new_cases::NUMERIC) * 100 as DeathPercentage
FROM "CovidDeaths"
WHERE continent != ''
GROUP BY 1
ORDER BY 1,2;

SELECT SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, SUM(new_deaths)/SUM(new_cases::NUMERIC) * 100 as DeathPercentage
FROM "CovidDeaths"
WHERE continent != ''
--GROUP BY 1
ORDER BY 1,2;


--Looking at total population vs vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM "CovidDeaths" dea
JOIN "CovidVaccinations" vac 
  ON dea.location = vac.location 
  and dea.date = vac.date::date 
Where dea.continent != '' --and dea.location = 'Ukraine'
ORDER BY 2,3
LIMIT 1000;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(vac.new_vaccinations::integer) OVER (PARTITION BY dea.location)
FROM "CovidDeaths" dea
JOIN "CovidVaccinations" vac 
  ON dea.location = vac.location 
  and dea.date = vac.date::date 
Where dea.continent != '' --and dea.location = 'Ukraine'
ORDER BY 2,3
LIMIT 1000;



Alter TABLE "CovidVaccinations"
ALTER COLUMN new_vaccinations TYPE NUMERIC(10,0) USING (trim(new_vaccinations)::NUMERIC);

SELECT new_vaccinations from "CovidVaccinations"
where new_vaccinations !='';

ALTER TABLE "CovidVaccinations" 
ALTER COLUMN new_vaccinations TYPE INT USING (cast ( coalesce( nullif( trim(new_vaccinations), '' ), '0' ) as integer ));


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(vac.new_vaccinations::integer) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM "CovidDeaths" dea
JOIN "CovidVaccinations" vac 
  ON dea.location = vac.location 
  and dea.date = vac.date::date 
Where dea.continent != '' --and dea.location = 'Ukraine'
ORDER BY 2,3
LIMIT 1000;

--Total Population vs Vaccinations, USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(vac.new_vaccinations::integer) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    -- ,(RollingPeopleVaccinated/population)*100
FROM "CovidDeaths" dea
JOIN "CovidVaccinations" vac 
  ON dea.location = vac.location 
  and dea.date = vac.date::date 
Where dea.continent != '' --and dea.location = 'Ukraine'
--ORDER BY 2,3
LIMIT 1000
)
SELECT *, Round ((RollingPeopleVaccinated/population::NUMERIC)*100, 2) as VaccinatedPercentofPopulation
FROM PopVsVac;


--Creating view to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(vac.new_vaccinations::integer) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    -- ,(RollingPeopleVaccinated/population)*100
FROM "CovidDeaths" dea
JOIN "CovidVaccinations" vac 
  ON dea.location = vac.location 
  and dea.date = vac.date::date 
Where dea.continent != '' --and dea.location = 'Ukraine'
--ORDER BY 2,3
LIMIT 1000