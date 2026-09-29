USE [Admission Data];
GO
---viewing the data content.
SELECT COUNT(*) AS Raw_Row_Count FROM [HDHI Admission data];
SELECT TOP 100 * FROM [HDHI Admission data];
GO

---Create the clean view (single source of truth)A duplicate = same patient (MRD_No) with the same admit date (D_O_A)
---and discharge date (D_O_D). ROW_NUMBER() numbers the rows in each group;
---I keep row 1 only.ORDER BY SNO makes the row I keep the same on every run.
CREATE OR ALTER VIEW VW_AdmissionData AS WITH CleanData AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY MRD_No, D_O_A, D_O_D 
ORDER BY SNO) AS Dup_No
FROM [HDHI Admission data])
SELECT *
FROM CleanData
WHERE Dup_No = 1 -- keep one record per duplicate group
AND MRD_No IS NOT NULL; -- drop records with no patient ID
GO

---QUESTATION 1: Total Discharges
--To count how many patients ware discharged
--12608 TOTAL DISCHARGES
SELECT COUNT(*) AS Total_Discharges
FROM VW_AdmissionData
WHERE OUTCOME = 'DISCHARGE';
GO

---QUESTATION 2:Average daily discharge rate (discharges per calendar day) 
--- Total discharges divided by the number of calendar days in the period.Rows with no discharge date are excluded (1 record).
SELECT
COUNT(*) AS Total_Discharges,
DATEDIFF(DAY, MIN(D_O_D), MAX(D_O_D)) + 1 AS Days_In_Period,
CAST(1.0 * COUNT(*) / (DATEDIFF(DAY, MIN(D_O_D), MAX(D_O_D)) + 1)
AS DECIMAL(6,2)) AS Avg_Daily_Discharges
FROM VW_AdmissionData
WHERE OUTCOME = 'DISCHARGE'
AND D_O_D IS NOT NULL;
GO

---QUESTATION 3:Average length of stay(days)
SELECT
CAST(AVG(CAST(DURATION_OF_STAY AS FLOAT)) AS DECIMAL(5,2)) AS Avg_Length_of_Stay_Days
FROM VW_AdmissionData
WHERE OUTCOME = 'DISCHARGE';
GO

---QUESTATION 4:Distribution of discharges by age-group
 ---CROSS APPLY defines the CASE once so it is not repeated in GROUP BY.
---<18 pediatric
---18-59 adult
--->60 senior citizen
SELECT ag.Age_Group,
COUNT(*) AS Discharges,
CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,1)) AS Pct_Of_Discharges
FROM VW_AdmissionData
CROSS APPLY (SELECT CASE
WHEN AGE IS NULL THEN 'Unknown'
WHEN AGE < 18 THEN 'Pediatric'
WHEN AGE < 60 THEN 'Adult'
ELSE 'Senior citizen'
END AS Age_Group) AS ag
WHERE OUTCOME = 'DISCHARGE'
GROUP BY ag.Age_Group
ORDER BY Discharges DESC;
GO

---QUESTATION 5:Distribution of disscharges by Gender
SELECT
GENDER,COUNT(*) AS Discharges,
CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,1)) AS Pct_Of_Discharges
FROM VW_AdmissionData
WHERE OUTCOME = 'DISCHARGE'
GROUP BY GENDER
ORDER BY Discharges DESC;
GO

---QUESTATION 6:Ditribution of discharges by day of the week in calendar order.
SELECT DATENAME(WEEKDAY, D_O_D) AS Day_Of_Week, COUNT(*) AS Discharges
FROM VW_AdmissionData
WHERE OUTCOME = 'DISCHARGE' AND D_O_D IS NOT NULL
GROUP BY DATENAME(WEEKDAY, D_O_D), DATEPART(WEEKDAY, D_O_D)
ORDER BY DATEPART(WEEKDAY, D_O_D);

---DATA QUALITY CHECK 1: Raw vs clean row counts
SELECT
(SELECT COUNT(*) FROM [HDHI Admission data]) ---AS Raw_Rows,
(SELECT COUNT(*) FROM VW_AdmissionData) --AS Clean_Rows,
(SELECT COUNT(*) FROM [HDHI Admission data])--- (SELECT COUNT(*) FROM VW_AdmissionData)  AS Rows_Removed;
GO

---DATA QUALITY CHECK 2: Date range of the data
SELECT MIN(D_O_A) AS First_Admit,MAX(D_O_A) AS Last_Admit,
MIN(D_O_D) AS First_Discharge,MAX(D_O_D) AS Last_Discharge
FROM VW_AdmissionData;
GO