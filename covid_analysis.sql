SELECT *
FROM [Portfolio Project]..covid_deaths$
Where continent is not null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..covid_vaccinations$
--order by 3,4

-- SELECT Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..covid_deaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths

-- Shows likeihood of dying if you get covid in your country 
SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..covid_deaths$
order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of population got covid
SELECT Location, date, total_cases, total_deaths, population, (Total_cases/population)*100 as PercentPopulationIfected
FROM [Portfolio Project]..covid_deaths$
--WHERE Location like '%states%'
order by 1,2

-- looking for countries with highest infection rate compared to population
SELECT Location, population, MAX(Total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..covid_deaths$
--WHERE Location like '%states%'
Group By Location, population
order by PercentPopulationInfected desc

--showing counties with highest death count per population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..covid_deaths$
--WHERE Location like '%states%'
Where continent is not null
Group By Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..covid_deaths$
--WHERE Location like '%states%'
Where continent is null
Group By location
order by TotalDeathCount desc

-- Global 
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..covid_deaths$
--WHERE Location like '%states%'
Where continent is not null
Group By date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..covid_deaths$
--WHERE Location like '%states%'
Where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths$ dea
join [Portfolio Project]..covid_vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3

--use cte
With POPvsVAC (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths$ dea
join [Portfolio Project]..covid_vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM POPvsVAC

-- Temp table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..covid_deaths$ dea
join [Portfolio Project]..covid_vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated
