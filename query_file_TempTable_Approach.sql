-- Combining 12 Months data into year data by creating a Temp Table named "#year_data"
DROP TABLE IF EXISTS #year_data;
CREATE TABLE #year_data
(    ride_id [NVARCHAR](255) NULL, 
	 rideable_type [NVARCHAR](255) NULL,
	 started_at [DATETIME] NULL,
	 ended_at [DATETIME] NULL,
	 ride_length [DATETIME] NULL,
	 day_of_week [FLOAT] NULL,
	 start_station_name [NVARCHAR](255) NULL,
	 start_station_id [NVARCHAR](255) NULL,
	 end_station_name [NVARCHAR](255) NULL,
	 end_station_id [NVARCHAR](255) NULL,
	 start_lat [FLOAT] NULL,
	 start_lng [FLOAT] NULL,
	 end_lat [FLOAT] NULL,
	 end_lng [FLOAT] NULL,
	 member_casual [NVARCHAR](255) NULL
)
-- Checking whether the temp table was successfully created
SELECT *
FROM #year_data

-- Inserting 12 months data into the temp table #year_data
INSERT INTO #year_data
SELECT *
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

--Create new table which only contains clean data
DROP TABLE IF EXISTS #year_data_final;
CREATE TABLE #year_data_final 
(    ride_id [NVARCHAR](255) NULL, 
	 rideable_type [NVARCHAR](255) NULL,
	 started_at [DATETIME] NULL,
	 ended_at [DATETIME] NULL,
	 ride_length [DATETIME] NULL,
	 day_of_week [FLOAT] NULL,
	 start_station_name [NVARCHAR](255) NULL,
	 start_station_id [NVARCHAR](255) NULL,
	 end_station_name [NVARCHAR](255) NULL,
	 end_station_id [NVARCHAR](255) NULL,
	 start_lat [FLOAT] NULL,
	 start_lng [FLOAT] NULL,
	 end_lat [FLOAT] NULL,
	 end_lng [FLOAT] NULL,
	 member_casual [NVARCHAR](255) NULL,
	 total_minutes [INT] NULL,
	 day_of_week_name [NVARCHAR](255) NULL,
	 start_station_name_clean [NVARCHAR](255) NULL,
	 end_station_name_clean [NVARCHAR](255) NULL,
	 start_date [NVARCHAR](255) NULL,
	 end_date [NVARCHAR](255) NULL,
	 month [NVARCHAR](255) NULL
)

-- Clearing empty cells from the dataset using NOT and LIKE operators along with % sign to identify NULLS
-- Remove ride_ids where length of ride_id > 16
-- Creating new column named total_minutes by using DATEDIFF command
-- Using CASE statement to change the day_of_week from numerical to string data
-- Remove rows where total_minutes < 1
-- start_station_name and end_station_name cleaned by replacing '*' and 'temp' with blank spaces
INSERT INTO #year_data_final
SELECT *, 
	   (DATEPART(HOUR,ride_length) * 60) + DATEPART(MINUTE,ride_length) AS total_minutes,
	   CASE
	      WHEN day_of_week = 1 THEN 'Sunday'
		  WHEN day_of_week = 2 THEN 'Monday'
		  WHEN day_of_week = 3 THEN 'Tuesday'
		  WHEN day_of_week = 4 THEN 'Wednesday'
		  WHEN day_of_week = 5 THEN 'Thursday'
		  WHEN day_of_week = 6 THEN 'Friday'
          ELSE 'Saturday'
       END AS day_of_week_name,
	   TRIM(REPLACE(REPLACE(start_station_name, '*', ''),'(Temp)', '')) AS start_station_name_clean,
	   TRIM(REPLACE(REPLACE(end_station_name, '*', ''),'(Temp)', '')) AS end_station_name_clean,
	   CAST(started_at AS date) AS start_date,
	   CAST(ended_at AS date) AS end_date,
	   CASE
		  WHEN MONTH(CAST(started_at AS date)) = 1 THEN 'Jan'
		  WHEN MONTH(CAST(started_at AS date)) = 2 THEN 'Feb'
		  WHEN MONTH(CAST(started_at AS date)) = 3 THEN 'Mar'
		  WHEN MONTH(CAST(started_at AS date)) = 4 THEN 'Apr'
		  WHEN MONTH(CAST(started_at AS date)) = 5 THEN 'May'
		  WHEN MONTH(CAST(started_at AS date)) = 6 THEN 'Jun'
		  WHEN MONTH(CAST(started_at AS date)) = 7 THEN 'Jul'
		  WHEN MONTH(CAST(started_at AS date)) = 8 THEN 'Aug'
		  WHEN MONTH(CAST(started_at AS date)) = 9 THEN 'Sep'
		  WHEN MONTH(CAST(started_at AS date)) = 10 THEN 'Oct'
		  WHEN MONTH(CAST(started_at AS date)) = 11 THEN 'Nov'
		  ELSE 'Dec'
		END AS Month
FROM #year_data
WHERE	start_station_name NOT LIKE '%NULL%'
	AND end_station_name  NOT LIKE '%NULL%'
    AND start_lat  NOT LIKE '%NULL%'
	AND start_lng  NOT LIKE '%NULL%'
	AND end_lat  NOT LIKE '%NULL%'
	AND end_lng NOT LIKE '%NULL%'
	AND LEN(ride_id) = 16
    AND (DATEPART(HOUR,ride_length) * 60) + DATEPART(MINUTE,ride_length) >= 1

SELECT *
FROM #year_data_final

DROP TABLE #year_data

--DATA EXPLORATION AND ANALYSIS

