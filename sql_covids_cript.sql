USE sql_covid;

SELECT * FROM sql_covid.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- SELECT * FROM covidvaccinations
-- ORDER BY 3,4;

-- Select the data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE (continent IS NOT NULL AND location like '%fra%' )
ORDER BY 1, 2;

-- Looking at the Total cases vs Population
-- Shows percentage of population got covid
SELECT location, date, population, total_cases, 
(total_cases/population)*100 AS PercentPopulationInfected
FROM coviddeaths
-- WHERE location like '%fra%'
ORDER BY 1, 2;

-- Looking at Countries with the Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM coviddeaths
-- WHERE location like '%fra%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Highest Death Count per population

set sql_mode=''; 
alter table sql_covid.coviddeaths
change column total_deaths total_deaths int;

-- SELECT DeathByLocation.continent,
-- SUM(DeathByLocation.TotalDeathCount) AS TotalDeathCount
-- FROM (SELECT continent, location, MAX(total_deaths) AS TotalDeathCount
-- FROM coviddeaths 
-- WHERE continent IS NOT NULL
-- WHERE location like '%fra%'
-- GROUP BY location, continent) AS DeathByLocation
-- GROUP BY DeathByLocation.continet;

UPDATE coviddeaths
SET continent = 'Europe'
WHERE location = 'Europe';

SELECT continent, location
FROM coviddeaths
WHERE continent = 'NULL';

UPDATE coviddeaths
SET location = 'United States'
WHERE location = 'High income';

UPDATE coviddeaths
SET continent = 'North America'
WHERE continent = 'NULL';

UPDATE coviddeaths
SET continent = 'Europe'
WHERE location = 'Europe';

UPDATE coviddeaths
SET continent = 'Europe'
WHERE location = 'European Union';

UPDATE coviddeaths
SET continent = 'Africa'
WHERE location = 'Africa';

SELECT location, SUM(total_deaths) AS TotalDeathCount
FROM coviddeaths
-- WHERE location like '%fra%'
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Showing continents with the heighest death count per populat

CREATE VIEW death_by_country AS 
	SELECT continent, location,
    MAX(total_deaths) AS TotalDeathCount
    FROM coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY continent, location;

SELECT continent, SUM(TotalDeathCount) AS TotalDeathCount
FROM death_by_country
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers
SELECT  SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths,
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL  
-- WHERE location like '%fra%' 
-- GROUP BY date
ORDER BY  1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
 
 -- USE CTE
set sql_mode=''; 
alter table sql_covid.covidvaccinations
change column new_vaccinations new_vaccinations int;

WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
 AS
(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY
d.location, d.date) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM coviddeaths d
JOIN covidvaccinations v
	ON d.location = v.location AND
    d.date = v.date
WHERE d.continent IS NOT NULL)

SELECT* , (RollingPeopleVaccinated/population)*100 
FROM PopvsVac;

-- TEMP Table 
set sql_mode=''; 
alter table sql_covid.covidvaccinations
change column new_vaccinations new_vaccinations int;

-- DROP TABLE if exists #PercentPopulationVaccinated;
-- CREATE TABLE #PercentPopulationVaccinated
-- (
-- continent nvarchar(255),
-- location nvarchar(255),
-- date datetime,
-- population int,
-- new_vaccinations int,
-- RollingPeopleVaccinated int
-- );

-- INSERT INTO #PercentPopulationVaccinated

-- SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
-- SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)
-- FROM coviddeaths d
-- JOIN covidvaccinations v
	-- ON d.location = v.location AND
    -- d.date = v.date
-- WHERE d.continent IS NOT NULL

-- SELECT* , (RollingPeopleVaccinated/population)*100 
-- FROM #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY
d.location, d.date) AS RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM coviddeaths d
JOIN covidvaccinations v
	ON d.location = v.location AND
    d.date = v.date
WHERE  d.continent IS NOT NULL
