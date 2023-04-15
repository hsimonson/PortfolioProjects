-- Covid Data Exploration --
-- Written 4/15/2023 by Henry Simonson

-- Select data to be used in analysis
Select *
From [Portfolio Project]..CovidDeaths
order by 3,4

Select *
From [Portfolio Project]..CovidVaccinations
order by 3,4

-- BREAKING DATA DOWN BY COUNTRY
-- Looking at total Covid cases vs total Covid deaths per country
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Shows the percentage of population that has died from Covid per country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- Shows the percentage of population that has died from Covid in the United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
Where location like '%state%' and continent is not null
order by 1,2

-- Looking at total cases vs population in the United States.  Shows percent of population that was infected with Covid.
Select Location, date, total_cases, population, (total_cases/population)*100 as infection_percent
From [Portfolio Project]..CovidDeaths
Where location like '%state%' and continent is not null
order by 1,2

-- Looking at countries with the highest infection rate compared to population
Select Location, Population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_pop_infected
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by location, population
order by percent_pop_infected desc

-- Looking at countries with highest death count
Select Location, Population, MAX(cast(total_deaths as int)) as total_death_count
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by location, population
order by total_death_count desc

-- BREAKING DATA DOWN BY CONTINENT
-- Looking at continents with highest death count
Select continent, MAX(cast(total_deaths as int)) as total_death_count
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by continent
order by total_death_count desc

-- GLOBAL NUMBERS
-- Shows the percentage of population that has died from Covid per day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percent
From [Portfolio Project]..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Looking at total population compared to vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Using CTE (common_table_expression)
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

-- TEMP TABLE
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

-- Inserting population vs vaccination data into tmep table
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

--Creating view to store data for visualizations
USE [Portfolio Project]
GO
CREATE View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

