/*******  Integrating the Auditor's report *****/
use  md_water_services;
DROP TABLE IF EXISTS `auditor_report`;
CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);

select 
	*
from 
	auditor_report
limit 5;


/*******
1. Is there a difference in the scores?
2. If so, are there patterns?

For the first question, 
we will have to compare the quality scores in the water_quality table to the auditor's scores.
The auditor_report table used location_id, but the quality scores table only has a record_id we can use. 
The visits table links location_id and record_id, so we can link the auditor_report table and water_quality using the visits table.
*******/

/**
So first, grab the location_id and true_water_source_score columns from auditor_report. */

SELECT 
    location_id, true_water_source_score
FROM
    auditor_report;
    
/** Now, we join the visits table to the auditor_report table. 
Make sure to grab subjective_quality_score, record_id and location_id.

*/


SELECT 
    ar.location_id as audit_location,
    ar.true_water_source_score,
    v.location_id as visit_location,
    v.record_id,
    wq.subjective_quality_score
FROM
    auditor_report as ar
join
	visits as v
on v.location_id=ar.location_id
left join
	water_quality as wq
on
	wq.record_id=v.record_id;
    
    
/**** It doesn't matter if your columns are in a different format, 
because we are about to clean this up a bit. Since it is a duplicate,
 we can drop one of the location_id columns. 
Let's leave record_id and rename the scores to surveyor_score and auditor_score
 to make it clear which scores
we're looking at in the results set. **/


SELECT 
    ar.location_id as location,
    v.record_id,
    ar.true_water_source_score as auditor_score,    
    wq.subjective_quality_score as employee_score
FROM
    auditor_report as ar
join
	visits as v
on v.location_id=ar.location_id
left join
	water_quality as wq
on
	wq.record_id=v.record_id;
    
 /*** analysis:
Checking if the auditor's and exployees' scores agree.
*/ 
 
create view AE_Agree as
SELECT 
    ar.location_id as location,
    v.record_id,
    ar.true_water_source_score as auditor_score,    
    wq.subjective_quality_score as employee_score
FROM
    auditor_report as ar
join
	visits as v
on v.location_id=ar.location_id
left join
	water_quality as wq
on
	wq.record_id=v.record_id
    
where ar.true_water_source_score=wq.subjective_quality_score;


-- counting # of Rows
select count(*) as "# of records that agree" 
from
	ae_agree;
    
-- removing duplicates

create view AE_Agree2 as
SELECT 
    ar.location_id as location,
    v.record_id,
    ar.true_water_source_score as auditor_score,    
    wq.subjective_quality_score as employee_score
FROM
    auditor_report as ar
join
	visits as v
on v.location_id=ar.location_id
left join
	water_quality as wq
on
	wq.record_id=v.record_id
    
where ar.true_water_source_score=wq.subjective_quality_score
and
	v.visit_count=1;


-- counting # of Rows
select count(*) as "# of records that agree2" 
from
	ae_agree2;
    
    
-- incorrect records
create view Disagree as
SELECT 
    ar.location_id as location,
    v.record_id,
    ar.true_water_source_score as auditor_score,    
    wq.subjective_quality_score as employee_score
FROM
    auditor_report as ar
join
	visits as v
on v.location_id=ar.location_id
left join
	water_quality as wq
on
	wq.record_id=v.record_id
    
where
	ar.true_water_source_score<>wq.subjective_quality_score
and
	v.visit_count=1;


-- counting # of Rows
select count(*) as "# of records that disagree" 
from
	disagree;
    
/*** Since we used some of this data in our previous analyses, 
we need to make sure those results are still valid, now we know some of them are incorrect.
We didn't use the scores that much, but we relied a lot on the type_of_water_source, 
so let's check if there are any errors there.
So, to do this, we need to grab the type_of_water_source column 
from the water_source table and call it survey_source, using the
source_id column to JOIN.
 Also select the type_of_water_source from the auditor_report table, 
and call it auditor_source. */


SELECT 
    ar.location_id as location,
    v.record_id,
    ws.type_of_water_source as survey_source,
    ar.true_water_source_score as auditor_score,    
    wq.subjective_quality_score as employee_score,
    ws.type_of_water_source as auditor_source
FROM
    auditor_report as ar
join
	visits as v
on v.location_id=ar.location_id
left join
	water_quality as wq
on
	wq.record_id=v.record_id
join
	water_source as ws
on
	ws.source_id=v.source_id
    
where
	ar.true_water_source_score<>wq.subjective_quality_score
and
	v.visit_count=1;
    
/** In either case, the employees are the source of the errors, 
so let's JOIN the assigned_employee_id for all the people on our list from the visits
table to our query. Remember, 
our query shows the shows the 102 incorrect records, so when we join the employee data, we can see which
employees made these incorrect records.  ***/

SELECT 
    ar.location_id as location,
    v.record_id,
    e.assigned_employee_id,
    ws.type_of_water_source as survey_source,
    ar.true_water_source_score as auditor_score,    
    wq.subjective_quality_score as employee_score,
    ws.type_of_water_source as auditor_source
FROM
    auditor_report as ar
join
	visits as v
on v.location_id=ar.location_id
left join
	water_quality as wq
on
	wq.record_id=v.record_id
join
	water_source as ws
on
	ws.source_id=v.source_id
join
	employee as e
on
	e.assigned_employee_id=v.assigned_employee_id   
    
where
	ar.true_water_source_score<>wq.subjective_quality_score
and
	v.visit_count=1;
    

create view Incorrect_records as 
SELECT 
    ar.location_id as location,
    v.record_id,
    e.assigned_employee_id,
    e.employee_name,
    ar.true_water_source_score as auditor_score,    
    wq.subjective_quality_score as employee_score,
    ws.type_of_water_source as auditor_source
FROM
    auditor_report as ar
join
	visits as v
on v.location_id=ar.location_id
left join
	water_quality as wq
on
	wq.record_id=v.record_id
join
	water_source as ws
on
	ws.source_id=v.source_id
join
	employee as e
on
	e.assigned_employee_id=v.assigned_employee_id   
    
where
	ar.true_water_source_score<>wq.subjective_quality_score
and
	v.visit_count=1;
    
-- summaries
select
	employee_name,
    count(location) as "number_of_mistakes"
from 
	incorrect_records
group by 1
order by 2 desc;


create view error_Counts as
select
	employee_name,
    count(location) as "number_of_mistakes"
from 
	incorrect_records
group by 1
order by 2 desc;

-- Returning the workers above average 
create view suspect_list as
select
	employee_name,
    number_of_mistakes
from 
	error_counts
where
	number_of_mistakes>(
    select avg(number_of_mistakes)
    from 
		error_counts);
        
select 
	distinct sl.employee_name,
	sl.number_of_mistakes,
    ar.statements
from
	auditor_report as ar
join incorrect_records as ir
	on ar.location_id=ir.location
join suspect_list as sl
on sl.employee_name=ir.employee_name
where ar.statements like "%cash%";



	




