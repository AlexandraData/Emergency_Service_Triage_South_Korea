/* 
Emergency Service - Triage Application in South Korea 
Skills used: Joins, CTE, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Use Korea Database 
USE korea_emergency_service

-- View all records 
SELECT * FROM emergency_service
SELECT * FROM KTAS_Level

-- Check for Null values in KTAS_RN and KTAS_expert
SELECT
   	KTAS_RN, 
   	KTAS_expert,
	Disposition
FROM emergency_service
WHERE KTAS_RN IS NULL AND KTAS_expert IS NULL

-- Cast "Age" from float  to integer
SELECT 
	Age, 
    CAST(age AS int) AS Age 
FROM emergency_service

-- Convert 1 to Female and 2 to Male
SELECT
	CASE 
		WHEN Sex = 1 THEN 'Female'
		WHEN Sex = 2 THEN 'Male'
	ELSE 'other'
	END Gender
FROM emergency_service

-- Calculate Mistriage
SELECT
	KTAS_RN,
    KTAS_expert,
    CASE 
		WHEN KTAS_RN < KTAS_expert THEN 'Over triage'
		WHEN KTAS_RN = KTAS_expert THEN 'Correct triage'
        WHEN KTAS_RN > KTAS_expert THEN 'Under triage'
	ELSE 'other'
	END AS 'Triage Difference'
FROM emergency_service

-- Add a column with the minutes per KTAS level
SELECT
	KTAS_RN,
	CASE 
		WHEN KTAS_RN = 1 THEN 0
		WHEN KTAS_RN = 2 THEN 10
        WHEN KTAS_RN = 3 THEN 30
        WHEN KTAS_RN = 4 THEN 60
        WHEN KTAS_RN = 5 THEN 120
	ELSE 'other'
	END AS 'Medical Action (minutes)'
FROM emergency_service

-- Blood Pressure Calculation / Classification
SELECT 
	SBP,
    DBP,
    CASE 
		WHEN SBP < 120 AND DBP < 80 THEN 'Normal Blood Pressure'
		WHEN SBP BETWEEN 120 AND 129 AND DBP < 80 THEN 'Elevated Blood Pressure'
		WHEN SBP BETWEEN 130 AND 139 OR DBP > 80 AND  DBP < 89 THEN 'High Blood Pressure - Hypertension Stage 1'
		WHEN SBP > 140 OR DBP > 90 THEN 'High Blood Pressure - Hypertension Stage 2'
   		WHEN SBP > 180 OR DBP > 120 THEN 'High Blood Pressure - Hypertensive Crisis - Consult Doctor Immediatly'     
	ELSE 'other'
	END AS 'Blood Pressure'
FROM emergency_service

-- Minimum, Average, Maximum Length of stay in minutes, Group and Order by Disposition
SELECT 
    	Disposition,
     	CASE 
		WHEN Disposition = 1 THEN 'Discharge'
		WHEN Disposition = 2 THEN 'Ward admission'
		WHEN Disposition = 3 THEN 'ICU admission'
		WHEN Disposition = 4 THEN 'AMA discharge'     
		WHEN Disposition = 5 THEN 'Transfer'   
		WHEN Disposition = 6 THEN 'Death' 
		WHEN Disposition = 7 THEN 'OP from ED' 
	ELSE 'other'
	END AS 'Disposition Info',
	ROUND(MIN(Length_of_stay_min), 2) As 'Minimum Stay (minutes)',
	ROUND(AVG(Length_of_stay_min), 2) As 'Average Stay (minutes)',
    ROUND(MAX(Length_of_stay_min), 2) As 'Maximum Stay (minutes)'
FROM emergency_service
GROUP BY Disposition
ORDER BY Disposition

-- Search for Acute Diagnosis and Compare Patients Complaint with Nurse Diagnosis
SELECT 
	Chief_complain,
    Diagnosis_in_ED
FROM emergency_service
WHERE Diagnosis_in_ED LIKE ('%acute%')


/* 
Creating View to store data for later visualization
Table 1 All Records Partition by Mistriage Disposition
*/

