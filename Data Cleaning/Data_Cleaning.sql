-- Data Cleaning

SELECT *
FROM layoffs;

/*
1. Remove Duplicates
2. Standarize the Data
3. Null values or blank values
4. Remove any columns
*/

----------------------------------------------------------------------------------------------------
-- 1. Remove Duplicate

-- Membuat salinan tabel
CREATE TABLE layoffs_staging
LIKE layoffs;
-- Membuat salinan data 
INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT * 
FROM layoffs_staging;

-- Ini bikin semua kolom jadi satu grup gitu jadi kalo misal ada grup yang sama maka row_numnya jadi 2
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) AS row_num 
FROM layoffs;

-- Ini dibuat kek menjadi fungsi atau semacam temp tabel biar bisa dipanggil pake nama gitu
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) AS row_num 
FROM layoffs
)

SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM duplicate_cte
WHERE company = 'casper';

-- Duplikat tabel lagi buat menghapus data yang duplikat
CREATE TABLE `layoffs_staging2` (
  `company` text DEFAULT NULL,
  `location` text DEFAULT NULL,
  `industry` text DEFAULT NULL,
  `total_laid_off` int(11) DEFAULT NULL,
  `percentage_laid_off` text DEFAULT NULL,
  `date` text DEFAULT NULL,
  `stage` text DEFAULT NULL,
  `country` text DEFAULT NULL,
  `funds_raised_millions` int(11) DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) AS row_num 
FROM layoffs_staging;

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

DELETE  
FROM layoffs_staging2
WHERE row_num > 1;
----------------------------------------------------------------------------------------------------

-- 2. Standarize the data

-- Menghapus spasi diawal kata atau akhir
SELECT company, TRIM(company)
FROM layoffs_staging2;
-- Diupdate ke dalam tabel
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Buat lihat samanya dimana aja
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
-- Buat update kolom industry yg datanya sama aja jadi sama satu kata
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Buat lihat samanya dimana aja
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;
-- Buat updatenya
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Mengubah format di baris nya 
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;
-- Update ke dalam tabelny
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT  `date`
FROM layoffs_staging2;
-- Mengubah format kolomnya dari TEXT ke DATE
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
----------------------------------------------------------------------------------------------------

-- 3. Null or blank data

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- Disini kita coba ngisi data di industry yg kosong dengan data yang ada
-- Sebelumnya kita ubah dulu yang formatnya masih '' jadi NULL biar gampang
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';
-- Ini cek data yg kosong sama ga kosongnya
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;
-- Update data dengan data yang ada pada data yang kosong
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Cek data NULL di kolom total sama percentage
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- Karena tidak memungkinkan untuk diisi jadi di delete saja
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
----------------------------------------------------------------------------------------------------

-- 4. Remove any columns
SELECT * 
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;






