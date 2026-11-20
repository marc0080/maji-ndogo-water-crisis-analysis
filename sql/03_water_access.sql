-- Analyzing locations

-- count records per town grouped by town name and province name
SELECT 
		province_name,
		town_name,
        COUNT(*) AS Records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name,town_name DESC;

-- records per location type ; rural vs urban 
SELECT 
    location_type,
    COUNT(*) AS num_records_per_loc_type,
    (COUNT(*) / SUM(COUNT(*)) OVER ()) * 100 AS pct_coverage
FROM location
GROUP BY location_type
ORDER BY num_records_per_loc_type DESC;
 
/* Some of the insights we gained from the location table;
1. Our entire country was properly canvassed, and our dataset represents the situation on the ground.
2. 60% of our water sources are in rural communities across Maji Ndogo. We need to keep this in mind when we make decisions.
*/

-- Diving into the sources

-- Key questions 
-- 1. How many people did we survey in total? = 27.62 million people surveyed
SELECT 
		SUM(number_of_people_served) AS Total_no_pple_serv
FROM water_source;

-- 2. How many wells, taps and rivers are there?
-- COUNT of each type of water source
SELECT 
		COUNT(type_of_water_source) AS num_type_of_water_source,
        type_of_water_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY num_type_of_water_source;

-- 3. How many people share particular types of water sources on average?
SELECT 
        type_of_water_source,
        ROUND(AVG(number_of_people_served)) AS avg_no_of_pple
FROM md_water_services.water_source
GROUP BY type_of_water_source
ORDER BY avg_no_of_pple DESC;

-- 4. How many people are getting water from each type of source? 
-- Total number of people served per water source
-- 43% of our people are using shared taps in their communities, 
-- and on average, we saw earlier, that 2000 people share one shared_tap.
SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS Total_no_of_ppl,
    ROUND(
        SUM(number_of_people_served) * 100.0 /
        SUM(SUM(number_of_people_served)) OVER (),
        0
    ) AS Pct_pple_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY Total_no_of_ppl DESC;

/* By adding tap_in_home and tap_in_home_broken together, we see that 31% of people have water infrastructure installed in their homes,
but 45% (14/31) of these taps are not working! 
This isn't the tap itself that is broken, but rather the infrastructure like treatment plants, reservoirs, pipes, and
pumps that serve these homes that are broken.
18% of people are using wells. 
But only 4916 out of 17383 are clean = 28%
*/

-- Start of a solution

-- Aggregated population served by each water source, calculated its percentage
-- of the total population, and ranked sources by population served to
-- prioritize water access interventions.

SELECT
    type_of_water_source,
    SUM(number_of_people_served) AS Total_no_of_ppl,
    ROUND(
        SUM(number_of_people_served) * 100.0 /
        SUM(SUM(number_of_people_served)) OVER (),
        0
    ) AS Pct_pple_per_source,
    RANK() OVER (
        ORDER BY SUM(number_of_people_served) DESC
    ) AS Rank_priority
FROM water_source
GROUP BY type_of_water_source
ORDER BY Total_no_of_ppl DESC;

-- Ranked improvable water sources within each source type by population served,
-- excluding functioning home taps to prioritize high-impact repair interventions.

SELECT
    source_id,
    type_of_water_source,
    number_of_people_served AS total_no_of_ppl,

    DENSE_RANK() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS rank_priority,

    ROW_NUMBER() OVER (
        PARTITION BY type_of_water_source
        ORDER BY number_of_people_served DESC
    ) AS unique_row_number

FROM water_source
WHERE type_of_water_source != 'tap_in_home'
ORDER BY total_no_of_ppl DESC;
