use Covid
-- SELECCIONANDO LA DATA QUE USAREMOS EN EL PROYECTO 

Select Location, date, total_cases,new_cases,total_deaths,population
From Covid..CovidDeaths
Order by 1,2


-- FILTRAREMOS EL TOTAL DE CASOS VS EL TOTAL DE MUERTES (porcentaje de muerte en relacion a los infectados)
-- Se muestra que tan probable es que muera una persona si se infectaba en relacion a su pais 

Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS 'Porcentaje de muerte'
From Covid..CovidDeaths
Where Location like '%states'
Order by 1,2

--FILTRANDO A LOS PAISES CON MAYOR TASA DE INFECCION EN RELACION A LA POBLACION
Select location, population, MAX(total_cases) as 'Cantidad de casos',max((total_cases/population))*100 as 'Porcentaje de poblacion infectada'
From Covid..CovidDeaths
Group by location,population
Order By [Porcentaje de poblacion infectada] desc


--FILTRANDO LOS PAISES CON MAYORES FALLECIMIENTOS EN RELACION A LA POBLACION
Select location, MAX(cast(total_deaths as int)) as 'Cantidad de fallecimientos'
From Covid..CovidDeaths
where continent is not null
Group by location
Order By [Cantidad de fallecimientos] desc

--- ORDENANDO POR CONTINENTE	

----FILTRANDO LOS CONTINENTES CON MAYORES FALLECIMIENTOS EN RELACION A LA POBLACION
Select continent, MAX(cast(total_deaths as int)) as 'Cantidad de fallecimientos'
From Covid..CovidDeaths
where continent is not null
Group by continent
Order By [Cantidad de fallecimientos] desc





-- DATOS GLOBALES
Select sum(new_cases) 'casos totales',sum(cast(new_deaths as int)) as 'total de muertes'
,sum(cast(new_deaths as int))/sum(new_cases)*100 as 'Porcentaje de muerte'
From Covid..CovidDeaths
--Where location like '%states'
where continent is not null 
order by 1,2


--FILTRANDO EL TOTAL DE POBLACION CON LA CANTIDAD VACUNADA	

With POBVSVAC (continent,location,date,population,new_vaccinations,personasvacunadas)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER(partition by dea.location,dea.date) as personasvacunadas
from Covid..CovidDeaths dea
join CovidVaccinations vac	
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 
)
Select*,(personasvacunadas/population)*100
From POBVSVAC


--TABLAS TEMPORALES
Drop table if exists #PorcentajePoblacionVacunada
Create table #PorcentajePoblacionVacunada 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
personasvacunadas numeric
)

Insert into #PorcentajePoblacionVacunada
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER(partition by dea.location,dea.date) as personasvacunadas
from Covid..CovidDeaths dea
join CovidVaccinations vac	
	on dea.location=vac.location
	and dea.date=vac.date
Select*,(personasvacunadas/population)*100
From #PorcentajePoblacionVacunada


--CREANDO VISTA PARA GUARDAR LA DATA PARA LA VISUALIZACION

Create view PorcentajePoblacionVacunada as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER(partition by dea.location,dea.date) as personasvacunadas
from Covid..CovidDeaths dea
join CovidVaccinations vac	
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null 

