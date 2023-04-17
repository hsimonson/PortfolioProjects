-- Covid Data Exploration --
-- Written 4/15/2023 by Henry Simonson
-- Last updated 4/17/2023

-- Select data to be used in analysis
Select *
From [Portfolio Project]..CovidDeaths
order by 3,4

Select *
From [Portfolio Project]..CovidVaccinations
order by 3,4

---- COVID DEATH DATA EXPLORATION ----

-- GLOBAL NUMBERS --

-- #1 
-- Shows global total Covid infections and death percent
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/(SUM(new_cases)))*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null

-- #2
-- Shows the percentage of population that has died from Covid per day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- BREAKING DATA DOWN BY COUNTRY --

-- #3
-- Looking at total Covid cases vs total Covid deaths per country per day
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- #4
--Looking at total Covid cases vs total covid deaths per country as of 4/30/2021
Select Location, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by Location
order by 1,2

-- #5
-- Shows the running percentage of population that has died from Covid per country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- #6
-- Shows the running percentage of population that has died from Covid in the United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
Where location like '%state%' and continent is not null
order by 1,2

-- #7
-- Looking at total cases vs population.  Shows percent of population that was infected with Covid.
Select location, date, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Pop_Infected
From [Portfolio Project]..CovidDeaths
Where location not in ('World','European Union','International','Asia','Africa','Europe','North America','South America','Oceania')
Group by location, population, date
Order by 1,2

-- #8
-- Looking at countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Pop_Infected
From [Portfolio Project]..CovidDeaths
Where location not in ('World','European Union','International','Asia','Africa','Europe','North America','South America','Oceania')
Group by location, population
order by Percent_Pop_Infected desc

-- #9
-- Looking at countries with highest death count
Select Location, Population, MAX(cast(total_deaths as int)) as total_death_count
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by location, population
order by total_death_count desc

-- BREAKING DATA DOWN BY CONTINENT --

-- #10
-- Looking at total covid deaths by continent
Select location, SUM(cast(new_cases as int)) as death_count
From [Portfolio Project]..CovidDeaths
where continent is null
and location not in ('World','European Union','International')
Group by location
Order by death_count desc

---- COVID VACCINATION DATA EXPLORATION ----

-- BREAKING DOWN DATA BY COUNTRY --

-- #11
-- Looking at total population compared to vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Will be using two methods to insert population vs vaccination data into a usable table.

-- Method #1:
-- Using CTE (common_table_expression) to look at total population compared to vaccinations and the vaccination percent
With PopVsVac (Continent, Location, Date, Population, new_vaccinations, rolling_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (rolling_vaccinations/Population)*100 as percent_vac
From PopVsVac
Order by 2,3

-- Method #2:
-- Creating temp table to hold population vs vaccine data
USE [Portfolio Project]
GO
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_vaccinations numeric
)

-- Inserting population vs vaccination data into temp table
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (rolling_vaccinations/Population)*100 as percent_vac
From #PercentPopulationVaccinated
Order by 2,3

---- CREATING VIEWS TO STORE DATA FOR VISUALIZATION ----
USE [Portfolio Project]
GO
Drop View if exists GlobalDeathPercent
Drop View if exists GlobalDeathPercentByDate
Drop View if exists ContinentDeathCount
Drop View if exists DeathPercentByCountyAndDate
Drop View if exists HighestInfectionPercentByCountry
Drop View if exists InfectionPercentByCountryandDate

CREATE VIEW GlobalDeathPercent as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/(SUM(new_cases)))*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null

CREATE View GlobalDeathPercentByDate as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by date

Create View ContinentDeathCount as
Select location, SUM(cast(new_cases as int)) as death_count
From [Portfolio Project]..CovidDeaths
where continent is null
and location not in ('World','European Union','International')
Group by location

Create View DeathPercentByCountyAndDate as
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null

Create view HighestInfectionPercentByCountry as
Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Pop_Infected
From [Portfolio Project]..CovidDeaths
Where location not in ('World','European Union','International','Asia','Africa','Europe','North America','South America','Oceania')
Group by location, population

Create view InfectionPercentByCountryandDate as
Select location, date, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Pop_Infected
From [Portfolio Project]..CovidDeaths
Where location not in ('World','European Union','International','Asia','Africa','Europe','North America','South America','Oceania')
Group by location, population, date



