/* Data Source-https://ourworldindata.org/covid-deaths */

USE covid_data;
/* Display all the rows of each table */
SELECT 
    *
FROM
    covid_vaccines;
SELECT 
    *
FROM
    covid_deaths;

/* Display continent-wise total covid cases */
SELECT 
    continent, SUM(total_cases) AS continent_wise_total_cases
FROM
    covid_deaths
WHERE
    continent != ''
GROUP BY 1;

/* Display continent-wise total deaths */
SELECT 
    continent, SUM(total_deaths) AS continent_wise_total_deaths
FROM
    covid_deaths
WHERE
    continent != ''
GROUP BY 1;

/*Display country-wise death rates */
SELECT 
    location,
    date_time,
    total_cases AS total_case_count,
    total_deaths AS total_death_count,
    (total_deaths / total_cases) * 100 AS death_rate
FROM
    covid_deaths
GROUP BY 1
HAVING death_rate IS NOT NULL;

/*Display date-wise death rates in India */
SELECT 
    location,
    date_time,
    total_cases AS total_case_count,
    total_deaths AS total_death_count,
    (total_deaths / total_cases) * 100 AS death_rate
FROM
    covid_deaths
WHERE
    location LIKE '%India%'
GROUP BY 1 , 2
HAVING death_rate IS NOT NULL;

/*Display what percentage of population is infected with covid in India */
SELECT 
    location,
    population,
    MAX(CAST(total_cases AS SIGNED)) AS total_infected,
    (MAX(CAST(total_cases AS SIGNED)) / population) * 100 AS perc_population_covid_infected
FROM
    covid_deaths
WHERE
    location LIKE '%India'
GROUP BY 1 , 2;

/*Display what percentage of population is infected with covid in each country */
SELECT 
    location,
    population,
    MAX(CAST(total_cases AS SIGNED)) AS total_infected,
    (MAX(CAST(total_cases AS SIGNED)) / population) * 100 AS perc_population_covid_infected
FROM
    covid_deaths
GROUP BY 1 , 2
ORDER BY 4 DESC;

/* Display countries with the highest death counts
After a little exploration I came across that in location the continent name is mentioned and it is aggregrating
over that, so we will exclude those where the continent name is blank */
SELECT 
    location, MAX(CAST(total_deaths AS SIGNED)) AS total_deaths
FROM
    covid_deaths
WHERE
    continent != ''
GROUP BY 1
ORDER BY 2 DESC;

/* Display the daily death percentage worldwide */
SELECT 
    date_time,
    SUM(CAST(new_cases AS SIGNED)) AS cases_per_day,
    SUM(CAST(new_deaths AS SIGNED)) AS deaths_per_day,
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(CAST(new_cases AS SIGNED))) * 100 AS per_day_death_percentage
FROM
    covid_deaths
WHERE
    continent != ''
GROUP BY date_time
ORDER BY 2 DESC;

/* Display the total death percentage worldwide */
SELECT 
    SUM(CAST(new_cases AS SIGNED)) AS cases_per_day,
    SUM(CAST(new_deaths AS SIGNED)) AS deaths_per_day,
    (SUM(CAST(new_deaths AS SIGNED)) / SUM(CAST(new_cases AS SIGNED))) * 100 AS per_day_death_percentage
FROM
    covid_deaths
WHERE
    continent != ''
ORDER BY 2 DESC;

/* Joining the two tables */
SELECT 
    *
FROM
    covid_deaths cd
        JOIN
    covid_vaccines cv ON cd.date_time = cv.date_time;

/* Display country wise % of population fully vaccinated */
SELECT 
    cv.location AS country,
    cd.population AS total_population,
    (MAX(CAST(cv.people_fully_vaccinated AS SIGNED)) / cd.population) * 100 AS total_vaccinations
FROM
    covid_deaths cd
        JOIN
    covid_vaccines cv ON cd.date_time = cv.date_time
        AND cd.location = cv.location
WHERE
    cd.continent != ''
GROUP BY 1;

/* Display country wise total population vs vaccinations
Shows number of people in each country who has recieved at least one Covid Vaccine */

Select cd.continent, cd.location, cd.date_time, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS SIGNED))
OVER (Partition By cd.location order by cd.location, cd.date_time) as total_people_vaccinated FROM
    covid_deaths cd
        JOIN
    covid_vaccines cv ON cd.date_time = cv.date_time
        AND cd.location = cv.location
WHERE
    cd.continent != ''
ORDER BY 2,3;


/* Display country wise percentage of people who received atleast one dose */
With perc_pop_vac (continent, location, date_time, population, new_vaccinations, total_people_vaccinated)
As
(Select cd.continent, cd.location, cd.date_time, cd.population, cv.new_vaccinations, SUM(CAST(cv.new_vaccinations AS SIGNED))
OVER (Partition By cd.location order by cd.location, cd.date_time) as total_people_vaccinated FROM
    covid_deaths cd
        JOIN
    covid_vaccines cv ON cd.date_time = cv.date_time
        AND cd.location = cv.location
WHERE
    cd.continent != '')
Select *, (total_people_vaccinated/population)*100 as perc_people_vaccinated from perc_pop_vac;


/* Display the countrywise total tests conducted */
Select continent, location, date_time, new_tests, SUM(CAST(new_tests AS SIGNED))
OVER (Partition By location order by location, date_time) as total_tests FROM
covid_vaccines WHERE
continent != '';

/*Display daily covid positivity rates in India */
SELECT 
    cd.location,
    cd.date_time,
    cd.new_cases AS case_count,
    cv.new_tests AS test_count,
    (cd.new_cases / cv.new_tests) * 100 AS positivity_rate
FROM
    covid_deaths cd
        JOIN
    covid_vaccines cv ON cd.date_time = cv.date_time and cd.location = cv.location
WHERE
    cd.location LIKE '%India%'
GROUP BY 1 , 2
HAVING positivity_rate IS NOT NULL;

/* Display country wise daily covid positivity rate */
SELECT 
    cd.location,
    cd.date_time,
    cd.new_cases AS case_count,
    cv.new_tests AS test_count,
    (cd.new_cases / cv.new_tests) * 100 AS positivity_rate
FROM
    covid_deaths cd
        JOIN
    covid_vaccines cv ON cd.date_time = cv.date_time and cd.location = cv.location
GROUP BY 1 , 2
HAVING positivity_rate IS NOT NULL;

/* Display countrywise hospitals per thousand beds */
SELECT 
    location, hospital_beds_per_thousand
FROM
    covid_vaccines
GROUP BY 1
ORDER BY 2 desc;

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date_time, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.date_time) as RollingPeopleVaccinated
From covid_deaths dea
Join covid_vaccines vac
	On dea.location = vac.location
	and dea.date_time = vac.date_time
where dea.continent!='';







 