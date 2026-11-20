-- 1. Get to know our data Exploring the foundational tables and their structure.

SHOW TABLES; -- we've got 8 tables 

-- So let's have a look at one of these tables, 
-- Let's use location so we can use that killer query With a limit of 5 rows.
SELECT * FROM location 
LIMIT 5;
/* So we can see that this table has information on a specific location, with an address,
 the province and town the location is in, and if it's in a city (Urban) or not.*/

-- Let's have a look at visits table and the water source respectively
SELECT * FROM visits 
LIMIT 5;
SELECT * FROM water_source
LIMIT 5;

-- 2. Dive into the water sources: 
-- We need to understand the types of water sources we're dealing with. 
SELECT distinct type_of_water_source 
FROM water_source;

-- 3. Unpacking the visits: Discovering the visits patterns
-- We have a table in our database that logs the visits made to different water sources.
SELECT * FROM visits 
LIMIT 5;
-- Checking for time in queue greater than 8 hours 
SELECT * FROM visits
WHERE time_in_queue > 420;
-- linking them with type of water source 
SELECT v.source_id AS source_id,
	   v.time_in_queue AS queue_time_mins, 
       w.type_of_water_source AS water_source
FROM visits v
JOIN water_source w 
ON v.source_id = w.source_id
WHERE time_in_queue > 420;

/* 4. Assess the quality of water sources:
The quality of our water sources is the whole point of this survey. 
Records where the subject_quality_score is 10 -- only looking for home taps -- and where the source
was visited a second tim */

SELECT * 
	FROM water_quality
WHERE subjective_quality_score = 10  AND visit_count > 1; 

-- 5. Investigate pollution issues:
-- checking first few rows
SELECT * 
FROM well_pollution
LIMIT 10;
-- Data cleaning in this well pollution table
SELECT
*
FROM
well_pollution
WHERE
description LIKE "Clean_%"
;
/* Case 1a: Update descriptions that mistakenly mention `Clean Bacteria: E. coli` to `Bacteria: E. coli`*/
-- Disabling Safe update
SET SQL_SAFE_UPDATES = 0;
UPDATE
well_pollution
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';

/* Case 1b: Update the descriptions that mistakenly mention 
`Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia */

UPDATE
well_pollution
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description = 'Clean Bacteria: Giardia Lamblia';

-- Case 2: Update the `result` to `Contaminated: Biological` where
-- `biological` is greater than 0.01 plus current results is `Clean`
UPDATE
well_pollution
SET
results = 'Contaminated
: Biological'
WHERE
biological > 0.01 AND results = 'Clean';

-- verification 
SELECT *
FROM well_pollution
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);


