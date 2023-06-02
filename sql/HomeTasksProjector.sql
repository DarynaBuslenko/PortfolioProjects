--Departments with the highest average total payments 

Select department_title, avg (total_payments) as average_total_payments
From `grand-solstice-351606.projector.payroll`
Group by department_title
Order by average_total_payments DESC
LIMIT 20; 

--Share of base pay in total payments

Select SUM (base_pay) / SUM (total_payments) * 100 as Share_of_base_pay_in_total_paym
From `grand-solstice-351606.projector.payroll`;

--Top 20 departments with the most entries by the range of base pay

Select count(index) as index_quantity,
CASE
  When base_pay < 50000 then 'less then 50 k'
  When base_pay Between 50000 and 80000 then '50-80k'
  When base_pay Between 80001 and 100000 then '80-100k'
  When base_pay Between 100001 and 130000 then '100-130k'
  When base_pay > 130000 then 'more then 130k'
  End AS RangeOfBasePay
From grand-solstice-351606.projector.payroll
Where department_title in (select department_title from (Select department_title,  count(index) as index_quantity
From grand-solstice-351606.projector.payroll
Group by department_title
order by index_quantity DESC
Limit 20))
Group by 2
order by index_quantity DESC
Limit 20;

--How total payments changed annually for different employment types 

Select et.employment_type, pr.year, SUM (pr.total_payments) as total_payments
From grand-solstice-351606.projector.payroll as pr
Join grand-solstice-351606.projector.employment_types as et
on pr.index = et.index
group by et.employment_type, pr.year
order by et.employment_type DESC, pr.year ASC;

______

--Users from what countries we have

Select country, count (user_id) as QtyOfusers
From `grand-solstice-351606.final_task.event_level_sample`
Group by 1
Order by 2 desc;

--Shows from which devices users access the site

Select count (user_id) as QtyOfusers, device
From `grand-solstice-351606.final_task.event_level_sample`
Group by 2
Order by 1 desc;

--Shows the traffic 

Select traffic_source, count (user_id) as QtyOfusers
From `grand-solstice-351606.final_task.event_level_sample`
Group by 1
Order by 2 desc;

--Products that users buy most often and at what price

Select item_name, price, count (event_name)
From `grand-solstice-351606.final_task.event_level_sample`
Where event_name = "purchase"
Group by 1, 2
Order by 3 desc
Limit 50;

--Shows the test groups we have and how many users got into each group

SELECT ab.ab_groups, count (distinct ab.user_id) as quantOfUserID
FROM `grand-solstice-351606.final_task.ab_labels` ab
RIGHT JOIN `grand-solstice-351606.final_task.event_level_sample` ft
ON ab.user_id = ft.user_id
GROUP BY 1
Order by 2 desc;

--Visits to the site (paid traffic)

Select traffic_source, event_name, count (user_id) as QtyOfUsers, event_date
From `grand-solstice-351606.final_task.event_level_sample`
Where event_name ="session_start" and traffic_source = "paid"
Group by 1, 2, 4
ORDER BY 4;

--Visits to the site (direct traffic)

Select traffic_source, event_name, count (user_id) as QtyOfUsers, event_date
From `grand-solstice-351606.final_task.event_level_sample`
Where event_name ="session_start" and traffic_source = "direct"
Group by 1, 2, 4
ORDER BY 4;