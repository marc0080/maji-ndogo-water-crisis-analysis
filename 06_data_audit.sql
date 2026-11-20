-- Integrating the Auditor's report

-- Creating the table  and importing the  auditor's report csv

DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

-- Viewing the report ; has 1620 records

SELECT * 
FROM auditor_report
;

/* We need to tackle a couple of questions here.
1. Is there a difference in the scores?
2. If so, are there patterns?
*/

-- Looking for a difference in the scores between auditor's score and employee score

/* With the duplicates removed I now get 1518 records. 
What does this mean considering the auditor visited 1620 sites?
I think that is an excellent result. 1518/1620 = 94% of the records the auditor checked were correct!
But that means that 102 records are incorrect.*/

SELECT
visits.location_id AS visit_location,
visits.record_id,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS employee_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
WHERE auditor_report.true_water_source_score = water_quality.subjective_quality_score
AND visits.visit_count = 1;

-- To View the 102 incorrect records we will include a " ! " 
-- before the " = " sign in the 1st WHERE clause from the last query

SELECT
visits.location_id AS visit_location,
visits.record_id,
auditor_report.true_water_source_score AS auditor_score,
water_quality.subjective_quality_score AS employee_score
FROM
auditor_report
JOIN
visits
ON auditor_report.location_id = visits.location_id
JOIN 
water_quality
ON water_quality.record_id = visits.record_id
WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
AND visits.visit_count = 1;


-- Linking the incorrect records to employees

-- Next up, let's look at where these errors may have come from.
-- We will create a CTE named incorrect records with employee names

CREATE OR REPLACE VIEW Incorrect_records AS (
	SELECT
		visits.location_id AS visit_location,
		visits.record_id,
		employee.employee_name,
		auditor_report.true_water_source_score AS auditor_score,
		water_quality.subjective_quality_score AS employee_score,
        auditor_report.statements AS statements
	FROM
		auditor_report
	JOIN visits
	ON auditor_report.location_id = visits.location_id
	JOIN water_quality
	ON water_quality.record_id = visits.record_id
	JOIN employee
	ON employee.assigned_employee_id= visits.assigned_employee_id
	WHERE auditor_report.true_water_source_score != water_quality.subjective_quality_score
		AND visits.visit_count = 1
);

-- calculate how many mistakes each employee made. 
SELECT 
        employee_name,
		COUNT(*) AS number_of_mistakes
    FROM incorrect_records 
    GROUP BY employee_name
    ORDER BY 2 DESC;
-- It looks like some of our surveyors are making a lot of "mistakes"
-- while many of the other surveyors are only making a few

WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
		employee_name,
		COUNT(employee_name) AS number_of_mistakes
FROM
	Incorrect_records
	/*
	Incorrect_records is a view that joins the audit report to the database
	for records where the auditor and
	employees scores are different */

GROUP BY
	employee_name),
	suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
	employee_name,
	number_of_mistakes
FROM
	error_count
WHERE
	number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data and contained cash statements 
SELECT
	employee_name,
	visit_location,
	statements
FROM
	Incorrect_records
WHERE
	employee_name in (SELECT employee_name FROM suspect_list)
    AND statements LIKE "%cash%";

-- So we can sum up the evidence we have for Zuriel Matembo, Malachi Mavuso, Bello Azibo and Lalitha Kaburi:
-- 1. They all made more mistakes than their peers on average.
-- 2. They all have incriminating statements made against them, and only them.



