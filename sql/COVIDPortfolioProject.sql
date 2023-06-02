--COVID 19 Data Exploration

Select *
FROM "CovidDeaths"
WHERE continent is not null and continent != ''
ORDER BY 3,4;

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases::NUMERIC)*100 as DeathPercentage
FROM "CovidDeaths"
--Where location = 'Ukraine'
ORDER BY 1,2;


--Select data that I am going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM "CovidDeaths"
WHERE continent != ''
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract Covid my country

SELECT location, date, total_cases, total_deaths, (total_deaths::NUMERIC/total_cases)*100 as DeathPercentage
FROM "CovidDeaths"
WHERE location = 'Ukraine'
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths::NUMERIC/total_cases)*100 as DeathPercentage
FROM "CovidDeaths"
WHERE location = 'Ukraine'
ORDER BY 4 DESC;

--Total Cases vs Population
--Shows what percentage of the Population got Covid

SELECT location, date, population, total_cases, (total_cases::NUMERIC/population)*100 as percentOfPopulationInfected
FROM "CovidDeaths"
WHERE location = 'Ukraine'
ORDER BY 1,2;

--Looking at countries with the highest infection rate compared to the population 

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population::NUMERIC))*100 as PercentOfPopulationInfected
FROM "CovidDeaths"
GROUP BY location, population
ORDER BY 4 DESC;

--Showing countries with the highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount 
FROM "CovidDeaths"
WHERE continent != '' and total_deaths is not null
GROUP BY location
ORDER BY 2 DESC;

--Breaking things down by CONTINENT

--Showing continents with the highest death count per population 

SELECT location, population, MAX(total_deaths) as TotalDeathCount, MAX((total_deaths/population::NUMERIC))*100 as PercentOfPopulationDied
FROM "CovidDeaths"
WHERE continent = ''
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
ORDER BY 1,2;


--Looking at Total Population vs Vaccination 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM "CovidDeaths" dea
JOIN "CovidVaccinations" vac 
  ON dea.location = vac.location 
  and dea.date = vac.date::date 
Where dea.continent != '' --and dea.location = 'Ukraine'
ORDER BY 2,3
LIMIT 1000;

--Shows the percentage of the Population that has received at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     SUM(vac.new_vaccinations::integer) OVER (PARTITION BY dea.location)
FROM "CovidDeaths" dea
JOIN "CovidVaccinations" vac 
  ON dea.location = vac.location 
  and dea.date = vac.date::date 
Where dea.continent != '' --and dea.location = 'Ukraine'
ORDER BY 2,3
LIMIT 1000;

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
ORDER BY 2,3
LIMIT 1000
)
SELECT *, Round ((RollingPeopleVaccinated/population::NUMERIC)*100, 2) as VaccinatedPercentofPopulation
FROM PopVsVac;


--Creating a view to store data for later visualizations 

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