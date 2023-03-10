--FRON COVID DEATHS TABLE

SELECT * 
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM CovidVaccinations$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total cases vs Total deaths
--Shows likelihood of dying from Covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location like '%canada%'
AND continent IS NOT NULL
ORDER BY 1,2

--Total cases vs Population
--Shows percentage of the population infected by covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentageInfected
FROM CovidDeaths$
WHERE location like '%canada%'
AND continent IS NOT NULL
ORDER BY 1,2

--Countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths$
--WHERE location like '%canada%'
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY 4 DESC

--Countries with highest death rate compared to population

SELECT location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM CovidDeaths$
--WHERE location like '%canada%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC


--Breaking down by Continent with highest death count

SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- Global numbers

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS float)) AS TotalDeaths, 
SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS TotalDeathPercentage
FROM CovidDeaths$
--WHERE location like '%canada%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



--JOINING COVID VACCINATION TABLE

SELECT * 
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date

--Looking at Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Using CTE

WITH PopVSVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 FROM PopVSVac


--Using TEMP TABLE

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO  #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW  PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated

