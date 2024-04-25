/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Creating Table, Windows Functions, Aggregate Functions, Creating Views

*/

SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Select Data that we are going to be starting with
SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE location LIKE 'Phil%'
AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS percent_population_infected
FROM covid_deaths
WHERE location LIKE 'Phil%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT
	location,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX((total_cases/population))*100 AS percent_population_infected
FROM covid_deaths
GROUP BY location,population
ORDER BY percent_population_infected DESC;



-- Countries with Highest Death Count per Population
SELECT
	location,
	MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
SELECT
	continent,
	MAX(total_deaths) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

-- GLOBAL NUMBERS
SELECT
	SUM(new_cases) AS total_cases, 
	SUM(new_deaths) AS total_deaths,
	SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac 
	(continent,location,date,population,new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location= vac.location
	AND dea.date= vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,
	(rolling_people_vaccinated/population)*100 AS percent_population_vaccinated
FROM PopvsVac;

-- Using Table to perform Calculation on Partition By in previous query
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
	continent varchar(255),
	location varchar(255),
	date date,
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;

SELECT *,
	(rolling_people_vaccinated / population) * 100 AS percent_population_vaccinated
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW Percent_Population_Vaccinated AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
