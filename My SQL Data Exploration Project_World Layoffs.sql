-- Exploratory Data Analysis
-- Skills Used ORDER BY, GROUP BY, SUBSTRING, OVER, CTE, RANK


SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off =1
ORDER BY total_laid_off DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 ASC;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Rolling total Calculation of total_laid_off each month

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY SUBSTRING(`date`,1,7)
ORDER BY 1 ASC;


WITH Rolling_total AS (
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_month_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY SUBSTRING(`date`,1,7)
ORDER BY 1 ASC
)
SELECT `MONTH`, total_month_laid_off,
SUM(total_month_laid_off) OVER( ORDER BY `MONTH`) AS rolling_total
FROM Rolling_total;


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC; 

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Rank the companies according to the running total

WITH company_year (company, years, total_laid_off) AS (
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Ranking AS (
SELECT *, dense_rank() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS RANK_Company
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Ranking
WHERE RANK_Company <=5
;