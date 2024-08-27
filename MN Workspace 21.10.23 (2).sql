-- MD part 2
show databases;
use md_water_services;

-- 
select * 
from employee
limit 5;

-- Cleaning 
select
lower(concat(replace(employee_name,(" "),"."),"@ndogowater.gov"))
from employee
limit 4;

-- replacing the email column
update employee
set email=lower(concat(replace(employee_name,(" "),"."),"@ndogowater.gov"));

Select email
from employee
limit 5;
-- cleaning phone_numbers
select lengtH(phone_number)
FROM 	EMPLOYEE
LIMIT 10;

select phone_number
FROM 	EMPLOYEE
LIMIT 10;

select length(trim(phone_number))
FROM 	EMPLOYEE
LIMIT 10;


-- updating the phone col
update employee
set phone_number=trim(phone_number);

-- wherre employees live
select town_name,count(assigned_employee_id) as n
from employee
group by 1
order by 2 desc;


-- honouring employees
select max(visit_count)
from visits
limit 5;

/* Pres. Naledi has asked we send out an email or message congratulating the top 3 field surveyors. 
So let's use the database to get the employee_ids and use those to get the names, 
email and phone numbers of the three field surveyors with the most location visits.*/

select employee_name,email,phone_number
from employee
where assigned_employee_id in (

select assigned_employee_id
from (
select assigned_employee_id,sum(visit_count) as No_of_Visits
from visits 
group by 1
order by 2 desc
limit 3) as v);


-- Create a query that counts the number of records per town
select town_name,count(*) as " No. of records" 
from location
group by 1
order by 2 desc;

-- Now count the records per province.
select province_name,count(*) as " No. of records" 
from location
group by 1
order by 2 desc;

/* Can you find a way to do the following:
1. Create a result set showing:
• province_name
• town_name
• An aggregated count of records for each town (consider naming this records_per_town).
• Ensure your data is grouped by both province_name and town_name.
2. Order your results primarily by province_name. 
Within each province,
 further sort the towns by their record counts in descending order */

select province_name,town_name,count(*) as records_per_town
from location
group by 1,2
order by 1,3 desc;

--  number of records for each location type
select location_type,count(*) as records_per_location_type,count(*)/(select count(*) from location)*100 as "%" 
from location
group by 1
order by 2 desc;


-- Diving into the sources
select *
from water_source
limit 10;

select distinct type_of_water_source
from water_source;


--  How many people did we survey in total?
select sum(number_of_people_served) as "Total People Surveyed"
from water_source;

--  How many wells, taps and rivers are there?
select type_of_water_source,count(source_id)
from water_source
group  by 1
order by 2 desc;

-- How many people share particular types of water sources on average?
select type_of_water_source,round(avg(number_of_people_served),0)
from water_source
group  by 1
order by 2 desc;

-- 4. How many people are getting water from each type of source
select type_of_water_source,sum(number_of_people_served) as " Total No. of People" ,round(sum(number_of_people_served)/(select 
sum(number_of_people_served)
from water_source)*100,0) as "%"
from water_source
group  by 1
order by 2 desc;



-- rankings
select source_id,type_of_water_source,
sum(number_of_people_served) as number_served,
rank () over (order by sum(number_of_people_served) desc) as "Ranking"
from water_source
group by 1,2
order by 2 desc;


select type_of_water_source,
sum(number_of_people_served) as number_served,
rank () over (order by sum(number_of_people_served) desc) as "Ranking"
from water_source
group by 1
order by 2 desc;


-- Analysing queues
select * 
from visits
limit 3;

-- How long did the survey take?
select * 
from data_dictionary
where table_name like "visits";


-- How long did the survey take?
select datediff(max(time_of_record),min(time_of_record)) as " Days it took to do the survey"
from visits;


-- What is the average total queue time for water?
select avg(time_in_queue) as  "average total queue time for water"
from visits
where time_in_queue is not null
and  time_in_queue <>0;

-- What is the average queue time on different days?
select dayname(time_of_record),round(avg(time_in_queue),0) as  "average total queue time for water"
from visits
where time_in_queue is not null
and  time_in_queue <>0
group by 1
order by 2 desc;



-- What is the average queue time on different hour_of_day?
select HOUR(time_of_record) AS hour_of_day,round(avg(time_in_queue),0) as  "average total queue time for water"
from visits
where time_in_queue is not null
and  time_in_queue <>0
group by 1
order by 1 ;


select TIME_FORMAT(TIME(time_of_record), '%H:00')  AS hour_of_day,round(avg(time_in_queue),0) as  "average total queue time for water"
from visits
where time_in_queue is not null
and  time_in_queue <>0
group by 1
order by 1 ;



-- pivot table
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
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
ELSE NULL
END
),0) AS Tuesday,

-- Wednesday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
ELSE NULL
END
),0) AS Wednesday,

-- Thursday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
ELSE NULL
END
),0) AS Thursday,

-- friday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
ELSE NULL
END
),0) AS Friday,

-- saturday
ROUND(AVG(
CASE
WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
ELSE NULL
END
),0) AS saturday
FROM
visits
WHERE
time_in_queue != 0 -- this excludes other sources with 0 queue times
GROUP BY
hour_of_day
ORDER BY
hour_of_day;



/* Which SQL query will produce the date format "DD Month YYYY" 
from the time_of_record column in the visits table, as a single column? 
Note: Monthname() acts in a similar way to DAYNAME(). */

