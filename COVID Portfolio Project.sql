Select *
From PortfolioProjects..CovidDeaths
Where continent is not Null
Order by 3,4

Select *
From PortfolioProjects..CovidVaccinations
Order by 3,4 

-- Select Data that we are going to be using 

Select location
,date
,total_cases
,new_cases
,total_deaths
,population
From PortfolioProjects..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- => Show likelihood of dying if you contract covid in your country
Select location
,date
,total_cases
,total_deaths
,(total_deaths/total_cases)*100 as DeathPercentage

From PortfolioProjects..CovidDeaths
Where location like 'Vietnam'
Order by 1,2

-- Looking at Total Cases and Population
-- Show what percentage of population got Covid
Select location
,date
,population
,total_cases
,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
Where location like 'Vietnam'
Order by 1,2

-- Looking at Counries with Highest Infection Rate compared to Population
Select location
,population
,Max(total_cases) as HighestInfectionCount
,Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
Group by location
,population
--Where location like 'Vietnam'
Order by PercentPopulationInfected desc


--BREAKING THINGS DOWN BY CONTINENTS
-- Showing Countries with Highest Death Count per Population
Select location
,Max(cast((total_deaths) as int)) as TotalDeathCount
--,Max(total_deaths/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
Where  continent is not null
Group by location
Order by TotalDeathCount desc


-- Showing continents with highest death count per population
Select continent
,Max(cast((total_deaths) as int)) as TotalDeathCount
--,Max(total_deaths/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select date
,sum(new_cases) as total_cases
,sum(cast((new_deaths) as int)) as total_deaths
,SUM(cast((new_deaths) as int))/sum(new_cases)*100 as DeathPercentage 
--,total_deaths
--,(total_cases/population)*100 
From PortfolioProjects..CovidDeaths
-- Where location like 'Vietnam'
where continent is not null
Group by date
Order by 1,2

Select sum(new_cases) as total_cases
,sum(cast((new_deaths) as int)) as total_deaths
,SUM(cast((new_deaths) as int))/sum(new_cases)*100 as DeathPercentage 
--,total_deaths
--,(total_cases/population)*100 
From PortfolioProjects..CovidDeaths
-- Where location like 'Vietnam'
where continent is not null
-- Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select Deaths.continent
,Deaths.location
,Deaths.date
,Deaths.population
,Vaccine.new_vaccinations
,SUM(cast((Vaccine.new_vaccinations) as int)) over (Partition by Deaths.Location order by Deaths.Location, Deaths.Date) as RollingPeopleVaccinated
--,Vaccine.total_vaccinations
--(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths as Deaths
Join PortfolioProjects..CovidVaccinations as Vaccine
	on Deaths.location = Vaccine.location
	and Deaths.date = Vaccine.date
Where Deaths.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE

Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255)
, Location nvarchar(255)
, Date datetime
, Population numeric
, New_vaccinations numeric
, RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select Deaths.continent
,Deaths.location
,Deaths.date
,Deaths.population
,Vaccine.new_vaccinations
,SUM(cast((Vaccine.new_vaccinations) as int)) over (Partition by Deaths.Location order by Deaths.Location, Deaths.Date) as RollingPeopleVaccinated
--,Vaccine.total_vaccinations
--(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths as Deaths
Join PortfolioProjects..CovidVaccinations as Vaccine
	on Deaths.location = Vaccine.location
	and Deaths.date = Vaccine.date
Where Deaths.continent is not null
--Order by 2,3

Select *
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select Deaths.continent
,Deaths.location
,Deaths.date
,Deaths.population
,Vaccine.new_vaccinations
,SUM(cast((Vaccine.new_vaccinations) as int)) over (Partition by Deaths.Location order by Deaths.Location, Deaths.Date) as RollingPeopleVaccinated
--,Vaccine.total_vaccinations
--(RollingPeopleVaccinated/population)*100
From PortfolioProjects..CovidDeaths as Deaths
Join PortfolioProjects..CovidVaccinations as Vaccine
	on Deaths.location = Vaccine.location
	and Deaths.date = Vaccine.date
Where Deaths.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated