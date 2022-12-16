--Combining 12 Months data into year data by creating a CTE Table named "year_data"
WITH year_data AS 
(	SELECT *
	FROM [capstone_project].[dbo].[202110_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202111_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202112_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202201_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202202_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202203_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202204_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202205_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202206_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202207_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202208_cyclistic_tripdata]
	UNION
	SELECT *
	FROM [capstone_project].[dbo].[202209_cyclistic_tripdata]
), 
-- Clearing empty cells from the dataset using NOT and LIKE operators along with % sign to identify NULLS
year_data_nulls_cleaned AS
(	SELECT * 
	FROM year_data
	WHERE	start_station_name NOT LIKE '%NULL%'
		AND end_station_name  NOT LIKE '%NULL%'
		AND start_lat  NOT LIKE '%NULL%'
		AND start_lng  NOT LIKE '%NULL%'
		AND end_lat  NOT LIKE '%NULL%'
		AND end_lng NOT LIKE '%NULL%'
),
-- Remove ride_ids where length of ride_id > 16
-- Creating new column named total_minutes by using DATEDIFF command
-- Using CASE statement to change the day_of_week from numerical to string data
year_data_clean_ride_id AS
(	SELECT *,
		   DATEDIFF(MINUTE,started_at, ended_at) as total_minutes,
		   CASE
			  WHEN day_of_week = 1 THEN 'Sunday'
			  WHEN day_of_week = 2 THEN 'Monday'
			  WHEN day_of_week = 3 THEN 'Tuesday'
			  WHEN day_of_week = 4 THEN 'Wednesday'
			  WHEN day_of_week = 5 THEN 'Thursday'
			  WHEN day_of_week = 6 THEN 'Friday'
			  ELSE 'Saturday'
		   END AS day_of_week_name
	FROM year_data_nulls_cleaned
	WHERE LEN(ride_id) = 16
),
-- Remove rows where total_minutes < 1 (Taken as faulty data)
year_data_faulty_data_cleaned AS
(	SELECT *
	FROM year_data_clean_ride_id
	WHERE total_minutes >= 1
),
-- start_station_name and end_station_name cleaned by replacing '*' and 'temp' with blank spaces
clean_start_station_name AS
(	SELECT ride_id,
		   TRIM(REPLACE(REPLACE(start_station_name, '*', ''),'(Temp)', '')) AS start_station_name_clean
	FROM year_data_faulty_data_cleaned
),
clean_end_station_name AS
(	SELECT ride_id,
		   TRIM(REPLACE(REPLACE(end_station_name, '*', ''),'(Temp)', '')) AS end_station_name_clean
	FROM year_data_faulty_data_cleaned
),
-- Joining the previous two tables ON ride_id to give station table
station_name AS
(	SELECT s.ride_id, s.start_station_name_clean, e.end_station_name_clean 
	FROM clean_start_station_name s
	  JOIN clean_end_station_name e
	  ON s.ride_id = e.ride_id
),
--Joining clean station columns with the year_data_faulty_data_cleaned table ON ride_id
final_table AS
(	Select	s.ride_id, y.rideable_type, y.day_of_week_name, 
		CAST(y.started_at AS date) AS start_date, y.started_at, CAST(y.ended_at AS date) AS end_date, y.ended_at, y.total_minutes,
		s.start_station_name_clean, s.end_station_name_clean, y.member_casual, y.start_lat, y.start_lng, y.end_lat, y.end_lng 
	FROM year_data_faulty_data_cleaned y
	  JOIN station_name s
	  ON y.ride_id = s.ride_id
)
SELECT *
FROM final_table


