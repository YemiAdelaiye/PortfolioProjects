use PortfolioProject

SELECT id, Location, date, total_cases, new_cases, total_deaths,population 
FROM PortfolioProject.covid_deaths



-- Looking at Total Cases vs Total Death --
-- Shows likelihood of dying if you contract covid in your country (ex. Belgium) --

SELECT id, Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathercentage
FROM PortfolioProject.covid_deaths
where location like '%Belgium'



-- Looking at Total Cases vs Population --
-- Shows what percentage of Population got covid) --
SELECT population, Location, date, total_cases, (total_cases/population)*100 as Percentage_Population_Infected
FROM PortfolioProject.covid_deaths
where location like '%Belgium'



-- Looking at countries with the Highest Infection Rate compared to Population --

SELECT
    Location,
    Population,
    continent,
    MAX(total_cases) AS Highest_infection_Count,
    ROUND((MAX(total_cases) / Population) * 100, 1) AS Percentage_Population_Infected
FROM PortfolioProject.covid_deaths
WHERE continent IS NOT NULL
GROUP BY Location, Population, continent
ORDER BY Percentage_Population_Infected DESC;



-- Showing the Countries with the Highest Death Count per Population --

SELECT continent, MAX(total_deaths) AS Total_Death_Count 
FROM PortfolioProject.covid_deaths
where continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC;



--  BREAK THINGS DOWN BY CONTINENT --

SELECT continent, MAX(total_deaths) AS Total_Death_Count 
FROM PortfolioProject.covid_deaths
where continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC;



-- Global Numbers --

SELECT date, SUM(new_cases)as TotalCases, SUM(CAST(new_deaths AS SIGNED)) AS TotalDeaths, (SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases)) * 100 AS Deathpercentage
FROM PortfolioProject.covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2



-- Looking at Total Population vs Vaccinations -- 


WITH VaccinationSums AS (
    SELECT
        location,
        SUM(new_vaccinations) AS TotalNewVaccinations
    FROM PortfolioProject.covid_vaccination
    GROUP BY location
)

SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    vs.TotalNewVaccinations
FROM PortfolioProject.covid_deaths dea
JOIN PortfolioProject.covid_vaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
JOIN VaccinationSums vs
    ON dea.location = vs.location
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


-- USE CTE--

WITH VaccinationSums AS (
    SELECT
        location,
        SUM(new_vaccinations) AS TotalNewVaccinations
    FROM PortfolioProject.covid_vaccination
    GROUP BY location
)

, PopvsVac AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations AS New_Vaccination,
        vs.TotalNewVaccinations
    FROM PortfolioProject.covid_deaths dea
    JOIN PortfolioProject.covid_vaccination vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    JOIN VaccinationSums vs
        ON dea.location = vs.location
    WHERE dea.continent IS NOT NULL
    ORDER BY dea.location, dea.date
)

SELECT *, (TotalNewVaccinations/population)*100 FROM PopvsVac;



-- TEMP TABLE --

-- Creating a table for storing the sum of new_vaccinations by location
-- Disable safe update mode for the current session
SET SQL_SAFE_UPDATES = 0;

CREATE TEMPORARY TABLE VaccinationSums AS
SELECT
    location,
    SUM(new_vaccinations) AS TotalNewVaccinations
FROM PortfolioProject.covid_vaccination
GROUP BY location;

-- Create a new table for the final results
CREATE TEMPORARY TABLE NewVaccinationPopulation AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations AS New_Vaccination,
    vs.TotalNewVaccinations
FROM PortfolioProject.covid_deaths dea
JOIN PortfolioProject.covid_vaccination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
JOIN VaccinationSums vs
    ON dea.location = vs.location
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;

-- Calculate the percentage column
ALTER TABLE NewVaccinationPopulation
ADD COLUMN Percentage NUMERIC;

UPDATE NewVaccinationPopulation
SET Percentage = (TotalNewVaccinations / population) * 100;

-- Re-enable safe update mode for the current session
SET SQL_SAFE_UPDATES = 1;

-- Display the final results
SELECT * FROM NewVaccinationPopulation;




-- Creating view to store data for later visualizations --

create view TotalDeathsbyContinent as

SELECT continent, MAX(total_deaths) AS Total_Death_Count 
FROM PortfolioProject.covid_deaths
where continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC;


  






