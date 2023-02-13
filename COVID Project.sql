--Analysis of COVID cases data in Europe

SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3 desc

SELECT count(iso_code)
from PortfolioProject..CovidVaccinations

--Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

--Convert data in total_cases and total_deaths from nvarchar(255) to float - this is requaired if your data are in nvarchar(255) if not just ignore this step
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases FLOAT
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths FLOAT
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN population FLOAT
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN new_cases FLOAT
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN new_deaths FLOAT

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Poland'
ORDER BY 1, 2

--Shows likelihood od dying if you contract covid per specific country
SELECT location, AVG((total_deaths/total_cases)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location
ORDER BY 1

--Looking at Total Cases vs Population
--Shows what percentage of population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Poland'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Poland'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Swowing Countries with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Poland'
GROUP BY location
ORDER BY TotalDeathCount desc

--Total number per Europe
SELECT  SUM(new_cases) AS 'TotalCases', SUM(new_deaths) AS 'Total_deaths', SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases) * 100 AS 'DeathsPercentage' 
FROM PortfolioProject..CovidDeaths


-- Lookin at Total Population vs Vaccinations
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS 'RollingPeopleVaccinated'
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	ORDER BY 1, 2, 3

-- USE CTE
WITH PopvsVac(location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	--ORDER BY 1, 2, 3
)

Select *, (RollingPeopleVaccinated/population)
From PopvsVac

