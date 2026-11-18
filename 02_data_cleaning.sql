-- Beginning our data-driven journey in Maji Ndogo
-- Cleaning our data

-- Setting our employee emails to this syntax : first_name.last_name@ndogowater.gov.

SELECT 
	CONCAT(
    LOWER(REPLACE(employee_name, ' ','.') ),'@','ndogowater.gov') AS Employee_email
FROM employee;

-- Updating the email in the db

-- Disabling Safe update
SET SQL_SAFE_UPDATES = 0;
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),'@ndogowater.gov');


/* Identified trailing spaces in employee phone numbers using LENGTH().
 Applied TRIM() to remove leading and trailing spaces, ensuring
phone numbers meet the required 12-character format for SMS communication. */
SELECT
LENGTH(phone_number)
FROM
employee;
-- trimming whitespaces
SELECT 
	LTRIM(RTRIM(phone_number)) AS New_phone_number,
    LENGTH(LTRIM(RTRIM(phone_number)))
FROM employee;
--
UPDATE employee
SET phone_number = LTRIM(RTRIM(phone_number));

-- Honouring the workers

-- 1. Employee Distribution by Town
-- Counted employees in each town using COUNT(*) and GROUP BY town_name
-- to understand the geographical distribution of the workforce.
SELECT 
	town_name,
	COUNT(*) AS num_employee
FROM employee
GROUP BY 1;

-- Identifying the Top Three Field Surveyors
SELECT
    v.assigned_employee_id,
    e.employee_name,
    COUNT(*) AS num_of_visits
FROM visits v
JOIN employee e
    ON e.assigned_employee_id = v.assigned_employee_id
GROUP BY
    v.assigned_employee_id,
    e.employee_name
ORDER BY num_of_visits DESC
LIMIT 3;

/* 3. Retrieving Employee Contact Information
   Used the top three employee IDs to query the employee table
   and retrieve their names, email addresses and phone numbers
   for recognition by President Naledi. */
SELECT
    employee_name,
    email,
    phone_number
FROM employee
WHERE assigned_employee_id IN (1, 30, 34);



