select *
from PortfolioProject..CovidDeaths
where continent is not null


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1, 2


--looking at Total Cases vs Total Deaths
--this shows likelihood of dying if you contract covid in my country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'nigeri%'
order by 1, 2;

--Looking fot Total cases vs population
--This shows percentage of population that got covid
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercent
from PortfolioProject..CovidDeaths
order by 1, 2;


--Looking at countries with the highest infection rate count
select location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercent
from PortfolioProject..CovidDeaths
GROUP BY location, population
order by CovidPercent desc;

--showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
order by Total_Death_Count desc;

--showing continent with highest death count per population
select continent, max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
order by Total_Death_Count desc;

--global numbers
select date, sum(new_cases), sum(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY date
order by 1,2;


--looking at total population versus vaccination
select Dea.continent, Dea.location, Dea.date, population, Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.Date) as RollingPeopleVaccination
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccines Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3;

--use CTE to get the rollingpeoleVaccination versus population

with PopvsVac (continet, location, date, population, new_vaccinations, RollingPeopleVaccination)
as (
select Dea.continent, Dea.location, Dea.date, population, Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.Date) as RollingPeopleVaccination, (
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccines Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
)

select *, (RollingPeopleVaccination/population)*100 as RollingPeoplePercent
from PopvsVac;



--Temp table
DROP TABLE if exists #percentRollingPeople
create table #percentRollingPeople
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric
)

insert into #percentRollingPeople
select Dea.continent, Dea.location, Dea.date, population, Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.Date) as RollingPeopleVaccination
--,(RollingPeopleVaccination/population)*100 
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccines Vac
on Dea.location = Vac.Location
and Dea.date = Vac.Date
where Dea.continent is not null


select *, (RollingPeopleVaccination/population)*100 as RollingPeoplePercent
from #percentRollingPeople;


--creating views for visualization
create view percentRollingPeople as 
select Dea.continent, Dea.location, Dea.date, population, Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.Date) as RollingPeopleVaccination
from PortfolioProject..CovidDeaths Dea
join PortfolioProject..CovidVaccines Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3;
