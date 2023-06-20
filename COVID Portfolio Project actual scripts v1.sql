Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using

--Select Location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths$
--order by 1, 2


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where Location like '%Barbados%'
order by 1, 2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where Location like '%Barbados%'
order by 1, 2


-- Looking at the countries with highest infection rate compared to population

Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where Location like '%Barbados%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where Location like '%Barbados%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

