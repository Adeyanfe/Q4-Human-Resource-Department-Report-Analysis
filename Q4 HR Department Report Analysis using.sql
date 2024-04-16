/*********
Viewing all data from both table
**********/

-- 1. SELECT *
FROM Employee_information;

   TABLE 2

-- 1.1 SELECT *
FROM Employee_Performance;

Joining both tables

-- 2. SELECT *
FROM Employee_Information
JOIN Employee_Performance
ON Employee_Information.Employee_ID = Employee_Performance.Employee_ID;

-- 3. Find the total numbers of employees that have left the company
SELECT Count(*) AS total_employees
FROM
(SELECT employee_id FROM Employee_Performance
 UNION 
  SELECT employee_id FROM Employee_Information)
  AS combined_tables;
-- Answer = 300 employees have left the company

-- 4. Check for duplicate rows
SELECT 
    Employee_Information.Employee_Id,
    Employee_Information.Department,
    Emloyee_Information.Position,
    Employee_Information.Gender,
    Employee_Information.Age,
    Employee_Information.Hire_date,
    Employee_Information.Performance_rating,
    Employee_Performance.employee_id,
    Employee_Performance.Termination_Date,
    Employee_Performance.Reason_for_Termination,
    Employee_Performance.Employee_Satisfaction_Score,
    Employee_Performance.Manager_Feedback_Score,
    Employee_Performance.Annual_Salary,
    Employee_Performance.Training_Hours_Last_Year,
    Employee_Performance.Termination_Year,
    Employee_Performance.Termination_Quarter,
    COUNT(*) AS duplicate_count
FROM 
    Employee_Information
JOIN 
    Employee_Performance
ON 
    Employee_Information.Employee_ID = Employee_Performance.Employee_ID
GROUP BY 
    Employee_Information.Employee_Id,
    Employee_Information.Department,
    Employee_Information.Position,
    Employee_Information.Gender,
    Employee_Information.Age,
    Employee_Information.Hire_date,
    Employee_Information.Performance_rating,
    Employee_Performance.employee_id,
    Employee_Performance.Termination_Date,
    Employee_Performance.Reason_for_Termination,
    Employee_Performance.Employee_Satisfaction_Score,
    Employee_Performance.Manager_Feedback_Score,
    Employee_Performance.Annual_Salary,
    Employee_Performance.Training_Hours_Last_Year,
    Employee_Performance.Termination_Year,
    Employee_Performance.Termination_Quarter
HAVING 
    COUNT(*) > 1;
-- Answer = There are no duplicate rows

-- 5. Check for null values count for columns with null values
SELECT 'Manager_Feedback_Score' AS columnName, COUNT(*) AS NullCount
FROM Employee_Performance
WHERE manager_feedback_score IS NULL
UNION
SELECT 'Termination_Year' AS columnName, count(*) AS Nullcount
FROM Employee_Performance
WHERE termination_year IS NULL
UNION
SELECT 'Employee_satisfaction_score' AS ColumnName, COUNT(*) AS NullCount
FROM Employee_Performance
WHERE employee_satisfaction_score GLOB '*[^0-9]*';
-- The GLOB function sets non-numeric values(Unknown) in 'Employee_Satisfaction_Score' to NULL

-- 5.1 Handle null values
-- we will fill null values with their mean.
UPDATE Employee_Performance
SET manager_feedback_score = (SELECT AVG(manager_feedback_score) FROM Employee_Performance)
WHERE manager_feedback_score IS NULL;

-- Null values in Termination_year column
UPDATE Employee_Performance
WHERE termination_year = (SELECT AVG(termination_year) FROM Employee_Performance)
WHERE termination_year IS NULL;

-- Replace the non-numeric value to null
UPDATE Employee_Performance
SET Employee_Satisfaction_Score = NULL
WHERE Employee_Satisfaction_Score GLOB '*[^0-9]*';

-- Select statement is used to view the result of the queries
SELECT 'manager_feedback_score' AS columnName, COUNT(*) AS Nullcount
FROM Employee_Performance
WHERE manager_feedback_score IS NULL
UNION
SELECT 'Termination_Year' AS columnName, count(*) AS Nullcount
FROM Employee_Performance
WHERE termination_year IS NULL
UNION
SELECT 'Employee_satisfaction_score' AS ColumnName, COUNT(*) AS NullCount
FROM Employee_Performance
WHERE employee_satisfaction_score GLOB '*[^0-9]*';


/***********************************************
Data exploration and answering company questions
***********************************************/

-- 1. What is the turnover count for the past three years?
SELECT Termination_Year,COUNT(Employee_ID) AS Turnover
FROM Employee_Performance
Where Termination_Year IS NOT NULL
GROUP BY Termination_year 
ORDER BY termination_year DESC
LIMIT 3;
-- Answer = 2023, 2022, 2021 have 25, 27, 23 turnovers respectively.

