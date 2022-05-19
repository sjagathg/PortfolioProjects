select *
from PortfolioProject..['CovidDeaths$']
order by 3,4

--select *
--from PortfolioProject..['CovidVaccinations$']
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['CovidDeaths$']
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.. ['CovidDeaths$']
where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population

select location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.. ['CovidDeaths$']
-- where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population

select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.. ['CovidDeaths$']
-- where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.. ['CovidDeaths$']
-- where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- Let's Break things down by continent

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject.. ['CovidDeaths$']
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..['CovidDeaths$']
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from PortfolioProject..['CovidDeaths$']
-- Where location like '%states%'
where continent is not null
-- group by date
order by 1,2

with PopvsVac(continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths$'] dea
join PortfolioProject..['CovidVaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/Population)*100
from PopvsVac

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths$'] dea
join PortfolioProject..['CovidVaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths$'] dea
join PortfolioProject..['CovidVaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/Population)*100
from PopvsVac

Create view #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated,
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths$'] dea
join PortfolioProject..['CovidVaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3