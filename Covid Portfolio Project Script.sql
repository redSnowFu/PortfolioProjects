select * from PortfolioProject..CovidDeaths 
where continent is not null
order by 3, 4
--select * from PortfolioProject..CovidVaccinations order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Canada%'
order by 1, 2

--looking at total cases vs population
--show that percentage of population got covid
select location, date, total_cases, population, (total_deaths/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%Canada%'
order by 1, 2

--looking at countries with highest infectionrate compare to population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_deaths/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- showing countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--break things down by continent
--showing continent with the highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null and location not like '%income%'
Group by location
order by TotalDeathCount desc

--global numbers everyday
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date)  as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
order by 2, 3

--first option, use cte
With PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date)  as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



--another option, temp table
drop table if exists #PercentPopulationvaccinated
create table #PercentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationvaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date)  as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationvaccinated


-- creating view to store data for later visualizations 
Create View PercentPopulationvaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date)  as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationvaccinated

