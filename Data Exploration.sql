-- OVERVIEW OF CovidDeath TABLE (Last Data: 23-June-2021)
SELECT *
FROM CovidProject..CovidDeath
--WHERE location LIKE 'Singapore'
ORDER BY 3,4 

-- OVERVIEW OF CovidVac TABLE (Last Data: 23-June-2021)
SELECT *
FROM CovidProject..CovidVac
--WHERE location LIKE 'Singapore'
ORDER BY 3,4 DESC

---
---
---
-- TOTAL INFECTED % OF POPULATION PER DAY, DESCENDING: SG
SELECT 
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 AS "Infected%"
FROM CovidProject..CovidDeath
WHERE location LIKE 'Singapore'
ORDER BY date DESC

-- TOTAL INFECTED % BY POPULATION OF COUNTRY: GLOBAL
SELECT 
	location, 
	population, 
	max(total_cases) as Total_Cases, 
	max(total_cases/population)*100 AS "Total_Infected%"
FROM CovidProject..CovidDeath
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY location, population

-- TOTAL INFECTED % BY CONTINENT
SELECT 
	location, 
	population, 
	max(total_cases) as Total_Cases, 
	max(total_cases/population)*100 AS "Total_Infected%"
FROM CovidProject..CovidDeath
WHERE continent IS null AND location NOT LIKE 'International'
GROUP BY location, population
ORDER BY location, population


-- DEATH PERCENTAGE PER DAY OF TOTAL CASES, DESCENDING: SINGAPORE
SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS "Death%"
FROM CovidProject..CovidDeath
WHERE location LIKE 'Singapore'
ORDER BY date DESC

-- TOTAL DEATH COUNT PER POPULATION OF COUNTRY: GLOBAL
SELECT 
	location,
	max(cast(total_deaths as int)) AS Total_Death
FROM CovidProject..CovidDeath
WHERE continent IS NOT null
GROUP BY location
ORDER BY location

-- TOTAL DEATH COUNT BY CONTINENT
SELECT
	location,
	max(cast(total_deaths as int)) AS Total_Death
FROM CovidProject..CovidDeath
WHERE continent IS null AND location NOT LIKE 'International'
GROUP BY location



/*

CovidVac Dataset:

PERCENTAGE OF POPULATION THAT IS FULLY VACCINATED (2 DOSES) PER DAY: SINGAPORE

*/

-- #1: Using CTE:
---
;
WITH VacOfPop_Full 
(
	continent,
	location,
	date,
	population,
	vaccinated_full
)
AS
(
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	max(CONVERT(int,vac.people_fully_vaccinated)) 
		OVER (PARTITION BY dea.location
			ORDER BY dea.location, dea.date) AS vaccinated_full
FROM CovidProject..CovidDeath AS dea
JOIN CovidProject..CovidVac as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT null 
AND dea.location LIKE 'Singapore'
)
SELECT 
	*, 
	(vaccinated_full/population)*100 AS "Vac%"
FROM VacOfPop_Full 
ORDER BY 2,3 DESC


---
-- #2: Using Create Temp Table:
---
DROP TABLE IF EXISTS #PercentagePopulationVacFull
CREATE TABLE #PercentagePopulationVacFull
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
vaccinated_full numeric,
)
INSERT INTO #PercentagePopulationVacFull
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	max(CONVERT(int,vac.people_fully_vaccinated)) 
		OVER (PARTITION BY dea.location
			ORDER BY dea.location, dea.date) AS vaccinated_full
FROM CovidProject..CovidDeath AS dea
JOIN CovidProject..CovidVac as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT null 
AND dea.location LIKE 'Singapore'
SELECT 
	*, 
	(vaccinated_full/population)*100 AS "Vac%"
FROM #PercentagePopulationVacFull
ORDER BY 2,3 DESC


---
-- #3: Create View for Data Viz
---
USE CovidProject
DROP VIEW IF EXISTS PercentagePopulationVacFull
GO
CREATE VIEW PercentagePopulationVacFull AS
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	max(CONVERT(int,vac.people_fully_vaccinated)) 
		OVER (PARTITION BY dea.location
			ORDER BY dea.location, dea.date) AS vaccinated_full
FROM CovidProject..CovidDeath AS dea
JOIN CovidProject..CovidVac as vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT null 
AND dea.location LIKE 'Singapore'
