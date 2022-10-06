Select * 
from PortfolioProject . . CovidDeaths$
order by 3,4

--Select the data to be used
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths$
Order By 3,4

--Looking at total_cases vs total_deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From  PortfolioProject.dbo.CovidDeaths$
Where location='Australia'
Order By 1,2 desc

--Looking at total_cases vs Population
--Shows what percentage of population got Covid
Select location, date, total_cases, Population, (total_cases/population)*100 CasesPercentage
From  PortfolioProject.dbo.CovidDeaths$
Where location='Australia'
Order By 1,2 desc

--What countries have the highest infection rate  compared to population?
Select location, date, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 AS PercentagePopulationInfected
From  PortfolioProject.dbo.CovidDeaths$
Group By location, date
order by PercentagePopulationInfected desc

--Showing the countries with the highest death count per population
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject.dbo.CovidDeaths$
where continent is not null
Group By location
Order By HighestDeathCount desc

--Showing the continents with the highest death count per population
Select Continent, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject.dbo.CovidDeaths$
where Continent is not null
Group By Continent
Order By HighestDeathCount Desc

--Showing global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths$
where continent is not null
--Group by Date
Order By 1,2 desc

--Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject . dbo. CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--Using CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject . dbo. CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
FROM PopvsVac

--Create temp table
--DROP Table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject . dbo. CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated

--Creating view to store data for later visualizations
Create view PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths$ dea
join PortfolioProject . dbo. CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

Select location,SUM(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is  null
and location not in ('World','European Union','International')
Group by location
Order by TotalDeathCount desc

Select location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, Population
order by PercentagePopulationInfected desc

Select location, Population, date, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, population,date
order by PercentPopulationInfected desc