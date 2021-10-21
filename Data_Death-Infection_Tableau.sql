/*

Queries used to obtain data for Tableau data visualization

*/

-- 1. Death Percentage

SELECT 
	SUM(new_cases) AS TotalCases,
	SUM(CONVERT(INT,new_deaths)) AS TotalDeathCount,
	SUM(CONVERT(INT,new_deaths))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeath
WHERE continent IS NOT null
--AND location LIKE 'Singapore'
ORDER BY 1,2



-- 2. Death Count per Continent

SELECT 
	location,
	SUM(CONVERT(INT,new_deaths)) AS TotalDeathCount
FROM CovidProject..CovidDeath
WHERE continent IS null
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC



-- 3. Infected Percentage of Population by Continent

SELECT 
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX(total_cases/population)*100 AS InfectedPercentage
FROM CovidProject..CovidDeath
WHERE continent IS null
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location, population
ORDER BY InfectedPercentage DESC



-- 4. Infected Percentage of Population by Countries

SELECT 
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX(total_cases/population)*100 AS InfectedPercentage
FROM CovidProject..CovidDeath
GROUP BY location, population
ORDER BY InfectedPercentage DESC



-- 5. Infected Percentage of Population by Countries per day 
-- (Last data: 30-Jun-2021)

SELECT 
	location,
	population,
	date,
	MAX(total_cases) AS HighestInfectionCount,
	MAX(total_cases/population)*100 AS InfectedPercentage
FROM CovidProject..CovidDeath
GROUP BY location, population, date
ORDER BY InfectedPercentage DESC