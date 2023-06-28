/*
Covid 19 Data Exploration 

Skills used: 
	- Joins
	- CTE's
	- Temp Tables
	- Windows Functions
	- Aggregate Functions
	- Creating Views
	- Converting Data Types
*/



-- View all the columns/fields of the CovidDeaths table

SELECT *
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4



-- Data we are using from the CovidDeaths Table

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2



-- (Q1) Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS [Death Percentage]
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL -- AND location = 'United States' -- Delete the first two dashes(in front of the AND clause) 
-- to uncomment and search for a particular country. Make sure the country's name is in between the two apostrophes.
ORDER BY 1, 2



-- (Q2) Total Cases vs Population
-- Shows what percentage of the population contracted covid

SELECT location, date, population, total_cases, ((total_cases/population)*100) AS [Proportion that contracted COVID]
FROM Portfolio.dbo.CovidDeaths
-- WHERE location = 'United States'
ORDER BY 1, 2



-- (Q3) Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS [Highest Infection Count], (MAX((total_cases/population))*100) AS [Percent Population Infected]
FROM Portfolio.dbo.CovidDeaths
-- WHERE location = 'United States' 
GROUP BY location, population
ORDER BY [Percent Population Infected] DESC



-- (Q4) Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS [Total Death Count]
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY [Total Death Count] DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- (Q5) Continents with Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS [Total Death Count]
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY [Total Death Count] DESC



-- GLOBAL NUMBERS

-- (Q6) What is the proportion of people who died each day

SELECT date, SUM(new_cases) AS [Total Cases], SUM(CAST(new_deaths AS int)) AS [Total Deaths], (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS [Death Percentage]
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2



-- (Q7) Globally, what is the proportion of people who died altogether?

SELECT SUM(new_cases) AS [Total Cases], SUM(CAST(new_deaths AS int)) AS [Total Deaths], (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS [Death Percentage]
FROM Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- View all the columns/fields of the CovidVaccinations table
SELECT *
FROM Portfolio.dbo.CovidVaccinations



-- Joining the CovidDeaths and CovidVaccinations tables

SELECT *
FROM Portfolio.dbo.CovidDeaths AS deaths
JOIN Portfolio.dbo.CovidVaccinations AS vacc
	ON deaths.location = vacc.location AND deaths.date = vacc.date



-- (Q8) Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS [Rolling People Vaccinated]
FROM Portfolio.dbo.CovidDeaths AS deaths
JOIN Portfolio.dbo.CovidVaccinations AS vacc
	ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2, 3
-- NOTE: Can also use the CONVERT(data type to convert to, field) function


-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, [Rolling People Vaccinated])
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS [Rolling People Vaccinated]
FROM Portfolio.dbo.CovidDeaths AS deaths
JOIN Portfolio.dbo.CovidVaccinations AS vacc
	ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, ([Rolling People Vaccinated]/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated -- Making alterations to a temporary table/Prevents an error message
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
[Rolling People Vaccinated] numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS [Rolling People Vaccinated]
FROM Portfolio.dbo.CovidDeaths AS deaths
JOIN Portfolio.dbo.CovidVaccinations AS vacc
	ON deaths.location = vacc.location AND deaths.date = vacc.date
--WHERE deaths.continent IS NOT NULL

SELECT *, ([Rolling People Vaccinated]/Population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store date for later visualization (using Q8)

CREATE VIEW PercentPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS [Rolling People Vaccinated]
FROM Portfolio.dbo.CovidDeaths AS deaths
JOIN Portfolio.dbo.CovidVaccinations AS vacc
	ON deaths.location = vacc.location AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated

