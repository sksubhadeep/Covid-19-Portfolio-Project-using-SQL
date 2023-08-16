--Viewing all the columns from CovidDeaths Table
select *
from PortFolioProject.dbo.CovidDeaths
order by 3,4
--------------------------------------------------------------------------------------------------------------------------
--Viewing all the columns from CovidVaccination Table
select *
from PortFolioProject.dbo.CovidVaccination
order by 3,4
--------------------------------------------------------------------------------------------------------------------------
--View specific columns from CovidDeaths Table
select location, date,total_cases,new_cases,total_deaths,population
from PortFolioProject.dbo.CovidDeaths
order by 1,2
--------------------------------------------------------------------------------------------------------------------------

--Looking at Total cases vs total Deaths as Percentage for all countries
--Shows Likelihood of dying if you contact of Covid in Canada

select location, date,total_cases,round((total_deaths/total_cases)*100,2) as DeathPercentage
from PortFolioProject.dbo.CovidDeaths
where  total_cases !=0 and location like 'canada%'
order by 1,2
--------------------------------------------------------------------------------------------------------------------------

--Looking at Total cases vs population as percentage in Canada
select location, date,total_cases,population,round((total_cases/population)*100,2) as PercentPopulationinfected
from PortFolioProject.dbo.CovidDeaths
where  total_cases !=0 and location like 'canada%'
order by 1,2
--------------------------------------------------------------------------------------------------------------------------

--Looking at countries with highest infection rates compared to population
select location, population,max(total_cases) as HighestInfectionCount,max(round((total_cases/population)*100,2)) as PercentPopulationInfected
from PortFolioProject.dbo.CovidDeaths
where  total_cases !=0 
group by location, population
order by PercentPopulationInfected desc
--------------------------------------------------------------------------------------------------------------------------
--Looking for countries with highest death count per population
select location,max(Total_Deaths) as TotalDeathCount
from PortFolioProject.dbo.CovidDeaths
where  total_cases !=0 and continent is not null
group by location
order by TotalDeathCount desc
--------------------------------------------------------------------------------------------------------------------------
--Looking for Continents with highest death count per population
select continent,max(Total_Deaths) as TotalDeathCount
from PortFolioProject.dbo.CovidDeaths
where  total_cases !=0 and continent is not null
group by continent
order by TotalDeathCount desc
--------------------------------------------------------------------------------------------------------------------------
--Looking for Global Numbers
select sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths,round((sum(new_deaths)/sum(new_cases))*100,2) as DeathPercentage
from PortFolioProject.dbo.CovidDeaths
where  new_cases !=0 and continent is not null
order by 1,2
--------------------------------------------------------------------------------------------------------------------------
--looking total Population vs vaccinations by joining two tables w.r.t Location and Date
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as RollingVaccinationCount
--(RollingVaccinationCount/d.population)*100
from PortFolioProject.dbo.CovidDeaths d
join PortFolioProject.dbo.CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null
order by 2,3

---------------------------------------------------------------------------------------------------------------------------
--looking total Population vs vaccinations by joining two tables w.r.t Location and Date and Using CTE
with PopvsVac (Continent,location,date,population,New_Vaccinations,RollingVaccinationCount)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as RollingVaccinationCount
from PortFolioProject.dbo.CovidDeaths d
join PortFolioProject.dbo.CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null)

select * ,(RollingVaccinationCount/population)*100 as RollingPercentage
from PopvsVac

--------------------------------------------------------------------------------
--TEMP Tables
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinationCount numeric
)

insert into #PercentagePopulationVaccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as RollingVaccinationCount
from PortFolioProject.dbo.CovidDeaths d
join PortFolioProject.dbo.CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null

select * ,(RollingVaccinationCount/population)*100 as RollingPercentage
from #PercentagePopulationVaccinated


------------------------------------------------------------------------------------------

--views
drop view if exists PercentagePopulationVaccinated


create view PercentagePopulationVaccinated as 
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as RollingVaccinationCount
from PortFolioProject.dbo.CovidDeaths d
join PortFolioProject.dbo.CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null and v.new_vaccinations is not null

select * from PercentagePopulationVaccinated
