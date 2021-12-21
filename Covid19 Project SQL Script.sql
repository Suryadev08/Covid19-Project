/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT 
* FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4


-- Delete location name Upper middle Income, Low Income, High Income

DELETE FROM CovidDeaths WHERE location ='Upper middle income'


--1--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--2--Looking at Total deaths vs Total cases
--Shows likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths,ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--3--Looking at Total cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS Infection_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


--4--Looking at country with highest Infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection, MAX(ROUND((total_cases/population)*100,2)) AS Infection_Percentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Infection_Percentage DESC


--5--Looking at country with highest Death rate percentage compared to population

SELECT location, population, MAX(cast(total_deaths as int)) AS Highest_death, MAX(ROUND((total_deaths/population)*100,2)) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY location, population
ORDER BY Death_Percentage DESC


--6--Showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

--7--Shwoing the continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

--8--Total deaths per cases in world

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
Where continent is not null
ORDER BY 1,2

--9--Total death per cases on specific date in world

SELECT date,SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
--10-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3 


--11--Looking at total Population vs total Vaccinations Per day

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
ORDER BY 2,3


--12--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS PeopleVaccinatedPercentage FROM PopvsVac



--13-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE if exists #PercentPopulationVaccinated
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
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
--Where dea.continent is not null
--ORDER BY 2,3

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS PeopleVaccinatedPercentage 
FROM #PercentPopulationVaccinated





--14-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3


  SELECT * FROM PercentPopulationVaccinated