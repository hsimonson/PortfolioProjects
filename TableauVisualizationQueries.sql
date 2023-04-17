-- Covid Data Visualization Queries --
-- Written 4/17/2023 by Henry Simonson
-- Last updated 4/17/2023

-- #1
-- Shows global total Covid infections and death percent
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/(SUM(new_cases)))*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null

-- #2
-- Shows global total Covid infections and death percent by date
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by date
Order by 1

-- #3
-- Looking at total covid deaths by continent
Select location, SUM(cast(new_cases as int)) as death_count
From [Portfolio Project]..CovidDeaths
where continent is null
and location not in ('World','European Union','International')
Group by location
Order by death_count desc

-- #4
-- Looking at death percent by country and date
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null
Order by 1,2

-- #5
-- Looking at countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Pop_Infected
From [Portfolio Project]..CovidDeaths
Where location not in ('World','European Union','International','Asia','Africa','Europe','North America','South America','Oceania')
Group by location, population
order by Percent_Pop_Infected desc

-- #6
-- Looking at total cases vs population by country and date.  Shows percent of population that was infected with Covid.
Select location, date, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Pop_Infected
From [Portfolio Project]..CovidDeaths
Where location not in ('World','European Union','International','Asia','Africa','Europe','North America','South America','Oceania')
Group by location, population, date
Order by 1,2

