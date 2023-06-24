/* 
	Creator: Jamaal G. N Clarke
	
	Dataset: Covid 19 Data Exploration from website https://ourworldindata.org/covid-deaths 

	Skills used Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Create Views, Converting Data Types

*/

Select * 
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
Where continent is not null
order by 3,4

-- Select the data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
Where continent is not null
order by 1, 2


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where Location like '%Barbados%'
and continent is not null
order by 1, 2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where Location like '%Barbados%'
and continent is not null
order by 1, 2


-- Looking at the countries with highest infection rate compared to population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where Location like '%Barbados%'
--and continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where Location like '%Barbados%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Let's break this down by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where Location like '%Barbados%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Displaying the continents with the highest death count

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%Barbados%'
where continent is not null
Group by continent
Order by TotalDeathCount asc


 -- Global Numbers

 Select date, SUM(new_cases), SUM(cast(new_deaths as int))--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
 --where location like '%Barbados%'
 where continent is not null
 Group by date
 order by 1,2


  Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
 --where location like '%Barbados%'
 where continent is not null
 Group by date
 order by 1,2

   Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
 --where location like '%Barbados%'
 where continent is not null
 Group by date
 order by 1,2


    Select SUM(new_cases) as total_cases, SUM(CONVERT(int, new_deaths)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
 --where location like '%Barbados%'
 where continent is not null
 --Group by date
 order by 1,2

 -- Looking at Total Population vs Vaccinations

 Select * 
 From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vac
 On dea.location = vac.location
 and dea.date = vac.date


 Select dea.continent, dea.location, dea.date, dea.population
 From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location)
 From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vac ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
order by 2,3


 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vac ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3
) 
Select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac


-- TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) 
 as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
 From PortfolioProject..CovidDeaths$ dea
 Join PortfolioProject..CovidVaccinations$ vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated

