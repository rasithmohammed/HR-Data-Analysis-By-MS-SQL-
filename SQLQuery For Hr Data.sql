CREATE DATABASE hr;

USE hr;

select * 
from hr_data;

select 
 gender
 
 from hr_data

update hr_data
set termdate = format(convert(datetime, left(termdate, 19), 120), 'yyyy-MM-dd');

alter table hr_data
add new_termdate date;

--Copy convert time values from termdate to new_termdate

update hr_data
set new_termdate = case 
  when termdate is not null and isdate(termdate) = 1 then cast (termdate as datetime) else null end;

-- create new column "age"
alter table hr_data
add age varchar(50);

--pouplate new column with age 

update hr_data
set age= datediff(year, birthdate, getdate());

select * 
from hr_data

--What's the age distribution in the company?
-- age distrbution 
select 
min(age) as youngest,
max(age) as oldest
from hr_data

--age group by distribution
select age_group,
count(*) as count
from 
 (select 
 case
 when age <=21 and age <=30 then '21 to 30'
 when age <=31 and age <=40 then '31 to 40'
 when age <=41 and age <=50 then '41 to 50'
 else '50+'
  end as age_group
  from hr_data
  where new_termdate is null
  )
  as sub_query 
  group by age_group
  order by age_group

--age group by gender
select age_group,
gender,
count(*) as count
from 
 (select 
 case
 when age <=21 and age <=30 then '21 to 30'
 when age <=31 and age <=40 then '31 to 40'
 when age <=41 and age <=50 then '41 to 50'
 else '50+'
  end as age_group,gender
  from hr_data
  where new_termdate is null
  )
  as sub_query 
  group by age_group,gender
  order by age_group,gender

  --what's gender breakdown in the company?
  select 
  gender,
  count(gender) as count
  from hr_data
  where new_termdate is null
  group by gender
  order by gender asc;

  --how dose gender very across departments and job titles?
   select
  department,
  gender,
  count(gender) as count                                                    
  from hr_data
  where new_termdate is null
  group by department, gender
  order by department, gender asc;

  --job titles
    select
  department,
  jobtitle,
  gender,
  count(gender) as count                                                   
  from hr_data
  where new_termdate is null
  group by department,  jobtitle, gender
  order by department,  jobtitle, gender asc;

  --what's the race distribution in the comapny?
  select
  race,
  count(*) as count
  from hr_data
  where new_termdate is null
  group by race
  order by count desc;

  --what's the average length of empoleyment in the company?
  select 
  avg(datediff(year, hire_date, new_termdate)) as tenure
  from hr_data
  where new_termdate is not null and new_termdate<= getdate()

  --which department has the highest turnover rate?
  --get total count
  --get terminated count
  --terminated count\total count
select 
   department,
   total_count,
   terminated_count,
  (round((cast (terminated_count as float)/total_count),2))*100 as turnover_rate
from
   (select 
  department,
  count(*) as total_count,
  sum (case
       when new_termdate is not null and new_termdate<=getdate() then 1
	   end
	   ) as terminated_count
from hr_data
group by department
) as subquery
order by turnover_rate desc;

--what is the tenure distribution for each empolyment?
 select 
   department,
  avg(datediff(year, hire_date, new_termdate)) as tenure
  from hr_data
  where new_termdate is not null and new_termdate<= getdate()
  group by department
  order by tenure desc

--how many employee work remotly for each departments
select
 location,
 count(*) as count
 from hr_data
 where new_termdate is null
 group by location;

 --what's the distribution of employees across differnt states?
 select
 location_state,
 count(*) as count
 from hr_data
 where new_termdate is null
 group by location_state;

 --how are job title distributed in the company?
 select 
 jobtitle,
 count(*) as count
 from hr_data
 where new_termdate is null
 group by jobtitle
 order by count;

 --how have employee hire counts varied over time?
 --calculate hire 
 --calculate termination
 --(hires-termination) hire percent hire change
select 
    hire_year,
	hires,
	terminations,
	hires-terminations as net_change,
	(round(cast(hires-terminations as float)/hires,2))*100 as percent_hire_change
from(
   select
      year(hire_date) as hire_year,
      count(*) as hires,
      sum( case
            when new_termdate is not null and new_termdate <= getdate() then 1 else 0
			end
			)as terminations
      from hr_data
      group by year(hire_date)
) as subquery
order by percent_hire_change asc;



       







