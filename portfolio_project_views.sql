select Location, date, total_cases,total_deaths,population
from [dbo].[deathdata$]
order by 1,2

-- Total Cases vs Total Deaths

select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100
as Deathpercentage
from [dbo].[deathdata$]
where location = 'India'
order by 1,2

-- Looking at total cases vs Population
-- Shows what percentage of population got Covid

select Location, date, total_cases,population,(total_cases/population)*100
as Deathpercentage
from [dbo].[deathdata$]
where location = 'India'
order by 1,2

--Looking at countries with highest infection rate vs population

Select Location,Population,MAX(total_cases) as highinfection, MAX((total_cases/population))*100 as percentpopulation
from [dbo].[deathdata$]
group by location,population
order by percentpopulation desc

-- Showing highes deaths

Select Location, MAX(cast(total_deaths as int)) as totaldeaths
from [dbo].[deathdata$]
where continent is not null
group by location
order by totaldeaths desc

--LET'S BREAK THINGS BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as totaldeaths
from [dbo].[deathdata$]
where continent is NOT null
group by continent
order by totaldeaths desc

-- CORRECT NUMBERS

Select continent, MAX(cast(total_deaths as int)) as totaldeaths
from [dbo].[deathdata$]
where continent is not null
group by continent
order by totaldeaths desc

--Showing the continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as totaldeaths
from [dbo].[deathdata$]
where continent is not null
group by continent
order by totaldeaths desc

--Global count

Select date,SUM(new_cases) as newColumn,SUM(cast(new_deaths as int)) as deathcolumn
from [dbo].[deathdata$]
where continent is not null
group by date
order by 1,2

select date, SUM(new_cases) as newcases,SUM(cast(new_deaths as int)) as deathcases, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from [dbo].[deathdata$]
where continent is not null
group by date
order by 1,2 

--New Table(Joining)

Select dea.continent,dea.date,dea.population,vac.new_vaccinations
from [dbo].[Covid_vaccination$] vac
join [dbo].[deathdata$] dea
on dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null
order by 2,3

--Partition by location

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as int)) over (Partition by dea.location)
from [dbo].[Covid_vaccination$] vac
join [dbo].[deathdata$] dea
on dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null
order by 2,3

--Prtition by location and date

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as rollingcount
from [dbo].[Covid_vaccination$] vac
join [dbo].[deathdata$] dea
on dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null
order by 2,3

--Looking at Total Population vs Vaccinations(CTE)

With popvsvac(continent,location,date,population,new_vaccination,rollingcount)
as
(Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) 
as rollingcount
from [dbo].[Covid_vaccination$] vac
join [dbo].[deathdata$] dea
on dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null)
select *, (rollingcount/population)*100 as percentage
from popvsvac

--creating VIEW

Create view percentagepopvaccination as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as rollingcount
from [dbo].[Covid_vaccination$] vac
join [dbo].[deathdata$] dea
on dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null

Create view rollingcount as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location,dea.date) as rollingcount
from [dbo].[Covid_vaccination$] vac
join [dbo].[deathdata$] dea
on dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null

create view deathpercentage as
select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100
as Deathpercentage
from [dbo].[deathdata$]
where location = 'India'

create view locationpartition as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(Cast(vac.new_vaccinations as int)) over (Partition by dea.location) as new_vaccination
from [dbo].[Covid_vaccination$] vac
join [dbo].[deathdata$] dea
on dea.location = vac.location 
and 
dea.date = vac.date
where dea.continent is not null

