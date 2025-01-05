SELECT *
FROM healthcare_dataset;

DESC healthcare_dataset;

-- Bikin duplikat tabel
CREATE TABLE healthcare
LIKE healthcare_dataset;

SELECT * FROM healthcare;

INSERT healthcare
SELECT * 
FROM healthcare_dataset;

-- Ubah kolom Name jadi huruf awal yang besar
DELIMITER $$
CREATE FUNCTION ucfirst(input VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE len INT;
    DECLARE i INT;
    DECLARE result VARCHAR(255);
 
    SET len = CHAR_LENGTH(input);
    SET input = LOWER(input);
    SET result = '';
    SET i = 1;
 
    WHILE (i <= len) DO
        IF (i = 1 OR SUBSTRING(input, i - 1, 1) = ' ') THEN
            SET result = CONCAT(result, UPPER(SUBSTRING(input, i, 1)));
        ELSE
            SET result = CONCAT(result, SUBSTRING(input, i, 1));
        END IF;
        SET i = i + 1;
    END WHILE;
 
    RETURN result;
END$$
DELIMITER ;

SELECT ucfirst(Name)
FROM healthcare;

UPDATE healthcare
SET Name = ucfirst(Name);

SELECT * FROM healthcare;

-- Cek ada baris yang duplikat
WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY Name, Age, Gender, `Blood Type`, `Medical Condition`, `Date of Admission`, `Doctor`) AS row_num
FROM healthcare
)

-- SELECT *
-- FROM duplicate_cte
-- WHERE row_num > 1; 

SELECT *
FROM duplicate_cte
WHERE Name LIKE "Abigail Young";

-- Bikin tabel baru buat hapus tabel yang duplikat
CREATE TABLE `healthcare2` (
  `Name` text DEFAULT NULL,
  `Age` int(11) DEFAULT NULL,
  `Gender` text DEFAULT NULL,
  `Blood Type` text DEFAULT NULL,
  `Medical Condition` text DEFAULT NULL,
  `Date of Admission` text DEFAULT NULL,
  `Doctor` text DEFAULT NULL,
  `Hospital` text DEFAULT NULL,
  `Insurance Provider` text DEFAULT NULL,
  `Billing Amount` double DEFAULT NULL,
  `Room Number` int(11) DEFAULT NULL,
  `Admission Type` text DEFAULT NULL,
  `Discharge Date` text DEFAULT NULL,
  `Medication` text DEFAULT NULL,
  `Test Results` text DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO healthcare2
SELECT *, 
ROW_NUMBER() OVER(PARTITION BY Name, Age, Gender, `Blood Type`, `Medical Condition`, `Date of Admission`, `Doctor`
) AS row_num
FROM healthcare;

SELECT * 
FROM healthcare2;

DELETE
FROM healthcare2
WHERE row_num > 1;

ALTER TABLE healthcare2
DROP COLUMN row_num;

-- Mengubah format text ke date 
SELECT `Date of Admission`,
STR_TO_DATE(`Date of Admission`, '%Y-%m-%d')
FROM healthcare2;

UPDATE healthcare2
SET `Date of Admission` = STR_TO_DATE(`Date of Admission`, '%Y-%m-%d');

ALTER TABLE healthcare2
MODIFY COLUMN `Date of Admission` DATE;

UPDATE healthcare2
SET `Discharge Date` = STR_TO_DATE(`Discharge Date`, '%Y-%m-%d');

ALTER TABLE healthcare2
MODIFY COLUMN `Discharge Date` DATE;

-- DONE
SELECT * 
FROM healthcare2;