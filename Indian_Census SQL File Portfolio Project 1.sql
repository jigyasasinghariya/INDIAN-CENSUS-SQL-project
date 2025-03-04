create database Indian_Census_Database;
USE Indian_Census_Database;
show tables;

select * from Datashet1;
select * from Datashet2;

-- Note this data is based on year 2011 only

-- 01 Number of rows into our datashet;
select count(*) from Datashet1;
select count(*) from Datashet2;

-- 02 datashet for only two states Maharashtra & Uttar Pradesh
select * from Datashet1 where state in ('Maharashtra', 'Uttar Pradesh');

-- 03 Population of india
select sum(population) as Total_Population from Datashet2; 

-- 04 Avg Growth Of India
select avg(Growth) * 100 as Avg_Growth from datashet1;

-- 05 avg growth by states
select State, avg(Growth) * 100 as Avg_Growth from datashet1 group by state order by Avg_Growth desc;
select State, avg(Growth) as Avg_Growth from datashet1 group by state having state in ('Maharashtra', 'Uttar Pradesh') 
order by Avg_Growth desc;

-- 06 avg sex ratio:
select State, round(avg(Sex_Ratio), 0) as Avg_Sex_Ratio from datashet1 group by state order by Avg_Sex_Ratio desc;

-- 07 avg litracy rate 
select State, round(avg(Literacy), 0) as Avg_Literacy_rate from datashet1 
group by state having round(avg(Literacy), 0) >= 85 order by Avg_Literacy_rate desc;

-- 08 Top 3 states showing highest growth ratio
select state, avg(growth) * 100 as Avg_growth from datashet1 group by state order by Avg_growth desc limit 3;

-- 09 bottom 3 states showing Lowest sex ratio:
select state, round(avg(Sex_ratio), 0) as Avg_Sex_Ratio from datashet1 group by state order by Avg_Sex_Ratio asc limit 3;

-- 10 top and bottom 3 states in literacy state:
drop table if exists TopStates;
drop table if exists BottomStates;

-- TOP

create table TopStates(
state varchar(255),
TopState float
);

insert into TopStates
select state, round(avg(Literacy), 0) as Avg_Literacy from datashet1 group by state order by Avg_Literacy desc;

select * from TopStates order by TopState desc limit 3;
 
 -- OR
 
select state, round(avg(literacy), 0) as `Top States` from datashet1 group by state order by `Top States` desc limit 3;

-- BOTTOM --

create table BottomStates(
state varchar(255),
BottomState float
);

insert into BottomStates
select state, round(avg(Literacy), 0) as Avg_Literacy from datashet1 group by state order by Avg_Literacy asc;

select * from BottomStates order by BottomState asc limit 3;
 
-- OR
select state, round(Avg(Literacy), 0) as `Bottom States` from datashet1 group by state order by `Bottom States` asc limit 3;

-- Both Top and Bottom States:
select * from 
(
select * from (
select * from TopStates order by TopState desc limit 3) a
union
select * from (
select * from BottomStates order by BottomState asc limit 3) b
) c;


-- States starting with letter 'a' & 'b'--
select concat(concat_ws(" => ", District, State),'...') as `District And States` from datashet1 
where Lower(State) like "a%" or Lcase(State) like "b%";


select * from datashet1;
select * from datashet2;

-- joining both tables and male and female extract from the population
-- Total males and females

select d.state, sum(d.males) as total_males, sum(d.females) as total_females from
(
select c.district, c.state, round(c.population/(c.sex_ratio+1), 0) as Males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as females from
(select d1.district, d1.state, d1.sex_ratio/1000 as sex_ratio, d2.Population from datashet1 as d1
join datashet2 as d2 on d1.District = d2.District order by Population desc) c
) d
group by d.state;

-- Total litracy rate

select d1.District, d1.State, d1.Sex_Ratio, round(sum(d1.Literacy),0) as Total_Literacy, d2.Population from datashet1 as d1
join datashet2 as d2 on d1.District = d2.District group by State order by Total_Literacy desc;

-- OR

select state, sum(literate_people) as literate_people, sum(illiterate_people) as illiterate_people from
(
select district, state, round(literacy_ratio*Population, 0) as literate_people, round((1 - literacy_ratio)* population, 0) as illiterate_people from
(select d1.district, d1.state, d1.literacy/100 as literacy_ratio, d2.Population from datashet1 as d1
join datashet2 as d2 on d1.District = d2.District order by Population desc) c) x
group by state order by literate_people desc, illiterate_people desc;



-- populatioin in previous census

select Sum(Previous_Census_Population) as Previous_Census_Population, Sum(Current_Census_Population) as Current_Census_Population
from
(
select State, Sum(Previous_Census_Population) as Previous_Census_Population, Sum(Current_Census_Population) as Current_Census_Population from
(
select district, state, round(population/(1+growth),0) as Previous_Census_Population, Population as Current_Census_Population from
(select d1.district, d1.state, d1.growth as growth, d2.Population from datashet1 as d1
join datashet2 as d2 on d1.District = d2.District order by Population desc) c) x
group by State order by Previous_Census_Population desc, Current_Census_Population desc) y;

-- window
-- output top 3 district from each state with highest literacy rate.
 -- Type 01:
select District, State, Literacy from datashet1 order by Literacy desc limit 3;

-- Type 02: 
select District, State, Literacy from 
(select District, State, Literacy, rank() over(partition by State order by Literacy desc) rnk from datashet1)x
group by state order by Literacy desc;

-- Type 03 Most Efficient Result from this type...

select District, State, Literacy, rnk from 
(select District, State, Literacy, rank() over(partition by State order by Literacy desc) rnk from datashet1)x
where rnk in (1, 2, 3) order by State;

