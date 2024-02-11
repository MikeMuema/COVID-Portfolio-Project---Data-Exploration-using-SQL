/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM [Covid_Deaths].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Covid_Deaths].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Covid_Deaths].[dbo].[CovidDeaths]
WHERE location like '%Kenya%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Covid_Deaths].[dbo].[CovidDeaths]
--WHERE location like '%Kenya%'
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM  [Covid_Deaths].[dbo].[CovidDeaths]
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

SELECT Location,Population, MAX(cast(Total_deaths as int)) as TotalDeathCount, MAX(cast(Total_deaths as int)/population)*100 as PercentDeathsperPopulation
FROM [Covid_Deaths].[dbo].[CovidDeaths]
--Where location like '%states%'
WHERE continent is not null 
GROUP BY Location, population
ORDER BY PercentDeathsperPopulation desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent,  MAX(Population) as Population, MAX(cast(Total_deaths as int)) as TotalDeathCount, MAX(cast(Total_deaths as int)/population)*100 as PercentDeathsperPopulation
FROM [Covid_Deaths].[dbo].[CovidDeaths]
--Where location like '%states%'
WHERE continent is not null 
GROUP BY continent
ORDER BY PercentDeathsperPopulation desc

-- GLOBAL STATISTICS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Covid_Deaths].[dbo].[CovidDeaths]
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER BY 1,2

-- Joining the CovidDeaths table with the CovidVaccination table

SELECT *
FROM [Covid_Deaths].[dbo].[CovidDeaths] dea
JOIN [Covid_Vaccinations].[dbo].[CovidVaccinations$] vac
     ON dea.location = vac.location
	 and dea.date = vac.date

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM [Covid_Deaths].[dbo].[CovidDeaths] dea
Join [Covid_Vaccinations].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


 -- Using CTE to calculate the percentage of the population that has recieved at least one Covid Vaccine

 WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM [Covid_Deaths].[dbo].[CovidDeaths] dea
JOIN [Covid_Vaccinations].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinatedPop
FROM PopvsVac

-- Using Temp Table to calculate the rolling percentage of the population vaccinated against COVID-19. 

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
From [Covid_Deaths].[dbo].[CovidDeaths] dea
JOIN [Covid_Vaccinations].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentPopVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM [Covid_Deaths].[dbo].[CovidDeaths] dea
JOIN [Covid_Vaccinations].[dbo].[CovidVaccinations$] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

