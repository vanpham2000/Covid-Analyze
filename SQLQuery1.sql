select* 
from PorfolioProject..CovidDeath

select* 
from PorfolioProject..CovidVaccination


Select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeath
order by 1,2

--Looking at the Total cases vs total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentDeathRate
from PorfolioProject..CovidDeath
where location LIKE '%%'
order by 1,2

-- looking at the total cases vs the population
--  show percent that got covid
Select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as percentPopGotCovid
from PorfolioProject..CovidDeath
order by 6 DESC

-- Looking at the Countries with Highest Infection Rate compared to Population
Select location, population ,max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as percentPopGotCovid
from PorfolioProject..CovidDeath
group by population, location
order by 4 DESC

-- Looking for Countries with the highest Death Count per Population
Select location,max(cast(total_deaths as int)) as totalDeathCount
from PorfolioProject..CovidDeath
where continent is not null
group by  Location
order by totalDeathCount DESC

-- showing the continent with highest death count  
Select continent,max(cast(total_deaths as int)) as totalDeathCount
from PorfolioProject..CovidDeath
where continent is not null
group by continent
order by totalDeathCount DESC

-- GLOBAL NUMBERS
Select  SUM(new_cases) as newcase, SUM(new_deaths) as newdeath, 
case
	When SUM(new_deaths) <> 0 then (SUM(new_deaths)/sum(new_cases)) * 100
	else null
end as deathPercent
from PorfolioProject..CovidDeath
where continent is not null 
--group by location
order by deathPercent DESC

--Looking at Total Population
Select VD.continent, VD.location, VD.date, VD.population, VA.new_vaccinations
from PorfolioProject..CovidDeath as VD
join PorfolioProject..CovidVaccination as VA
on VD.location = VA.location and VD.date = VA.date
where VD.continent is not null
order by 2,3


--Looking at Total Population
Select VD.continent, VD.location, VD.date, VD.population, VA.new_vaccinations,
SUM(VA.new_vaccinations) over (partition by VD.location order by VD.location, VD.date)
from PorfolioProject..CovidDeath as VD
join PorfolioProject..CovidVaccination as VA
on VD.location = VA.location and VD.date = VA.date
where VD.continent is not null
order by 2,3

--Looking at Total population vs total vaccination
Select VD.continent, VD.location, VD.date, VD.population, VA.new_vaccinations,
SUM(VA.new_vaccinations) over (partition by VD.location order by VD.location, VD.date) as PeopleVAC,
from PorfolioProject..CovidDeath as VD
join PorfolioProject..CovidVaccination as VA
on VD.location = VA.location and VD.date = VA.date
where VD.continent is not null
order by 2,3


-- use CTE

with PopvsVac(continent, Location, date, Population, PeopleVAC, new_vaccinations)
as
(
Select VD.continent, VD.location, VD.date, VD.population, VA.new_vaccinations,
SUM(VA.new_vaccinations) over (partition by VD.location order by VD.location, VD.date) as PeopleVAC
from PorfolioProject..CovidDeath as VD
join PorfolioProject..CovidVaccination as VA
on VD.location = VA.location and VD.date = VA.date
where VD.continent is not null
)

select *, (PeopleVAC / Population) * 100 as PercentC
from  PopvsVac

-- temp table
drop table if exists #PercentPopulationVaccination
Create Table #PercentPopulationVaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime ,
Population numeric,
new_vaccination numeric,
PeopleVAC numeric
)
Insert into #PercentPopulationVaccination
Select VD.continent, VD.location, VD.date, VD.population, VA.new_vaccinations,
SUM(VA.new_vaccinations) over (partition by VD.location order by VD.location, VD.date) as PeopleVAC
from PorfolioProject..CovidDeath as VD
join PorfolioProject..CovidVaccination as VA
on VD.location = VA.location and VD.date = VA.date
where VD.continent is not null

select*
from #PercentPopulationVaccination

-- creating view for tableau
USE PorfolioProject
GO
create view PercentPopulationVaccination as
Select VD.continent, VD.location, VD.date, VD.population, VA.new_vaccinations,
SUM(VA.new_vaccinations) over (partition by VD.location order by VD.location, VD.date) as PeopleVAC
from PorfolioProject..CovidDeath as VD
join PorfolioProject..CovidVaccination as VA
on VD.location = VA.location and VD.date = VA.date
where VD.continent is not null

drop view PercentPopulationVaccination

select* 
from #PercentPopulationVaccination