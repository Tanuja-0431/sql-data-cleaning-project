

-- https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Step 1: Create a staging table for data cleaning

CREATE TABLE world_layoffs.layoffs_staging LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging
SELECT * FROM world_layoffs.layoffs;


-- Step 2: Remove duplicates

-- Check for duplicates based on key columns
WITH duplicate_rows AS (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
               ORDER BY company) AS row_num
    FROM world_layoffs.layoffs_staging
)
-- Delete duplicates where row_num > 1
DELETE FROM world_layoffs.layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
    FROM duplicate_rows
    WHERE row_num > 1
);


-- Step 3: Standardize data

-- Set blank values to NULL in the 'industry' column
UPDATE world_layoffs.layoffs_staging
SET industry = NULL
WHERE industry = '';

-- Update NULL industry values based on other rows with the same company
UPDATE world_layoffs.layoffs_staging t1
JOIN world_layoffs.layoffs_staging t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Standardize variations of 'Crypto' industry
UPDATE world_layoffs.layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Standardize the country name by removing the trailing period
UPDATE world_layoffs.layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);


-- Step 4: Fix 'date' column format

-- Convert the 'date' column to proper date format
UPDATE world_layoffs.layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify the data type of the 'date' column to DATE
ALTER TABLE world_layoffs.layoffs_staging
MODIFY COLUMN `date` DATE;


-- Step 5: Handle NULL values

-- Delete rows where both 'total_laid_off' and 'percentage_laid_off' are NULL
DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Final Step: Clean up by removing unnecessary columns

-- Drop the 'row_num' column if it was created
ALTER TABLE world_layoffs.layoffs_staging
DROP COLUMN IF EXISTS row_num;


-- Verify the cleaned data
SELECT * 
FROM world_layoffs.layoffs_staging;