CREATE OR ALTER VIEW V_Records_Partition_Mistriage_Disposition AS
SELECT
	CASE 
		WHEN t1.Sex = 1 THEN 'Female'
		WHEN t1.Sex = 2 THEN 'Male'
	ELSE 'other'
	END Gender,
	CAST(t1.age AS int) AS Age, 
	CASE 
		WHEN SBP < 120 AND DBP < 80 THEN 'Normal Blood Pressure'
		WHEN SBP BETWEEN 120 AND 129 AND DBP < 80 THEN 'Elevated Blood Pressure'
		WHEN SBP BETWEEN 130 AND 139 OR DBP > 80 AND DBP < 89 THEN 'High Blood Pressure - Hypertension Stage 1'
		WHEN SBP > 140 OR DBP > 90 THEN 'High Blood Pressure - Hypertension Stage 2'
   		WHEN SBP > 180 OR DBP > 120 THEN 'High Blood Pressure - Hypertensive Crisis - Consult Doctor Immediatly'     
	ELSE 'other'
	END 'Blood Pressure',
    t1.KTAS_RN, 
    t1.KTAS_expert,
	CASE 
		WHEN t1.KTAS_RN < KTAS_expert THEN 'Over triage'
		WHEN t1.KTAS_RN = KTAS_expert THEN 'Correct triage'
        WHEN t1.KTAS_RN > KTAS_expert THEN 'Under triage'
	ELSE 'other'
	END 'Mistriage',
    t1.Disposition,
    CASE 
		WHEN t1.Disposition = 1 THEN 'Discharge'
		WHEN t1.Disposition = 2 THEN 'Ward admission'
		WHEN t1.Disposition = 3 THEN 'ICU admission'
		WHEN t1.Disposition = 4 THEN 'AMA discharge'     
		WHEN t1.Disposition = 5 THEN 'Transfer'   
		WHEN t1.Disposition = 6 THEN 'Death' 
		WHEN t1.Disposition = 7 THEN 'OP from ED' 
	ELSE 'other'
	END 'Disposition Info',
	ROW_NUMBER() OVER(PARTITION BY t1.mistriage, t1.Disposition ORDER BY t1.Disposition) As 'Row Number of Mistriage by Disposition',
	Length_of_stay_min As 'Lenght of stay (minutes)',
    t2.KTAS_Level
FROM emergency_service t1
INNER JOIN KTAS_Level t2 
	ON t1.KTAS_RN = t2.KTAS_RN;


/* 
Creating View to store data for later visualization
Table 3 CTE Records Under Over Triage 
*/

CREATE OR ALTER VIEW V_Records_Under_Over_Triage AS
WITH cte AS
(SELECT
	KTAS_RN, 
    KTAS_expert,
	CASE 
		WHEN KTAS_RN < KTAS_expert THEN 'Over triage'
		WHEN KTAS_RN = KTAS_expert THEN 'Correct triage'
        WHEN KTAS_RN > KTAS_expert THEN 'Under triage'
	ELSE 'other'
	END AS 'Mistriage',
    CASE 
		WHEN Disposition = 1 THEN 'Discharge'
		WHEN Disposition = 2 THEN 'Ward admission'
		WHEN Disposition = 3 THEN 'ICU admission'
		WHEN Disposition = 4 THEN 'AMA discharge'     
		WHEN Disposition = 5 THEN 'Transfer'   
		WHEN Disposition = 6 THEN 'Death' 
		WHEN Disposition = 7 THEN 'OP from ED' 
	ELSE 'other'
	END AS 'Disposition Info',
	ROW_NUMBER() OVER(PARTITION BY mistriage, Disposition ORDER BY Disposition) As 'Row Number of Mistriage by Disposition'
FROM emergency_service)
SELECT *
FROM cte
WHERE Mistriage IN ('Under triage','Over triage');


/* 
Creating View to store data for later visualization
Table 5 Records Length Stay
*/

CREATE OR ALTER VIEW V_Lenght_Stay_Disposition AS
SELECT
    Disposition,
    CASE 
		WHEN Disposition = 1 THEN 'Discharge'
		WHEN Disposition = 2 THEN 'Ward admission'
		WHEN Disposition = 3 THEN 'ICU admission'
		WHEN Disposition = 4 THEN 'AMA discharge'     
		WHEN Disposition = 5 THEN 'Transfer'   
		WHEN Disposition = 6 THEN 'Death' 
		WHEN Disposition = 7 THEN 'OP from ED' 
	ELSE 'other'
	END AS 'Disposition Info',
	Length_of_stay_min As 'Lenght of stay (minutes)'
FROM emergency_service;