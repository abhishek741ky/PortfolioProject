select *
from Portfolio..CD
order by 3,4

--Select *
--from Portfolio..CV
--order by 3,4

--select data which we are going to use
select location,date,total_cases,new_cases,total_deaths,population
from Portfolio..CD
order by 1,2

--looking for total cases vs total deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CD
order by 1,2

--wrt to location
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CD
where location like '%states%'
order by 1,2


--highest infection rate
select location,Population,MAX(total_cases)as HighestInfectionCount, max(total_cases/population)*100 as PercentageHIC
from Portfolio..CD
group by location,Population
order by PercentageHIC  



--highest deathcount as per countries
select location,MAX(cast(total_deaths as int)) as HDC
From Portfolio..CD
where continent is not null
group by location
order by HDC desc

--showing continents with highest deathcount
--w.r.t to continent
select continent,MAX(cast(total_deaths as int)) as HighestDeathCount
From Portfolio..CD
where continent is not null
group by continent
order by HighestDeathCount desc


--global numbers
select date,SUM(new_cases) as totalcases,SUM(cast(new_deaths as int))as totaldeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio..CD
where continent is not null
group by date
order by DeathPercentage desc  

--use cte

with PopVsVac(continent,location,date,population,new_vaccinations,Vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location,dea.Date) as Vaccinated
from Portfolio..CD dea
join Portfolio..CV vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 
)
select*,(Vaccinated/population)*100 as vc
from PopVsVac

--temp table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Vaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location ,dea.Date) as Vaccinated
from Portfolio..CD dea
join Portfolio..CV vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3 

select*,(Vaccinated/population)*100 as vc
from #PercentPopulationVaccinated




--creating view for visualization

Create view PercentPopulationaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location ,dea.Date) as Vaccinated
from Portfolio..CD dea
join Portfolio..CV vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 



