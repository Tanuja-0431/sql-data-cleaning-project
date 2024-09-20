#SQL Project - Data Cleaning
Welcome to the SQL Project on Data Cleaning! This project focuses on cleaning and organizing a dataset of layoffs from 2022. The data, originally sourced from Kaggle, contains information about various companies, the number of employees laid off, industries affected, and more. Our goal is to ensure the dataset is clean, consistent, and ready for analysis.

About the Dataset
Source: Layoffs 2022 Dataset on Kaggle
Table: world_layoffs.layoffs
The dataset includes columns like company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, and funds_raised_millions. It's important to clean this data so it’s reliable and easier to work with.

How We Cleaned the Data
1. Creating a Backup (Staging Table)
First, we create a copy of the original data. This allows us to make changes while keeping the raw data intact. We call this copy the staging table.

sql
Copy code
CREATE TABLE world_layoffs.layoffs_staging LIKE world_layoffs.layoffs;
INSERT INTO world_layoffs.layoffs_staging SELECT * FROM world_layoffs.layoffs;
2. Removing Duplicate Entries
Data can sometimes have duplicates, so we used a method to identify and remove them. By applying a ROW_NUMBER() function, we made sure that only one unique record for each company and layoff event remains.

sql
Copy code
WITH duplicate_rows AS (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions ORDER BY company) AS row_num
    FROM world_layoffs.layoffs_staging
)
DELETE FROM world_layoffs.layoffs_staging
WHERE row_num > 1;
3. Standardizing the Data
Consistency is key when it comes to analyzing data. Here's how we cleaned up the data:

Handling missing values: Any blank values in the industry column were set to NULL, and where possible, we filled these missing values by looking for similar entries from the same company.

Fixing industry names: We standardized variations of terms like "Crypto" to ensure they’re consistent.

Cleaning the country field: We removed any trailing periods from country names.

Fixing dates: The date column was converted into a proper date format for easier filtering and sorting.

sql
Copy code
-- Standardize 'Crypto' industry variations
UPDATE world_layoffs.layoffs_staging SET industry = 'Crypto' WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

-- Fix country names
UPDATE world_layoffs.layoffs_staging SET country = TRIM(TRAILING '.' FROM country);

-- Convert 'date' column to proper date format
UPDATE world_layoffs.layoffs_staging SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE world_layoffs.layoffs_staging MODIFY COLUMN `date` DATE;
4. Handling Unnecessary Null Values
We removed records that didn’t contain meaningful information, such as rows where both total_laid_off and percentage_laid_off were missing.

sql
Copy code
DELETE FROM world_layoffs.layoffs_staging WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
5. Final Cleanup
To tidy up, we made sure to drop any temporary columns we used during the cleaning process, leaving the dataset lean and clean.

sql
Copy code
ALTER TABLE world_layoffs.layoffs_staging DROP COLUMN IF EXISTS row_num;
Why This Matters
Cleaning and organizing the data ensures that it is accurate, reliable, and easy to analyze. This clean version of the dataset can now be used for further exploration, insights, and even visualizations, without the risk of errors caused by messy data.


Key Takeaways:
We created a backup table to work on, ensuring we didn’t affect the original data.
Duplicates were removed, data was standardized, and invalid or incomplete rows were cleaned up.
This clean data is now ready for any deeper analysis, modeling, or visualization.