-- 2. What is the employee turnover for this quarter as compared to the previous quarter of the year? As compared to the same quarter of the previous year?
-- 2.1 What is the employee turnover for Q4 as compared to the previous quarter of the year 2023
SELECT Termination_year, Termination_Quarter, 
COUNT(Employee_ID) AS Turnover
FROM Employee_Performance
WHERE Termination_Year = 2023
GROUP BY Termination_Year, Termination_Quarter
ORDER BY Termination_Year, Termination_Quarter DESC;
-- Answer = The employee turnover for Q4 is 10

-- 2.2 What is the employee turnover for Q4 of the previous year (2022)
SELECT Termination_year, Termination_Quarter, 
COUNT(Employee_ID) AS Turnover
FROM Employee_Performance
WHERE Termination_Year = 2022
GROUP BY Termination_Year, Termination_Quarter
ORDER BY Termination_Year, Termination_Quarter DESC;
-- Answer = The employee turnover for Q4 in 2022 is 5

-- 3. Which department has the highest turnover in the last three years?
SELECT Department, termination_year, COUNT(Employee_Information.Employee_ID) AS Turnover
FROM Employee_Information
JOIN Employee_Performance 
ON Employee_Information.Employee_ID = Employee_Performance.Employee_ID
WHERE Termination_Date BETWEEN '2023-01-01' AND '2023-12-04'
GROUP BY Department, termination_year
ORDER BY Turnover DESC
LIMIT 1;
-- Answer = The department with the highest turnover is HR with 5 turnover counts

--- 2022
SELECT Department, termination_year, COUNT(Employee_Information.Employee_ID) AS Turnover
FROM Employee_Information
JOIN Employee_Performance 
ON Employee_Information.Employee_ID = Employee_Performance.Employee_ID
WHERE Termination_Date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY Department
ORDER BY Turnover DESC
LIMIT 1;
-- Answer = The department with the highest turnover is Finance with 7 turnover counts

--- 2021
SELECT Department,termination_year, COUNT(Employee_Information.Employee_ID) AS Turnover
FROM Employee_Information
JOIN Employee_Performance
ON Employee_Information.Employee_ID = Employee_Performance.Employee_ID
WHERE Termination_Date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY Department
ORDER BY Turnover DESC
LIMIT 2;
-- Answer = The departments with the highest turnovers are operations and IT are 5

-- 4. Finding correlation between regular training and turnover?
SELECT AVG(Training_Hours_last_Year) AS Average_Training_Hours, AVG(employee_satisfaction_score) AS Average_Satisfaction_Score, COUNT(Employee_Id) AS Turnover
FROM Employee_Performance
WHERE Termination_year = 2022
GROUP BY Training_Hours_last_year
ORDER BY Turnover DESC;
-- Answer = There is no correlation between regular training and turnover

-- 5. What is the employee satisfaction score for this quarter as compared to the previous quarter of the year? As compared to the same quarter of the previous year?
-- 5.1 What is the employee Satisfaction Score for Q4 as compared to previous quarter of the year 2023?
SELECT Termination_Quarter,
AVG(Employee_Satisfaction_Score) AS Average_Satisfaction
FROM Employee_Performance
WHERE Termination_year = 2023 AND Employee_Satisfaction_Score is not NULL
GROUP BY Termination_Year, Termination_Quarter
ORDER BY Termination_Year, Termination_Quarter DESC;

-- 5.2 What is the employee Satisfaction Score for same quarter of the previous year 2022?
SELECT Termination_Quarter,
AVG(Employee_Satisfaction_Score) AS Average_Satisfaction
FROM Employee_Performance
WHERE Termination_year = 2022 AND Employee_Satisfaction_Score IS NOT NULL
GROUP BY Termination_Year, Termination_Quarter;

-- 6. Finding correlation between manager feedback and employee satisfaction?
SELECT AVG(Manager_Feedback_Score) AS Manager_Feedback, 
AVG(Employee_Satisfaction_Score) AS Employee_Satisfaction
FROM Employee_Performance
WHERE termination_year = 2023
GROUP BY Employee_ID;
-- Answer = There is no correlation between the two metrics.

-- 7. How does satisfaction scores vary across different departments?
SELECT Department, AVG(Employee_Satisfaction_Score) AS Average_Satisfaction_Score
FROM Employee_Information
JOIN Employee_Performance
ON Employee_Information.Employee_ID = Employee_Performance.Employee_ID
WHERE Termination_year = 2023
GROUP BY Department;

-- 8. Finding correlation between regular trainings and employee satisfaction?
SELECT AVG(Training_Hours_last_Year) AS Average_Training_Hours, 
AVG(Employee_Satisfaction_Score) AS Average_Satisfaction_Score
FROM Employee_Performance
Where Termination_year = 2023
GROUP BY Training_Hours_last_year;
-- Answer = There is no correlation between the two metrics.

-- 9. What is the employee satisfaction scores across the company?
SELECT Employee_Satisfaction_Score, COUNT(Employee_ID) AS Frequency
FROM Employee_Performance
WHERE Termination_Year = 2023
GROUP BY Employee_Satisfaction_Score;





