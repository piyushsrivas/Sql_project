select *
FROM PortfolioProject..CovidDeaths$
order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations$
--order by 3,4

select location , date ,
 total_cases, new_cases, total_deaths, population
 from PortfolioProject..CovidDeaths$

 order by 1,2


 select location , date ,
 total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths$
  where location like  'India%'
 order by 1,2



 select location , date ,population,
 total_cases, (total_cases/population)*100 as totalcases_per_population
 from PortfolioProject..CovidDeaths$
 where location like  'India%'
 order by 1,2



 select location , population,
 Max(total_cases) as highestInfectedcount, Max((total_cases/population))*100 as totalcases_per_population
 from PortfolioProject..CovidDeaths$
 --where location like  'India%'
 group by location , population
 order by totalcases_per_population desc



 select location,
 Max(cast(total_deaths as int)) as TotalDeathsCase 
 from PortfolioProject..CovidDeaths$
 --where location like  'India%'
 where continent is not null 
 group by location
 order by TotalDeathsCase 
 desc



  select location,
 Max(cast(total_deaths as int)) as TotalDeathsCase 
 from PortfolioProject..CovidDeaths$
 --where location like  'India%'
 where continent is  null 
 group by location
 order by TotalDeathsCase 
 desc



 select *
 from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vacc
   on dea.location = vacc.location
    and dea.date = vacc.date
    


	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
