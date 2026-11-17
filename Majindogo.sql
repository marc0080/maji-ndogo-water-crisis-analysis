-- 
USE md_water_services;
SELECT SUM(number_of_people_served) AS pop
		
FROM water_source
;
SELECT 
	CONCAT(
    LOWER(REPLACE(employee_name, ' ','.') ),'@','ndogowater.gov') AS Employee_email
FROM employee;

-- Updating the email in the db

-- Disabling Safe update
SET SQL_SAFE_UPDATES = 0;
UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')),

'@ndogowater.gov');
--
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

SELECT 
	town_name,
	COUNT(*) AS num_employee
FROM employee
WHERE town_name = 'Harare'
	AND province_name = 'Kilimani'
GROUP BY 1;

-- Honouring the workers
SELECT
    v.assigned_employee_id,
    e.employee_name,
    COUNT(*) AS Num_of_visits
FROM visits v
JOIN employee e
ON e.assigned_employee_id = v.assigned_employee_id
GROUP BY assigned_employee_id
ORDER BY Num_of_visits
LIMIT 5;

SELECT COUNT(*) AS records_per_town,
		town_name
FROM location
GROUP BY town_name
ORDER BY records_per_town DESC;

-- count records per town grouped by town name and province name
SELECT 
		province_name,
		town_name,
        COUNT(*) AS Records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name,town_name DESC;

-- count of records per location type
SELECT 
		COUNT(*) AS num_records_per_loc_type,
        ((num_records_per_loc_type/SUM(*))*100 ) AS pct_coverage
        location_type
FROM location
GROUP BY 2
ORDER BY 1 DESC;

/* 
We can see that 60% of all water sources in the data set are in rural communities.
So again, what are some of the insights we gained from the location table?
1. Our entire country was properly canvassed, and our dataset represents the situation on the ground.
2. 60% of our water sources are in rural communities across Maji Ndogo. We need to keep this in mind when we make decisions.
*/
SELECT
    location_type,
    COUNT(*) AS num_records_per_loc_type,
    ROUND(
        (COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (),
        2
    ) AS pct_coverage
FROM location
GROUP BY location_type
ORDER BY num_records_per_loc_type DESC;

-- Water source 
SELECT *
FROM water_source;

SELECT 
		SUM(number_of_number_of_number_of_people_served) AS Total_no_pple_serv
FROM water_source;

-- COUNT of EACH type of water source
SELECT 
		COUNT(type_of_water_source) AS num_type_of_water_source,
        type_of_water_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY num_type_of_water_source;


-- 3. How many pple share particular types of water sources on average?
SELECT 
		ROUND(AVG(number_of_number_of_number_of_people_served)) AS avg_no_of_pple,
        type_of_water_source
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY avg_no_of_pple DESC;

-- Total number of people served
-- 43% of our people are using shared taps in their communities, 
-- and on average, we saw earlier, that 2000 people share one shared_tap.
SELECT
    type_of_water_source,
    SUM(number_of_number_of_number_of_people_served) AS Total_no_of_ppl,
    ROUND(
        SUM(number_of_number_of_number_of_people_served) * 100.0 /
        SUM(SUM(number_of_number_of_number_of_people_served)) OVER (),
        0
    ) AS Pct_pple_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY Total_no_of_ppl DESC;

--
SELECT
    type_of_water_source,
    SUM(number_of_number_of_number_of_people_served) AS Total_no_of_ppl,
    ROUND(
        SUM(number_of_number_of_number_of_people_served) * 100.0 /
        SUM(SUM(number_of_number_of_number_of_people_served)) OVER (),
        0
    ) AS Pct_pple_per_source,
    RANK() OVER (
        ORDER BY SUM(number_of_number_of_number_of_people_served) DESC
    ) AS Rank_priority
FROM water_source
GROUP BY type_of_water_source
ORDER BY Total_no_of_ppl DESC;


--
SELECT
	source_id,
    type_of_water_source,
    SUM(number_of_number_of_number_of_people_served) AS Total_no_of_ppl,
    DENSE_RANK() OVER (
        ORDER BY SUM(number_of_number_of_number_of_people_served) DESC
    ) AS Rank_priority,
    ROW_NUMBER() OVER ( ORDER BY SUM(number_of_number_of_number_of_people_served) DESC) AS unique_row_number
FROM water_source
GROUP BY type_of_water_source,1
ORDER BY Total_no_of_ppl;

-- How long did the survey take? = 924 DAYS
SELECT
    MIN(time_of_record) AS survey_start,
    MAX(time_of_record) AS survey_end,
    TIMESTAMPDIFF(DAY, MIN(time_of_record), MAX(time_of_record)) AS survey_duration_days
FROM visits;

-- The average queue time for water is 123min Excluding where time_in_queue =0
SELECT ROUND(AVG(NULLIF(time_in_queue,0)),0) AS average_queue_time_for_water
FROM visits;

-- Avg queue time for water by days of week
SELECT 
		DAYNAME(time_of_record) AS Day_of_week,
		ROUND(AVG(NULLIF(time_in_queue,0)),0) AS average_queue_time_for_water,
        TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day
FROM visits
GROUP BY DAYNAME(time_of_record)
ORDER BY 2 desc;

-- for sunday
SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
visits
WHERE
time_in_queue != 0;

/* Creating a pivot table to have a visual on the avegage queueing time on a daily basis
1. Queues are very long on a Monday morning and Monday evening as people rush to get water.
2. Wednesday has the lowest queue times, but long queues on Wednesday evening.
3. People have to queue pretty much twice as long on Saturdays compared to the weekdays. It looks like people spend their Saturdays queueing
for water, perhaps for the week's supply?
4. The shortest queues are on Sundays, and this is a cultural thing. The people of Maji Ndogo prioritise family and religion, so Sundays are spent
with family and friends*/

SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
-- Sunday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END
),0) AS Sunday,
-- Monday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
ELSE NULL
END
),0) AS Monday,
-- Tuesday
ROUND( AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END 
),0) AS Tuesday,
-- Wednesday
ROUND( AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END 
),0) AS Wednesday,
-- Thursday
ROUND( AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END 
),0) AS Thursday,
-- Friday
ROUND( AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END 
),0) AS Friday,
-- Saturday
ROUND( AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END 
),0) AS Saturday
FROM
md_water_services.visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;

