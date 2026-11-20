-- Analysing queues

-- Some of the things I think are worth looking at:

-- 1. How long did the survey take? = 924 Days

SELECT
    MIN(time_of_record) AS survey_start,
    MAX(time_of_record) AS survey_end,
    TIMESTAMPDIFF(DAY, MIN(time_of_record), MAX(time_of_record)) AS survey_duration_days
FROM visits;

-- 2. What is the average total queue time for water?
-- The average queue time for water is 123min Excluding where time_in_queue =0

SELECT ROUND(AVG(NULLIF(time_in_queue,0)),0) AS average_queue_time_for_water
FROM visits;

-- 3. What is the average queue time on different days?

-- Avg queue time for water by days of week
SELECT 
		DAYNAME(time_of_record) AS Day_of_week,
		ROUND(AVG(NULLIF(time_in_queue,0)),0) AS average_queue_time_for_water
FROM visits
GROUP BY DAYNAME(time_of_record)
ORDER BY 2 desc;

-- Avg queue time for water by hour of day
SELECT 
        TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
        ROUND(AVG(NULLIF(time_in_queue,0)),0) AS average_queue_time_for_water
FROM visits
GROUP BY 1
ORDER BY 2 desc;


-- 4. How can we communicate this information efficiently? 
-- By creating a pivot table to have a visual on the avegage queueing time on a daily basis

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

/* Insights 
1. Queues are very long on a Monday morning and Monday evening as people rush to get water.
2. Wednesday has the lowest queue times, but long queues on Wednesday evening.
3. People have to queue pretty much twice as long on Saturdays compared to the weekdays. It looks like people spend their Saturdays queueing
for water, perhaps for the week's supply?
4. The shortest queues are on Sundays, and this is a cultural thing. The people of Maji Ndogo prioritise family and religion, so Sundays are spent
with family and friends*/










