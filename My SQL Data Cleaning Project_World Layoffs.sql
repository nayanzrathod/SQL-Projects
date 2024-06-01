-- Data Cleaning Project
-- Skills Used CREATE TABLE, ALTER TABLE, INSERT, ROW_NUMBER, OVER, DELETE, CTE, UPDATE, SET

 
--  Copy data into the new table

SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Insertion of ROW_Number to find duplicates

SELECT company, industry, total_laid_off, `date`,
ROW_NUMBER() OVER(
                  Partition by company, industry, total_laid_off, `date`
                  ) AS row_num
FROM layoffs_staging;

SELECT *
FROM (
SELECT company, industry, total_laid_off, `date`,
ROW_NUMBER() OVER(
                  Partition by company, industry, total_laid_off, `date`
                  ) AS row_num
FROM layoffs_staging) AS duplicates
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging
WHERE company = 'Oda';

SELECT *
FROM (
SELECT company, industry, total_laid_off, `date`, percentage_laid_off, stage, country, location, funds_raised_millions, 
ROW_NUMBER() OVER(
                  Partition by company, industry, total_laid_off, `date`, percentage_laid_off, stage, country, location, funds_raised_millions
                  ) AS row_num
FROM layoffs_staging) AS duplicates
WHERE row_num > 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH Delete_CTE AS
(
SELECT *
FROM (
SELECT company, industry, total_laid_off, `date`, percentage_laid_off, stage, country, location, funds_raised_millions, 
ROW_NUMBER() OVER(
                  Partition by company, industry, total_laid_off, `date`, percentage_laid_off, stage, country, location, funds_raised_millions
                  ) AS row_num
FROM layoffs_staging) AS duplicates
WHERE row_num > 1
)
DELETE 
FROM 
Delete_CTE;

WITH DELETE_CTE AS (
                  SELECT company, industry, total_laid_off, `date`, percentage_laid_off, stage, country, location, funds_raised_millions, 
                  ROW_NUMBER() OVER(
                  Partition by company, industry, total_laid_off, `date`, percentage_laid_off, stage, country, location, funds_raised_millions
                  ) AS row_num
FROM layoffs_staging )
DELETE FROM layoffs_staging
WHERE (company, industry, total_laid_off, `date`, percentage_laid_off, stage, country, location, funds_raised_millions, row_num) IN(
       SELECT (company, industry, total_laid_off, `date`, percentage_laid_off, stage, country, location, funds_raised_millions, row_num)
       FROM DELETE_CTE)
       AND row_num > 1;
       
ALTER TABLE layoffs_staging
ADD row_num INT;
       
SELECT * 
FROM layoffs_staging;
                  
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO `world_layoff`.`layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT
`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
     ROW_NUMBER() OVER(
		Partition by company, industry, total_laid_off, `date`, percentage_laid_off, stage, country, location, funds_raised_millions
		) AS row_num
FROM world_layoff.layoffs_staging;


SELECT *
FROM world_layoff.layoffs_staging2;

DELETE FROM layoffs_staging2
WHERE row_num >=2;

SELECT *
FROM world_layoff.layoffs_staging2
WHERE row_num > 1;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize the data
-- Check for NULL and Blank Values and fix them

SELECT DISTINCT industry
FROM world_layoff.layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = ''
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'airbnb%';

UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = ''
ORDER BY industry;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = ''
ORDER BY industry;


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

SELECT DISTINCT country 
FROM layoffs_staging2
ORDER BY country;

UPDATE layoffs_staging2
SET country = trim(TRAILING '.' FROM country );


SELECT *
FROM layoffs_staging2;


UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');


ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE ;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Columns and Rows if unnecessary

SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;