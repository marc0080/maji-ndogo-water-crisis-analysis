 --  From analysis to action
 
-- Weaving the threads of Maji Ndogo's narrative

-- Joining the pieces together 

-- Concerns : 
-- 1. Are there any specific provinces, or towns where some sources are more abundant?
-- 2. We identified that tap_in_home_broken taps are easy wins. 
-- Are there any towns where this is a particular problem?

-- We are interested in the type of water source, province name, location, number of people served, the time in queue and the results column from wells table that clasifies the quality of wells
-- We will create this view named combined analysis table

CREATE VIEW combined_analysis_table AS
-- This view assembles data from different tables into one to simplify analysis
SELECT
water_source.type_of_water_source AS source_type,
location.town_name,
location.province_name,
location.location_type,
water_source.number_of_people_served AS people_served,
visits.time_in_queue,
well_pollution.results
FROM
visits
LEFT JOIN
well_pollution
ON well_pollution.source_id = visits.source_id
INNER JOIN
location
ON location.location_id = visits.location_id
INNER JOIN
water_source
ON water_source.source_id = visits.source_id
WHERE
visits.visit_count = 1;

/* The last analysis

Building another pivot table! This time, we want to break down our data into provinces or towns and source types. If we understand where
the problems are, and what we need to improve at those locations, we can make an informed decision on where to send our repair teams.
*/


WITH province_totals AS (-- This CTE calculates the population of each province
	SELECT
		province_name,
		SUM(people_served) AS total_ppl_serv
	FROM
		combined_analysis_table
	GROUP BY
		province_name
	)

	SELECT
		ct.province_name,
	-- These case statements create columns for each type of source.
	-- The results are aggregated and percentages are calculated
		ROUND((SUM(CASE WHEN source_type = 'river'
			THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
		ROUND((SUM(CASE WHEN source_type = 'shared_tap'
			THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
			THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
		ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
			THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
		ROUND((SUM(CASE WHEN source_type = 'well'
			THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
	FROM
		combined_analysis_table ct
	JOIN
		province_totals pt ON ct.province_name = pt.province_name
	GROUP BY
		ct.province_name
	ORDER BY
		ct.province_name;
        
/* 1. Are there any specific provinces, or towns where some sources are more abundant?
Insights : Sokoto has the largest population of people drinking river water
			We should send our drilling equipment to Sokoto first, so people can drink safe filtered water from a well.
		The majority of water from Amanzi comes from taps, but half of these home taps don't work because the infrastructure is broken. We need to
send out engineering teams to look at the infrastructure in Amanzi first */

-- Aggregating by town name and by province 

CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS (-- This CTE calculates the population of each town
	-- Since there are two Harare towns, we have to group by province_name and town_name
	SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
	FROM combined_analysis_table
	GROUP BY province_name,town_name
)
SELECT
		ct.province_name,
		ct.town_name,
	ROUND((SUM(CASE WHEN source_type = 'river'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN source_type = 'shared_tap'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN source_type = 'well'
		THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN -- Since the town names are not unique, we have to join on a composite key
	town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name
GROUP BY -- We group by province first, then by town.
	ct.province_name,
	ct.town_name
ORDER BY
	ct.town_name;
    
-- From the Query below  only 3% of Amina's citizens have access to running tap water in their homes. 
-- More than half of the people in Amina have taps installed in their homes, but they are not working.
SELECT *
FROM town_aggregated_water_access
WHERE province_name = "Amanzi" AND town_name = "Amina";

/* Summary report

Insights

1. Most water sources are rural in Maji Ndogo.
2. 43% of our people are using shared taps. 2000 people often share one tap.
3. 31% of our population has water infrastructure in their homes, but within that group,
4. 45% face non-functional systems due to issues with pipes, pumps, and reservoirs. Towns like Amina, the rural parts of Amanzi, and a couple
of towns across Akatsi and Hawassa have broken infrastructure.
5. 18% of our people are using wells of which, but within that, only 28% are clean. These are mostly in Hawassa, Kilimani and Akatsi.
6. Our citizens often face long wait times for water, averaging more than 120 minutes:
• Queues are very long on Saturdays.
• Queues are longer in the mornings and evenings.
• Wednesdays and Sundays have the shortest queues.


 Plan:
1. We want to focus our efforts on improving the water sources that affect the most people.
	• Most people will benefit if we improve the shared taps first.
2. Wells are a good source of water, but many are contaminated. Fixing this will benefit a lot of people.
3. Fixing existing infrastructure will help many people. If they have running water again, they won't have to queue, thereby shorting queue times
for others. So we can solve two problems at once.
4. Installing taps in homes will stretch our resources too thin, so for now if the queue times are low, we won't improve that source.
5. Most water sources are in rural areas. We need to ensure our teams know this as this means they will have to make these repairs/upgrades in
rural areas where road conditions, supplies, and labour are harder challenges to overcome.
*/


-- A practical plan

-- Our final goal is to implement our plan in the database.
 -- create a table where our teams have the information they need to fix, upgrade and repair water sources. 
 -- Call this table Project_progress
 


 CREATE TABLE Project_progress (
	Project_id SERIAL PRIMARY KEY,  -- Unique key for sources in case we visit the same source more than once in the future.
	source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE, -- Each of the sources we want to improve should exist, and should refer to the source table. This ensures data integrity.
	Address VARCHAR(50), -- Street address
	Town VARCHAR(30),
	Province VARCHAR(30),
	Source_type VARCHAR(50),
	Improvement VARCHAR(50), -- What the engineers should do at that place
	Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
		/* * Source_status −− We want to limit the type of information engineers can give us, so we limit Source_status.
			− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
			− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.
		*/
	Date_of_completion DATE,  -- Engineers will add this the day the source has been upgraded.
	Comments TEXT -- Engineers can leave comments. We use a TEXT type that has no limit on char length
);


/* At a high level, the Improvements are as follows:
1. rivers → Drill wells
2. wells: if the well is contaminated with chemicals → Install RO filter
3. wells: if the well is contaminated with biological contaminants → Install UV and RO filter
4. shared_taps: if the queue is longer than 30 min (30 min and above) → Install X taps nearby where X number of taps is calculated using X
= FLOOR(time_in_queue / 30).
5. tap_in_home_broken → Diagnose local infrastructure */


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
	OR (type_of_water_source = 'shared_tap' AND visits.time_in_queue >= 30)
    );
        
        


 
 
