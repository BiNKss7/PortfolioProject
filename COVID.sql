SELECT *
FROM PortfolioProject..CovidDeaths
--Where continent is not null
ORDER BY 3,4

-- SELECT *
-- FROM PortfolioProject..CovidVaccinations
-- ORDER BY 3,4

--To select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Looking at the total cases vs total deaths
-- Looking at the percentage of death for infected people
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nepal%'
ORDER BY 1, 2


-- Looking at the total_cases vs population

SELECT location, date, total_cases, population, (total_cases/population) * 100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Nepal%'
ORDER BY 1, 2

--Looking at the country with the highest rate of infection
SELECT location, population, max(total_cases) as Highest_Infection_Count, MAX(total_cases/population) * 100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE InfectedPercentage like '%Nepal%'
GROUP BY population, location
ORDER BY PercentPopulationInfected desc

-- Loooking at highest rate of deaths
SELECT location, max(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
ORDER BY Total_Death_Count desc

-- lets break things down by continent

--Showing the continent with the highest death count per population

SELECT continent, max(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc

-- Global Numbers
-- Total new cases globally each day
SELECT sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) * 100 as DeathPercent
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Nepal%'
where continent is not null
-- group by date
ORDER BY 1, 2

--Looking ate total population vs vaccinations using CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,
dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location= vac.location 
	and dea.date= vac.date
where dea.continent is not null
--order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/ Population) * 100 as Vaccinated_Percentage
from PopvsVac


-- Using Temp Table
Drop table if exists #Percent_Vaccinated
CREATE TABLE #Percent_Vaccinated
( 
continent nvarchar(255),
location nvarchar(255) ,
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #Percent_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,
dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location= vac.location 
	and dea.date= vac.date
where dea.continent is not null
--order by 2, 3

SELECT *, (RollingPeopleVaccinated/ Population) * 100 as Vaccinated_Percentage
from #Percent_Vaccinated


-- Crating view to store data for later visualization

CREATE View	PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location,
dea.date) as  RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location= vac.location 
	and dea.date= vac.date
where dea.continent is not null
--order by 2, 3

SELECT *
FROM PercentPopulationVaccinated