/* Immediate Relief: Deploy water tankers during peak hours, especially Saturdays.
Short-term Fixes: Install UV and RO filtration systems.
Infrastructure Focus: Repair broken home taps to restore service efficiently.
Long-term Goal: Reduce queue times to under 30 minutes. */

-- Count of employee living in Dahabu = 6 
SELECT 
	province_name,
	COUNT(*) AS employee_count,
    COUNT(w.type_of_water_source) AS type_water_count
    
FROM md_water_services.employee AS e
JOIN visits v
ON v.assigned_employee_id = e.assigned_employee_id
JOIN water_source w
ON w.source_id = v.source_id
GROUP BY province_name
ORDER BY 3 DESC;

-- Day 
SELECT 
	DATEDIFF(Min(time_of_record),Max(time_of_record)) AS Days_Spent
FROM md_water_services.visits
WHERE location_id = 'AkRu04611';

-- count the ‘clean’ water sources for each month - 
 -- which months had the highest and lowest number of ‘clean’ water sources, respectively

SELECT monthname(date) AS month,
		count(*) AS count
        
FROM md_water_services.well_pollution
WHERE results = 'Clean'
GROUP BY 1
ORDER BY 2 DESC;
        
SELECT 
    location_id,
    time_in_queue,
    AVG(time_in_queue) OVER (PARTITION BY location_id ORDER BY visit_count) AS total_avg_queue_time
FROM 
    visits
WHERE 
visit_count > 1 -- Only shared taps were visited > 1
ORDER BY 
    location_id, time_of_record;
    
-- Corrupt officers 
CREATE OR REPLACE VIEW Incorrect_records AS (
    SELECT 	
        a.location_id AS location,
        v.record_id,
        e.employee_name,
        a.true_water_source_score as auditors_score,
        w.subjective_quality_score AS employee_score,
        a.statements AS statements
    FROM auditor_report a
    JOIN visits v ON v.location_id = a.location_id
    JOIN water_quality w ON w.record_id = v.record_id
    JOIN employee e ON e.assigned_employee_id = v.assigned_employee_id
    WHERE a.true_water_source_score != w.subjective_quality_score
	    AND v.visit_count = 1
);
WITH error_count AS (
    SELECT 
        employee_name,
		COUNT(*) AS number_of_mistakes
    FROM Incorrect_records 
    GROUP BY employee_name
),
-- Step 1: Convert the high-error employees into the 'suspect_list' CTE
suspect_list AS (
    SELECT 
        employee_name,
        number_of_mistakes
    FROM error_count
    WHERE number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count)
)
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
employee_name,
location,
statements
FROM
Incorrect_records
WHERE
employee_name in (SELECT employee_name FROM suspect_list)
AND statements LIKE "%Suspicion%";

