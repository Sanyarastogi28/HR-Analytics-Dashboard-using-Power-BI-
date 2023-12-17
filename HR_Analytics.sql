
--## Data Cleaning
--## Here, I have added a column to the table which has value 1 or 0 depending if attrition is yes or no ,
--## as by summing and counting this column, we would get better insights about attrition

alter table dbo.HR_Analytics
add attrition_value int

update dbo.HR_Analytics set attrition_value = 
case 
when attrition = 'Yes' then 1
else 0
end from dbo.HR_Analytics

select * from dbo.HR_Analytics

--##We had a extra column in our table which has blanks values and column isn't of much use for us for visualizaton purposes.

alter table dbo.HR_Analytics drop column YearsWithCurrManager

--##Lets check if we have any duplicate rows in our table.
select empid,ROW_NUMBER() over (partition by empid order by empid) as num_rows
from dbo.HR_Analytics
order by 2 desc

--##So the data has some duplicate rows in it, so I decided to first import all distinct rows in another table and then
--##I truncated our original table and then added the distinct rows into the table.
--##NOTE:--one can easily do all these steps within excel and power bi , but I still chose to do all the work via SQL and just 
--## use these results in power bi to make visualizations ,just to get most out of SQL.

select distinct * into dbo.HR2
from dbo.HR_Analytics

truncate table dbo.HR_analytics

insert into dbo.HR_Analytics select * from dbo.HR2;

drop table dbo.HR2

select empid,ROW_NUMBER() over (partition by empid order by empid) as num_rows
from dbo.HR_Analytics
order by 2 desc
---##We can see that duplicates are now removed.

--##Here, the data has some Travel_Rarely and TravelRarely as two different values in the Buisness Travel column,so I decided to update the values

select BusinessTravel  from dbo.HR_Analytics
group  by BusinessTravel

update dbo.HR_Analytics
set BusinessTravel='Travel_Rarely'
where BusinessTravel='TravelRarely'

select BusinessTravel  from dbo.HR_Analytics
group  by BusinessTravel


--##Our Data is now cleaned,The Next step is to do some analysis on data ,
--##Here ,I have created different views from our data which includes Attrition by Age,Department,Education Field,Job Role,Salary,Years at company ,Gender and overtime.
--##We can further import these saved views in power bi, and do the analysis from there.
--##NOTE:--If the following view are already created one first needs to run the drop view command and then the following queries.

--Table for Attrition vs Age
drop view if exists AttVSAge

create view AttVSAge as(
select AgeGroup,sum(Attrition_value) as [number of employee attrited] ,count(agegroup)as [Employee count],(convert(float,sum(Attrition_value))/convert(float,count(AgeGroup)) )*100 as Attrition_percentage
from dbo.HR_Analytics
group by AgeGroup)

select * from AttVSAge

--Table for Attrition by department
drop view if exists AttVSDep

create view AttVSDep as
select Department,sum(Attrition_value) as [number of employee attrited] ,count(Department)as TotalEmployeePerDepartment,(convert(float,sum(Attrition_value))/convert(float,count(Department)) )*100 as Attrition_percentage
from dbo.HR_Analytics
group by Department

select * from AttVSDep

--Table for Attrition vs Educational field
drop view if exists AttVSEdu

create view AttVSEdu as
select EducationField,sum(Attrition_value) as [number of employee attrited] ,count(EducationField)as TotalEmployeePerEducation
,(convert(float,sum(Attrition_value))/convert(float,count(EducationField)) )*100 as Attrition_percentage
from dbo.HR_Analytics
group by EducationField

select * from AttVSEdu

--Table for Attrition vs Job role
drop view if exists AttVSJob

create view AttVSJob as
select JobRole,sum(Attrition_value) as [number of employee attrited] ,count(JobRole)as TotalEmployeePerJobrole
,(convert(float,sum(Attrition_value))/convert(float,count(JobRole)) )*100 as Attrition_percentage
from dbo.HR_Analytics
group by JobRole

select * from AttVSJob

--Table for Attrition vs Salary slab
drop view if exists AttVSSal

create view AttVSSal as
select SalarySlab,sum(Attrition_value) as [number of employee attrited] ,count(SalarySlab)as TotalEmployeePerSalarySlab
,(convert(float,sum(Attrition_value))/convert(float,count(SalarySlab)) )*100 as Attrition_percentage
from dbo.HR_Analytics
group by SalarySlab

select * from AttVSSal

--Table for Attrition vs Years at company
drop view if exists AttVSYrs

create view AttVSYrs as
select YearsAtCompany,sum(Attrition_value) as [number of employee attrited] ,count(YearsAtCompany)as TotalEmployeePerYearsAtCompany
,(convert(float,sum(Attrition_value))/convert(float,count(YearsAtCompany)) )*100 as Attrition_percentage
from dbo.HR_Analytics
group by YearsAtCompany

select * from AttVSYrs

--Table for Attrition by overtime
drop view if exists AttVSOverT

create view AttVSOverT as
select OverTime,sum(Attrition_value) as [number of employee attrited] ,count(OverTime)as TotalEmployeePerOverTime
,(convert(float,sum(Attrition_value))/convert(float,count(OverTime)) )*100 as Attrition_percentage
from dbo.HR_Analytics
group by OverTime

select * from AttVSOverT

--Table for Attrition vs Gender
drop view if exists AttVSGen

create view AttVSGen as
select gender,sum(Attrition_value) as [number of employee attrited] ,count(gender)as TotalEmployeePerGender
,(convert(float,sum(Attrition_value))/convert(float,count(Gender)) )*100 as Attrition_percentage
from dbo.HR_Analytics
group by Gender

select * from AttVSGen


--##one can use the cte here too,

with cte (AgeGroup,emp_attri,count_age)as(
select AgeGroup,sum(Attrition_value) as [emp_attri] ,count(agegroup)
from dbo.HR_Analytics
group by AgeGroup)
select *,(convert(float,emp_attri)/convert(float,count_age))*100
from cte
order by emp_attri desc
