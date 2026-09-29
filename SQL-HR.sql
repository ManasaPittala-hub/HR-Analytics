CREATE DATABASE HR_analytics;

USE hr_analytics;

-- Check both tables loaded (expect 50000 each)
SELECT COUNT(*) AS HR_1_Rows FROM hr_1;
SELECT COUNT(*) AS HR_2_Rows FROM hr_2;

-- KPI 1: Average attrition rate for all departments
SELECT
    Department,
    COUNT(*) AS Total_Employees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Attrition_Employees,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct
FROM hr_1
GROUP BY Department
ORDER BY Attrition_Rate_Pct DESC;

-- KPI 2: Average hourly rate of male Research Scientists
SELECT
    COUNT(*) AS Employee_Count,
    ROUND(AVG(HourlyRate), 2) AS Average_Hourly_Rate
FROM hr_1
WHERE Gender = 'Male'
  AND JobRole = 'Research Scientist';

-- KPI 3a: Attrition vs monthly income (average income for leavers vs stayers)
SELECT
    a.Attrition,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(b.MonthlyIncome), 2) AS Average_Monthly_Income,
    MIN(b.MonthlyIncome) AS Min_Income,
    MAX(b.MonthlyIncome) AS Max_Income
FROM hr_1 AS a
INNER JOIN hr_2 AS b ON a.EmployeeNumber = b.Employee_ID
GROUP BY a.Attrition;

-- KPI 3b: Attrition rate by monthly income band
SELECT
    Income_Band,
    COUNT(*) AS Employee_Count,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct
FROM (
    SELECT
        a.Attrition,
        CASE
            WHEN b.MonthlyIncome < 10000 THEN '1. Under 10K'
            WHEN b.MonthlyIncome < 20000 THEN '2. 10K-20K'
            WHEN b.MonthlyIncome < 30000 THEN '3. 20K-30K'
            WHEN b.MonthlyIncome < 40000 THEN '4. 30K-40K'
            ELSE '5. 40K+'
        END AS Income_Band
    FROM hr_1 AS a
    INNER JOIN hr_2 AS b ON a.EmployeeNumber = b.Employee_ID
) AS t
GROUP BY Income_Band
ORDER BY Income_Band;

-- KPI 4: Average working years for each department
SELECT
    a.Department,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(b.TotalWorkingYears), 2) AS Average_Working_Years
FROM hr_1 AS a
INNER JOIN hr_2 AS b ON a.EmployeeNumber = b.Employee_ID
GROUP BY a.Department
ORDER BY Average_Working_Years DESC;

-- KPI 5: Job role vs work-life balance
SELECT
    a.JobRole,
    COUNT(*) AS Employee_Count,
    ROUND(AVG(b.WorkLifeBalance), 2) AS Average_WorkLife_Balance
FROM hr_1 AS a
INNER JOIN hr_2 AS b ON a.EmployeeNumber = b.Employee_ID
GROUP BY a.JobRole
ORDER BY Average_WorkLife_Balance DESC;

-- KPI 6a: Attrition rate vs years since last promotion (each year)
SELECT
    b.YearsSinceLastPromotion,
    COUNT(*) AS Employee_Count,
    ROUND(SUM(CASE WHEN a.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct
FROM hr_1 AS a
INNER JOIN hr_2 AS b ON a.EmployeeNumber = b.Employee_ID
GROUP BY b.YearsSinceLastPromotion
ORDER BY b.YearsSinceLastPromotion;

-- KPI 6b: Attrition rate by promotion gap band
SELECT
    Promotion_Gap,
    COUNT(*) AS Employee_Count,
    ROUND(SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Attrition_Rate_Pct
FROM (
    SELECT
        a.Attrition,
        CASE
            WHEN b.YearsSinceLastPromotion <= 5  THEN '1. 0-5 years'
            WHEN b.YearsSinceLastPromotion <= 10 THEN '2. 6-10 years'
            WHEN b.YearsSinceLastPromotion <= 20 THEN '3. 11-20 years'
            ELSE '4. 21+ years'
        END AS Promotion_Gap
    FROM hr_1 AS a
    INNER JOIN hr_2 AS b ON a.EmployeeNumber = b.Employee_ID
) AS t
GROUP BY Promotion_Gap
ORDER BY Promotion_Gap;