-- 1. Are there any specific provinces, or towns where some sources are more abundant?
-- This table assembles data from different tables into one to simplify analysis
CREATE VIEW combined_analysis_table AS (
		SELECT
		water_source.type_of_water_source,
		location.town_name,
		location.province_name,
		location.location_type,
		water_source.number_of_number_of_number_of_people_served,
		visits.time_in_queue,
		well_pollution.results
FROM
	visits
LEFT JOIN
	well_pollution
ON 	well_pollution.source_id = visits.source_id
INNER JOIN
	location
ON 	location.location_id = visits.location_id
INNER JOIN
	water_source
ON 	water_source.source_id = visits.source_id
WHERE
	visits.visit_count = 1);
    
    
WITH province_totals AS (-- This CTE calculates the population of each province
SELECT
province_name,
SUM(number_of_number_of_people_served) AS total_ppl_serv
FROM
combined_analysis_table
GROUP BY
province_name
)
SELECT
	ct.province_name,
	-- These case statements create columns for each type of source.
	-- The results are aggregated and percentages are calculated
	ROUND((SUM(CASE WHEN type_of_water_source = 'river'
	THEN number_of_number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
	THEN number_of_number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
	THEN number_of_number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
	THEN number_of_number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN type_of_water_source = 'well'
	THEN number_of_number_of_people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN
	province_totals pt ON ct.province_name = pt.province_name
GROUP BY
	ct.province_name
ORDER BY
	ct.province_name;
    
    
-- We want to see the town level granularity
CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (-- This CTE calculates the population of each town
-- Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(number_of_people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
		ct.province_name,
		ct.town_name,
		ROUND((SUM(CASE WHEN type_of_water_source = 'river'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN type_of_water_source = 'shared_tap'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
		ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
		ROUND((SUM(CASE WHEN type_of_water_source = 'tap_in_home_broken'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN type_of_water_source = 'well'
		THEN number_of_people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt 
ON 
	ct.province_name = tt.province_name 
    AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
	ct.province_name,
	ct.town_name
ORDER BY
	ct.town_name;

select *
FROM town_aggregated_water_access;

SELECT
province_name,
town_name,
ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
town_aggregated_water_access
WHERE ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) < 50
ORDER BY 1;

-- Practical Solutions
-- Here is a less commented one so it is easier to see how we design the Project_progress table:
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
Address VARCHAR(50),
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50),
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Date_of_completion DATE,
Comments TEXT
);

-- solutions inclunsivity in the where clause 
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
AND (well_pollution.results != 'Clean'
OR type_of_water_source IN ('tap_in_home_broken', 'river')
OR (type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30));

-- practical solns
SELECT
location.address,
location.town_name,
location.province_name,
water_source.source_id,
water_source.type_of_water_source,
CASE
		WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
		WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter' -- for contamninated wells respectively
		WHEN type_of_water_source = 'river' THEN 'Drill well' -- for rivers
		WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30 -- we use floor here to det the no of taps to be intalled nearby to reduce the queue time
		THEN CONCAT("Install ", FLOOR(visits.time_in_queue / 30), " taps nearby")
		WHEN type_of_water_source = 'tap_in_home_broken' THEN 'Diagnose local infrastructure'
	ELSE NULL
END AS Improvement
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
AND (well_pollution.results != 'Clean'
OR type_of_water_source IN ('tap_in_home_broken','river')
OR (type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30));


-- Populating the progress table for the engineers
INSERT INTO Project_progress (source_id, Address, Town, Province, Source_type, Improvement)
SELECT
water_source.source_id,
location.address,
location.town_name,
location.province_name,
water_source.type_of_water_source,
CASE
WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV and RO filter'
WHEN type_of_water_source = 'river' THEN 'Drill well'
WHEN type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30
THEN CONCAT("Install ", FLOOR(visits.time_in_queue / 30), " taps nearby")
WHEN type_of_water_source = 'tap_in_home_broken'
THEN 'Diagnose local infrastructure'
ELSE NULL
END AS Improvement
FROM
water_source
LEFT JOIN
well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
visits ON water_source.source_id = visits.source_id
INNER JOIN
location ON location.location_id = visits.location_id
WHERE
visits.visit_count = 1
AND (well_pollution.results != 'Clean'
OR type_of_water_source IN ('tap_in_home_broken','river')
OR (type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30));


SELECT *
FROM md_water_services.well_pollution
;

SELECT DISTINCT m.description,
	SUM(m.biological) AS total
FROM md_water_services.well_pollution m
WHERE m.description LIKE '%Bacteria%'
GROUP BY 1;