--Which usertype on average uses the bicycle more?
SELECT member_casual AS 'User type', 
       AVG(total_minutes) AS 'Average Trip Duration'
FROM #year_data_final
GROUP BY member_casual

--Which usertype uses the bicycle more in total (by minutes)?
SELECT member_casual AS 'User Type', 
	   SUM(total_minutes) AS 'Total Bicycle Usage'
FROM #year_data_final
GROUP BY member_casual

--Number of trips by each user type
SELECT member_casual AS 'User type',
	   COUNT(ride_id) AS 'No. of Trips'
FROM #year_data_final
GROUP BY member_casual

--Number of trips and Average Trip duration Data for each usertype for each day of the week
SELECT member_casual AS 'User Type',
	   day_of_week_name AS 'Day of Week',
	   COUNT(ride_id) AS 'No. of Trips',
	   AVG(total_minutes) AS 'Average Trip Duration'
FROM #year_data_final
GROUP BY member_casual, day_of_week_name
ORDER BY 'User Type', 'No. of Trips' DESC

--Number of Trips and Average Trip duration Data for each usertype for weekends and weekdays
SELECT member_casual AS 'User Type',
	   CASE
			WHEN day_of_week_name IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') THEN 'Weekday'
			ELSE 'Weekend'
	   END AS 'Weekday/Weekend',
	   COUNT(ride_id) AS 'No. of Trips',
	   AVG(total_minutes) AS 'Average Trip Duration'
FROM #year_data_final
GROUP BY member_casual,   CASE
			WHEN day_of_week_name IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') THEN 'Weekday'
			ELSE 'Weekend' END

-- Peak hours 
SELECT member_casual AS 'User Type',
	   day_of_week_name AS 'Day of Week',
	   COUNT(ride_id) AS 'No. of Trips'
FROM #year_data_final
WHERE (CAST(started_at AS time) >= '07:00:00' AND CAST(ended_at AS time) <= '09:00:00')
	OR (CAST(started_at AS time) >= '16:00:00' AND CAST(ended_at AS time) <= '19:00:00')
GROUP BY member_casual, day_of_week_name

-- Monthly Data
SELECT member_casual AS 'User Type',
	   month,
	   COUNT(ride_id) AS 'No. of Trips'
FROM #year_data_final
GROUP BY member_casual, month
ORDER BY member_casual, month

-- Difference in usage of different types of Bikes by each type of user 
SELECT member_casual AS 'User Type',
	   rideable_type AS 'Type of Bike',
	   COUNT(ride_id) AS 'No. of Trips'
FROM #year_data_final
GROUP BY member_casual, rideable_type

-- Find out total numbers of member or casual riders DEPARTING from respective stations (Top 10)
SELECT start_station_name_clean, COUNT(member_casual) AS 'No. of Casual Users'
FROM #year_data_final
WHERE member_casual = 'casual' 
GROUP BY start_station_name_clean 
ORDER BY 2 DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY
	   
SELECT start_station_name_clean, COUNT(member_casual) AS 'No. of Member Users'
FROM #year_data_final
WHERE member_casual = 'member' 
GROUP BY start_station_name_clean 
ORDER BY 2 DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY

-- GROUP departing station name with distinct Latitude and Longitude (CASUAL USERS)
SELECT DISTINCT start_station_name_clean, 
	   COUNT(member_casual) AS 'No. of Casual Users',
	   ROUND(AVG(start_lat),4) AS departure_latitude, 
	   Round(AVG(start_lng),4) AS departure_longitude
FROM #year_data_final
WHERE member_casual = 'casual' 
GROUP BY start_station_name_clean 
ORDER BY 2 DESC

-- GROUP departing station name with distinct Latitude and Longitude (MEMBERS)
SELECT DISTINCT start_station_name_clean, 
	   COUNT(member_casual) AS 'No. of Member Users',
	   ROUND(AVG(start_lat),4) AS departure_latitude, 
	   Round(AVG(start_lng),4) AS departure_longitude
FROM #year_data_final
WHERE member_casual = 'member' 
GROUP BY start_station_name_clean 
ORDER BY 2 DESC

-- Find out total numbers of member or casual riders ARRIVING at respective stations (Top 10)
SELECT end_station_name_clean, COUNT(member_casual) AS 'No. of Casual Users'
FROM #year_data_final
WHERE member_casual = 'casual' 
GROUP BY end_station_name_clean 
ORDER BY 2 DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY
	   
SELECT end_station_name_clean, COUNT(member_casual) AS 'No. of Member Users'
FROM #year_data_final
WHERE member_casual = 'member' 
GROUP BY end_station_name_clean 
ORDER BY 2 DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY

-- GROUP arriving station name with distinct Latitude and Longitude (CASUAL USERS)
SELECT DISTINCT end_station_name_clean, 
	   COUNT(member_casual) AS 'No. of Casual Users',
	   ROUND(AVG(end_lat),4) AS arrival_latitude, 
	   Round(AVG(end_lng),4) AS arrival_longitude
FROM #year_data_final
WHERE member_casual = 'casual' 
GROUP BY end_station_name_clean 
ORDER BY 2 DESC

-- GROUP departing station name with distinct Latitude and Longitude (MEMBERS)
SELECT DISTINCT end_station_name_clean, 
	   COUNT(member_casual) AS 'No. of Member Users',
	   ROUND(AVG(end_lat),4) AS arrival_latitude, 
	   Round(AVG(end_lng),4) AS arrival_longitude
FROM #year_data_final
WHERE member_casual = 'member' 
GROUP BY end_station_name_clean 
ORDER BY 2 DESC

SELECT *
FROM #year_data
WHERE MONTH(CAST(started_at AS date)) = 8