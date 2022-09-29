select *
from Covid_project..CovidDeaths
where continent is not null
order by location, date 

--select *
--from CovidDeaths
--order by location, date;


Select Location,date, total_cases, new_cases, total_deaths, population
from Covid_project..CovidDeaths
where continent is not null
order by 1,2;


--TOTAL CASES VS TOTAL DEATHS
-- Shows liklihood of dying if you contact covid in India
Select Location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Covid_project..CovidDeaths
where location='India'
and continent is not null
order by 1,2;

--Looking at Total cases vs population
Select Location,date, Population, total_cases,(total_cases/Population)*100 as CasePercentage
from Covid_project..CovidDeaths
where location='India'
and continent is not null
order by 1,2;

--Looking at Countries with highest infection rate compared to population
Select Location, Population, max(total_cases) as Highest_infection_count,max((total_cases/Population))*100 as percent_population_infected
from Covid_project..CovidDeaths
--where location='India'
where continent is not null
group by Location, Population
order by percent_population_infected desc


--Showing Countries with highest death count per population
Select Location,max(cast(total_deaths as int)) as highest_death_count
from Covid_project..CovidDeaths
--where location='India'
where continent is not null
group by Location
order by Highest_death_count desc


--Let's break this down by continent
Select continent,max(cast(total_deaths as int)) as highest_death_count
from Covid_project..CovidDeaths
--where location='India'
where continent is not null
group by continent
order by Highest_death_count desc

--Showing continents with the highest death count per population
Select Location,max(cast(total_deaths as int)) as highest_death_count
from Covid_project..CovidDeaths
--where location='India'
where continent is not null
group by Location
order by Highest_death_count desc


--Global numbers
Select sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Covid_project..CovidDeaths
--where location='India'
where continent is not null
--group by date
order by 1,2


--total_population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as roling_people_vaccinated
from Covid_project..coviddeaths dea
join 
Covid_project..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--use CTE
with popvsvac as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as roling_people_vaccinated
from Covid_project..coviddeaths dea
join 
Covid_project..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *, (roling_people_vaccinated/population)*100 as people_vaccinated_percentage
from popvsvac



--temp table
drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
continent nvarchar(255),
locatin nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
roling_people_vaccinated numeric
)

insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as roling_people_vaccinated
from Covid_project..coviddeaths dea
join 
Covid_project..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null

select *, (roling_people_vaccinated/population)*100 as people_vaccinated_percentage
from #percent_population_vaccinated



--creating view to store data for later visualisation
create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as roling_people_vaccinated
from Covid_project..coviddeaths dea
join 
Covid_project..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * 
from percent_population_vaccinated