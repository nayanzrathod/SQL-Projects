-- Covid19 data exploration 
-- Skills Used : Converting Data Types, Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views

-- copy data 

CREATE TABLE covid_deaths
LIKE coviddeaths;

INSERT covid_deaths
SELECT * FROM coviddeaths;

SELECT * FROM covid_deaths;

SELECT * FROM covidvaccinations;

CREATE TABLE covid_vaccinations
LIKE covidvaccinations;

INSERT covid_vaccinations
SELECT * FROM covidvaccinations;

SELECT * FROM covid_vaccinations;

SELECT * 
FROM covid_deaths
WHERE continent IS NOT NULL;


-- Select data



SELECT location, `date`, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, `date` ASC
;


-- Change data type 

UPDATE covid_deaths
SET `date` = str_to_date(`date`,'%d-%m-%Y');

ALTER TABLE covid_deaths
MODIFY COLUMN `date` date;

UPDATE covid_deaths
SET total_deaths = total_deaths + 0;

ALTER TABLE covid_deaths
MODIFY COLUMN total_deaths INT ;

SELECT * 
FROM covid_vaccinations;

UPDATE covid_vaccinations
SET `date` = str_to_date(`date`, '%d-%m-%Y');

ALTER TABLE covid_vaccinations
MODIFY COLUMN `date` date; 


-- Check for duplicates

SELECT location, `date`, total_cases, total_deaths, population, 
ROW_NUMBER() OVER (
Partition By location, `date`, total_cases, total_deaths, population) AS row_num
FROM covid_deaths
;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Total deaths vs Total cases

SELECT distinct location, `date`, total_cases, total_deaths, ROUND(total_deaths/total_cases*100,2) AS death_percentage
FROM covid_deaths
WHERE location LIKE '%Bhutan%'
ORDER BY 2;

-- Total cases vs Total population

SELECT distinct location, `date`, total_cases, population, ROUND(total_cases/population*100,2) AS percentage_population_infected
FROM covid_deaths
WHERE location LIKE '%Bhutan%'
ORDER BY 2;

-- Countries with Highest infection rate compared to population 

SELECT location, MAX(total_cases) AS Highest_infected_cases, MAX((total_cases/population))*100 AS Max_infected_percentage
FROM covid_deaths
GROUP BY location
ORDER BY Max_infected_percentage DESC;

-- Countries with Highest Death Count per Population

SELECT location, population, MAX((total_deaths/population))*100 AS Max_death_percentage
FROM covid_deaths
GROUP BY location, population
ORDER BY Max_death_percentage DESC;

-- Showing contintents with the highest death count per population

SELECT continent, MAX(total_deaths) AS Highestdeathcount
FROM covid_deaths
GROUP BY continent
ORDER BY Highestdeathcount DESC;

-- GLOBAL NUMBERS

SELECT date, continent, location, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, round(SUM(new_deaths/new_cases),2) AS total_death_rate
FROM covid_deaths
WHERE new_cases >0 AND new_deaths >0
GROUP BY date, continent, location
ORDER BY total_death_rate DESC;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.date AS deathdate, dea.location AS loc, vac.new_vaccinations AS new_vaccines, 
SUM(vac.new_vaccinations) OVER( Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date
;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, date, location, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.date AS deathdate, dea.location AS loc, dea.population, vac.new_vaccinations AS new_vaccines, 
SUM(vac.new_vaccinations) OVER( Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date
)
SELECT *, Round((RollingPeopleVaccinated/population)*100,2)
FROM PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query


Create TABLE #PercentPoplulationVaccinated
(
continent varchar(255)
location varchar(255)
date datetime
population numeric
new_vaccinations numeric
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPoplulationVaccinated
SELECT dea.continent, dea.date AS deathdate, dea.location AS loc, dea.population, vac.new_vaccinations AS new_vaccines, 
SUM(vac.new_vaccinations) OVER( Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY dea.location, dea.date
)
SELECT *, Round((RollingPeopleVaccinated/population)*100,2)
FROM #PercentPoplulationVaccinated;



-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated AS
SELECT dea.continent, dea.date AS deathdate, dea.location AS loc, dea.population, vac.new_vaccinations AS new_vaccines, 
SUM(vac.new_vaccinations) OVER( Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid_deaths AS dea
JOIN covid_vaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null;