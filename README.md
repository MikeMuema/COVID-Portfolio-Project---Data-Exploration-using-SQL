# COVID-Portfolio-Project---Data-Exploration-using-SQL

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM [Covid_Deaths].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 3,4
