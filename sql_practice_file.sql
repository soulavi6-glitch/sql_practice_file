select e.department, 
count(distinct e.employee_id)as employee_count, sum(s.ammount) as total_sales
from employee e
join sales s on e.employee_id=s.employee_id
where salary > 50000
group by e.department
having total_sales >100000
order by total_sales asc;

select e.department,  count(distinct employee_id) as employee_count,
sum(s.ammount) as total sales
from employees e
left join sales s on e.employee_id=s.employee_id 
where salary >5000
group by e.department
having total_sales >100000
order by total_sales desc;

select e.department, count(distinct e.employee_id) as employee_count,
coalesce(sum(s.ammount),0)as total_sales, 
coalesce (sum(s.ammount),0)/count(distinct e.employee_id) as avg_sales
from employees e
left join sales s on e.employee_id=s.employee_id
where salary >50000
group by department
having coalesce(sum(s.ammount),0)>100000
order by total_sales desc;


select e.department, count(distinct e.employee_id) as employee_count,
		sum(s.ammount)as total_sales,
		avg(s.ammount) as avg_total_sales
		from employees e
		join sales s on e.employee_id=s.employee_id
		join products p on p.product_id=s.product_id
		where e.salary >50000 and p.category ="Electronics"
		group by e.department
		having sum(s.ammount)>50000
		order by total_sales desc;


select e.department,
count(distinct e.employee_id)as employee_count,
sum(s.ammount) as total_sales,
avg(s.ammount) as avg_sales
from employees e
join sales s on e.employee_id=s.employee_id
join products p on p.product_id=s.product_id
where e.salary >50000 and p.category='Electronics' and s.sale_date >='2026-1-1' and s.sale_date <= '2026-2-28'
group by e.department 
having total_sales > 50000
order by total_sales desc;


select e.department, count(distinct e.employee_id) as employee_count,
sum(s.amount)as tota_sales,
avg(s.amount) as avg_sales,
max(e.salary) as highest_employee_salary
from employees e
join sales s on e.employee_id=s.employee_id
where e.salary >65000
group by e.department
order by tota_sales desc;


select e.department,
e.total sales, dense_rank()over (order by e.total_sales desc) as dept_rank
from(select e.department, sum(s.amount)as total_sales
from employees e
join sales s on e.employee_id=s.employee_id
where  e.salary>65000
group by e.department)as e
order by dept_rank;


select department,
e.name as employee_name
salary, dense_rank() over (partition by department order by salary)as salary_rank
from employees e


select department,
e.name as employee_name, 
salary, avg(salary) over (partition by department )as dept_avg_salary
from employees e;


select department,
		employee_name,
		salary,
			dense_rank() over (partition by department order by salary desc) as salary_rank
			from employees 
			where salary_rank <=2;

select department,
 e.name as employee_name,
 salary,
 salary_rank from(select department,
 						e.name as employee_name,
						 salary, dense_rank()over (partition by department order by salary desc)as salary_rnk 
						 from employees)x where salary_rnk <=2;


select department,
 		name as employee_name,
		 salary, dense_rank() over (partition by department order by salary desc)as salary_rnk
		 from employees 
		 where salary_rnk=1;

select department, 
		employee_name,
		salary from(select department,
							name as employee_name,
							salary, dense_rank()ove (partition by department order by salary desc)as salary_rnk
							from employees) as x 
							where salary_rnk=1


select department,
		employee_name, salary
		from (select department,
							name as employee_name,
							salary, dense_rank() over (partition by department order by salary desc)as salary_rnk
							from employees) as x
							where salary_rnk=2;

select department,
				employee_name,
				salary from(select department,
							name as employee_name,
							salary, row_number() over (partition by department order by salary desc)as salary_rnk from employees) as e
							where salary_rnk=3;


select department,
		employee_name, 
		highest_sales from(select e.department,
				e.name as employee_name,
						s.amount as highest_sales,row_number() over (partition by e. department order by s. amount)as sales_rnk
						from employees  
						join sales s on e.employee_id=s.employee_id) as e 
						order by ammount desc
						where sales_rnk=1;

select department,
			employee_name,
				amount,
					sale_date,
							sales_rnk from(select e.department,
							e.name as employee_name,
									s.amount,
		s.sale_date,row_number() over (partition by e.department  order by s.amount desc) as sales_rnk		
	from employees e
	join sales s on e.employee_id = s.employee_id) as e
	where sales_rnk <=2;



-----lag window function-----
select employee_id, 
			sale_date,
				amount,
			previous_sale(select employee_id,
		sale_date,
	amount lag(amount) over (partition by employee_id order by sale_date)as previous_sale from sales);



select employee_id,
			sale_date,	
				amount,lag(amount) over (partition by employee_id order by sale_date ) as previous_sale from sales;


select employee_id,
			sale_date, 
				amount, lag(amount) over (partition by employee_id order by sale_date) as previouse_sale,
					amount- lag(amount) over (partition by employee_id order by sale_date) as difference from sales;


select employee_id,
sale_date,
amount,
previouse_sale(select employee_id, 
sale_date,
amount, lag(amount) over (partition by employee_id order by sale_date)as previous_sale from sales)t 
where amount > previous_sale;


select employee_id,
sale_date,
amount,
previous_sale from(select employee_id,
sale_date,
amount,lag(amount) over (partition by employee_id order by sale_date)as previous_sale from sales)t 
where amount < previous_sale;


select employee_id,
sale_date,
amount,
previous_sale from(select employee_id,
	sale_date,
	amount,lag(amount)over (partition by employee_id order by sale_date) as previous_sale from sales)
	(amount-previous_sale)/previous_sale*100 as percent_change;

select employee_id,
sale_date,
amount,
previous_sale,
(amount-previous_sale)*100/previous_sale as percent_change
from(select employee_id,
sale_date,
amount,lag(amount) over (partition by employee_id order by sale_date) as previous_sale from sales)t
where (amount-previous_sale)*100/previous_sale > 20;

select employee_id,
sale_date, 
amount,
previouse_sale,
difference_amount from(select employee_id, 
sale_date,
amount,
previous_sale,
amount-previous_sale as difference_amount,row_number()over (partition by employee_id order by amount-previous_sale  desc) AS rnk
from(select employee_id,
sale_date,
amount,
lag(amount)over (partition by employee_id order by sale_date)as previous_sale from sales) as t) as y
where rnk=1;

select employee_id, sale_date,
amount,
previous_sale,
drop_amount from (select employee_id,
sale_date,
amount,
previous_sale, previous_sale-amount as drop_amount,
row_number() over (partition by employee_id order by previous_sale-amount desc) as rnk 
from(select employee_id,
sale_date,
amount, lag(amount)over (partition by employee_id order by sale_date)as previous_sale from sales ) t)y
where rnk=1;

select employee_id,
sale_date,
amount,
previous_sale,
change_amount,(amount-previous_sale)/previous_sale*100 as change_precentage from(select employee_id,
sale_date,
amount, 
previous_sale,
amount-previous_sale as change_amount from (select employee_id,
sale_date,
amount,lag(amount) over (partition by employee_id order by sale_date)as previous_sale from sales)t)y;


select employee_id,
sale_date,
amount,
previous_sale,
drop_amount,
(previous_sale-amount)/previous_sale*100 as drop_percentage 
from (select employee_id,
sale_date,
amount,
previous_sale, previous_sale-amount as drop_amount from (select employee_id,
 sale_date,
 amount,lag(amount) over (partition by employee_id order by sale_date) as previous_sale from sales)t)y
where amount < previous_sale;


select employee_id,
sale_date,
amount,
previous_amount,
lag(amount,2)over (partition bu employee_id order by sale_date)as previous_previous_change from(select employee_id,
sale_date,
amount, lag(amount) over (partition by employee_id order by sale_date)as  previous_amount from sales)t
where amount< previous_amount and previous_amount<previous_previous_amount;

select employee_id,
sale_date,
amount,
previous_change,
previous_previous_change from(select employee_id,
sale_date, 
amount, lag(amount)over (partition by employee_id order by sale_date)as previous_change,
lag(amount, 2)over (partition by employee_id order by sale_date)as previous_previous_change from sales) t
where amount<previous_change
and previous_sale<previous_previous_change;


select employee_id, 
max(streak_length) as longest_decrease_streak from(select employee_id, 
streak_grp, sum(decrease) as streak_length from(
select employee_id, amount, previous_table, decrease, reset, 
sum(reset) over (partition by employee_id order by sale_date)as streak_grp from 
(select employee_id, amount, previous_sale, decrease,
case when decrease=0 then 1 else 0 end as reset from
(select employee_id, amount, previous_sale,
case when amount<previous_sale then 1 else 0 end as decrease from
(select   employee_id, amount,	
lag(amount) over (partition by employee_id order by sale_date) as previous_sale from sales)t)x)y)z)
group by employee_id, streak_grp)a		
group by employee_id
order by sale_date;


select employee_id, max(streak_length) as longest_strak_increase from
(select employee_id, streak_grp, sum(increase)as streak_length from(select employee_id, sale_date, amount,
previous_sale, increase, reset, sum(reset) over (partition by employee_id order by sale_date)as streak_grp from
(select employee_id, sale_date,
amount, previous_sale,
increase, case when increase=0 then 1 else 0 end as reset from
(select employee_id,sale_date,
amount, previous_sale, case when amount>previous_sale then 1 else 0 end as increase from
(select employee_id, sale_date, 
amount, lag(amount) over (partition by employee_id order by sale_da) as previous_sale from sales)a)b)c)d
group by employee_id, streak_grp)e
group by employee_id
order by employee_id;


select employee_id, max(streak_length) as longest_streak_increase from
(select employee_id, streak_grp, 
count(*) as streak_length from
(select employee_id, sale_date, amount, previous_sale, increase, reset,
sum(reset) over (partition by employee_id order by sale_date)as streak_grp from
(select employee_id, sale_date, amount,
previous_sale, increase,case when increase=0 then 1 else 0 end as reset from
(select employee_id,
sale_date, 
amount, previous_sale, case when amount>previous_sale then 1 else 0 end as increase 
from(select employee_id, sale_date,
amount, lag(amount)over (partition by employee_id order by sale_date)as previous_sale from sales)a)b)c)d
group by employee_id, streak_grp)e
group by employee_id
order by employee_id;


select employee_id, max(streak_length) as longest_streak_decrease from
(select employee_id, streak_grp,
count(*) as streak_length from
(select employee_id, sale_date, amount, 
previous_sale, decrease, reset, 
sum(reset) over (partition by employee_id order by sale_date )as streak_grp from
(select employee_id, sale_date,amount,
previous_sale, decrease,
case when decrease=0 then 1 else 0 end as reset from
(select employee_id, sale_date, amount, 
previous_sale, 
case when amount<previous_sale then 1	 else 0 end as decrease from
(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale from sales )a)b)c)d
group by employee_id, streak_grp)e 
group by employee_id
order by employee_id;


select * from(select employee_id, sale_date, amount,
previous_sale, increase, 
max(increase)over (partition by  employee_id) as largest_single_day_increase from
(select employee_id, sale_date, amount, previous_sale,
amount-previous_sale as increase from(select employee_id, sale_date, amount,
lag(amount)over (partition by employee_id order by sale_date) as previous_sale from sales)a)b)c
where increase=largest_single_day_increase
order by employee_id;


select * from(select employee_id, sale_date, amount, previous_sale,
decrease, max(decrease) over(partition by employee_id)as largest_single_day_decrease from
(select employee_id, sale_date, amount, previous_sale,
previous_sale-amount as decrease from
(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale from sales)a)b)c
where decrease=largest_single_day_decrease
order by employee_id;

select * from(select employee_id, sale_date, amount, previous_sale, increase, max_increase, row_number()over
(partition by employee_id order by sale_date desc)as rnk from
(select employee_id, sale_date, amount,
previous_sale, increase, max(increase)over(partition by employee_id) as max_increase from
(select employee_id, sale_date, amount, 
previous_sale,
amount-previous_sale as increase 
from(select employee_id, sale_date,
amount, 
lag(amount) over (partition by employee_id order by sale_date) as previous_sale from sales)a)b)c 
where increase=max_increase)d
where rnk=1
order by employee_id;


select * from(select employee_id, 
sale_date,
amount,
previous_sale, increase,
largset_singleday_increase,row_number()over (partition by employee_id order by sale_date desc)as rnk
from(select employee_id,
sale_date,
amount, previous_sale, 
increase, max(increase)over(partition by employee_id)as largest_singleday_increase from
(select employee_id,
sale_date, amount, previous_sale,
amount-previous_sale as increase from
(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale from sales)a)b)c 
where increase=largest_singleday_increase)d
where rnk=1
order by employee_id;

select * from (select employee_id, sale_date, amount, 
row_number() over (partition by employee_id order by sale_date desc)as rnk from
(select employee_id, 
sale_date, 
amount, previous_sale, previous_previous_sale from (select employee_id, 
sale_date, amount,
lag(amount)over (partition by employee_id order by sale_date)as previous_sale,
lag(amount, 2)over (partition by employee_id order by sale_date)as previous_previous_sale from sales)a
where previous_previous_sale>previous_sale
and amount>previous_sale )b)c
where rnk=1
order by employee_id;

select * from(select employee_id, 
sale_date, amount, 
row_number()over (partition by employee_id order by sale_date) as rnk 
from (select employee_id, sale_date,
amount, previous_sale, previous_previous_sale from
(select employee_id, 
sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale,
lag(amount, 2) over (partition by employee_id order by sale_date) as previous_previous_sale from sales)a 
where previous_previous_sale<previous_sale
and previous_sale<amount)b)c
where rnk=1
order by employee_id;


select employee_id, sale_date, amount,
previous_sale, next_sale from(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date) as previous_sale,
lead(amount) over (partition by employee_id order by sale_date) as next_sale from sales)a
where previous_sale <current_sale
current_sale<next_sale;

select employee_id,
sale_date, amount,
previous_sale,
next_sale from(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale,
lead(amount) over  (partition by employee_id order by sale_date) as next_sale from sales)a
where previous_amount < amount 
and amount > next_sale
order by employee_id;


select employee_id, sale_date, amount,
previous_sale, next_sale from(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale,
lead(amount) over (partition by employee_id order by sale_date)as next_sale from sales)q
where previous_sale > amount
and amount < next_sale
order by employee_id;


select employee_id, sale_date, amount,
previous_sale, next_sale from 
(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale,
lead(amount) over (partition by employee_id order by sale_date)as next_sale from sales)a
where previou_sale > amount
and amount <next_sale
order by employee_id;


select 
employee_id, sale_date, amount, previous_sale, next_sale from
(select employee_id, sale_date, amount, 
lag(amount)over (partition by employee_id order by sale_date)as previous_sale,
lead(amount) over (partition by employee_id order by sale_date) as next_sale from sales)a 
where (previous_sale<amount
and amount>next_sale) or (prevuous_sale>amount and amount<next_sale)
order by empliyee_id;

select employee_id, sale_date, amount, 
previous_sale, next_sale, 
case when previous_sale<amount and amount>next_sale then 'peak'
 when previous_sale>amount and amount<next_sale then 'valley' end as reversal_type 
from(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale,
lead(amount) over (partition by employee_id order by sale_date ) as next_sale from sales)a 
where (previous_sale<amount and amount>next_sale)
or (previous_sale>amount and amount<next_sale)
order by employee_id;


select employee_id, sale_date, amount,
case when peak=1 then 'PEAK'
	when valley=1 then 'VALLEY' end as reversal_type FROM(select employee_id, sale_date, amount, 
case when decrease=0 then 1 else end as valley) from
(select employee_id, sale_date, amount,case when increase=0 then 1 esle 0 end as peak
from(select employee_id, sale_date, amount, previous_sale, next_sale, 
previous_sale>amount and
amount<next_sale as decrease from(select 
employee_id, sale_date, amount, 
previous_sale, next_sale, previous_sale<amount and amount>next_sale as increase from(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale,
lead(amount) over (partition by employee_id order by sale_date ) as next_sale from sales)a )b)c)d)
where peak=1
	valley=1
order by employee_id; 

select employee_id, sale_date, amount, case when peak=1 then 'PEAK'
case when valley =1 then 'VALLEY' end as reversal_type from
(select employee_id, sale_date, amount,
 case when increase then 1 else 0 end as peak
 case when decrease then 1 else 0 end as valley from(select employee_id, sale_date,amount,
previous_sale, next_sale,
previous_sale<amount and amount>next_sale as increase,
previous_sale>amount and amount<next_sale as decrease from(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date)as previous_sale,
lead(amount) over (partition by employee_id order by sale_date) as next_sale from sales)a)b)c
where peak=1
 valley=1 
 order by employee_id;


select employee_id, sale_date, amount, previous_sale, 
next_sale, reversal_type,
case when reversal_type='PEAK'
 then amount-least(previous_sale, next_sale)
 when reveral_type='VALLEY'
 then greatest(previous_sale, next_sale)-amount end as reversal_strength
 (select employee_id, sale_date, amount, previous_sale, next_sale,
case when previous_sale<amount and amount>next_sale then 'PEAK'
when previous_sale>amount and amount<nextsale as 'VALLEY' end as reversal_type from
(select employee_id, sale_date, amount,
lag(amount) over (partition by employee_id order by sale_date) as previous_sale,
lead(amount) over (partition by employee_id order by sale_date) as next_sale from sales)a)b
where reverasl_type is not null
order by employee_id;


		--FIRST_VALUE--WINDOW--FUNCTION--

select employee_id, sale_date, 
amount from sales, first_value(amount)over (partition by employee_id)as first_sale
order by employee_id, sale_date;


select* from(select * ,  first_value(amount)over
(partition by employee_id order by sale_date)as first_sale from sales)a
order by employee_id, sale_date;

select employee_id, sale_date, amount, 
first_value(amount) over (partition by employee_id order by sale_date)from sales
order by employee_id, sale_date;

select employee_id, sale_date, amount,
first_sale, amount-first_sale as change_from_first from
(select employee_id, sale_date, amount,
first_value(amount) over (partition by employee_id order by sale_date)as first_sale from sales)a
order by employee_id;



select employee_id, sale_date, amount,
last_value(amount) over (partition by employee_id order by sale_date 
rows between unbounded preceding and
				unbounded following )as last_sale from sales
				order by employee_id, sale_date, amount;

select employee_id,
	sale_date, 
		amount, first_sale,
			last_sale, first_sale-last_sale as change_in_both_sale from(select employee_id, sale_date, amount,
first_value(amount) over (partition by employee_id order vy sale_date) as first_sale,
last_value(amount) over (partition by employee_id order by sale_date
rows between unbounded preceding and 
			unbounded following) as last_sale from sales
)a order by employee_id;


select employee_id, sale_date, amount,
first_sale,
last_sale, (last_sale-first_sale)/first_sale*100 as change_percent from
(select employee_id, sale_date, amount,
first_value(amount) over (partition by employee_id order by sale_date)as first_sale
last_value(amount) over (partition by employee_id order by sale_date
rows between unbounded preceding and 
			unbounded following)as last_sale from sales)a;



select 
	employee_id, sale_date, 
		amount, 
		first_sale, 
			last_sale, 
		amount_first_sale as first_sale_diff,
	last_sale-amount as last_sale_diff from
(select employee_id, sale_date, amount,
     first_value(amount) over (partition by employee_id order by sale_date) as first_sale,
        last_value(amount) over (partition by employee_id order by sale_date
		rows between unbounded preceding and 
	unbounded following) as last_sale from sales)a
order by employee_id;

select employee_id, sale_date, 
	amount, 
		second_sale fom(select employee_id, 
			sale_date, 
				amount,
nth_value(amount, 2) over (partition by employee_id order by sale_date)as Nth_sale from sales)a
order by employee_id;
	

select employee_id, sale_date, amount, first_sale,
second_sale,
amount-second_sale as change_from second from
(select employee_id, sale_date, 
amount,
first_value(amount) over (partition by employee_id order by sale_date)as first_sale,
nth_value(amount,2) over (partition by employee_id order by sale_date
rows between unbounded preceding and
				unbounded following )as second_sale from sales)a
order by employee_id;

select employee_id, sale_date,
amount, first_sale, third_sale,
amount-third_sale as change_from_third from
(select employee_id, sale_date, amount,
first_value(amount)over (partition by employee_id order by sale_date) as first_sale
nth_value(amount, 3) over (partition by employee_id order by sale_date
rows between unbounded preceding
			unbounded following ) as third_sale from sales)
			order by employee_id;


select employee_id, sale_date, amount,
sum(amount) over (partition by employee_id order by sale_date
rows between unbounded preceding and 
	current row) as total_amount from sales
	order by employee_id;

select employee_id, sale_date, amount,
avg(amount) over (partition by employee_id order by sale_date 
rows between unbounded preceding and current row) as ang_salary
from sales 
order by employee_id;

select employee_id, sale_date, amount,
avg(amount) over (partition by employee_id order by sale_date
rows between 2 and current row) as moving _avg_3 from sales
order by employee_id;

select employee_id, sale_date, amount,
sum(amount) over (partition by employee_id order by sale_date
rows between 2 preceding and current row) as total_sales_cumilative_of _3_rows
from sales
order by employee_id;

select employee_id, sale_date, amount,
sum(amount) over (partition by employee_id order by sale_date
 rows between current row and 2 following) as sum_of_next_2_rows from sales
 order by employee_id;

select employee_id, sale_date, amount,
avg(amount) over (partition by employee_id order by sale_date 
rows between 1 preceding and 1 following)as moving_avg_middle from sales
order by employee_id;


select employee_id, sale_date, amount,
sum(amount) over (partition by employee_id order by sale_date
rows between unbounded preceding and current row) as running_total_rows,
sum(amount) over (partition by employee_id order by sale_date
range between unbounded preceding and current row) as running_total_range from sales
order by employee_id;

select employee_id , sale_date, amount,
sum(amount) over (partition by employee_id order by sale_date
rows between 2 preceding and current row) as running_total
sum(amount) over (partition by employee_id order by sale_date
range between interval '2days' and current row) running_total_range from sales 
order by employee_id;


--Write a query to find all employees from the IT department whose salary is greater than ₹55,000.
select * from employees
where department='IT' and salary>55000;


--Find all unique departments present in the company.
select distinct departents 
from employees;

--Find all employees and display them from the highest salary to the lowest salary.
select * from employees
order by salary desc;

--Find the average salary of all employees.
select avg(salary)
from employees;

--Now calculate all three in one query:

--Total number of employees
--Total salary paid
--Average salary
select count(disctinct employee_id) as employee_count
	sum(salary) as salary_paid
	avg(salary) as avg_salary
	from employees;

---Find the number of employees in each department.
select department count(distinct employee_id)
 group by department
 from employees;

---Find the average salary for each department.
select department avg(salary)
from employees
group by department; 

--Find the average salary for each department,
--but consider only employees whose salary is greater than ₹50,000.
select department, avg(salary)
from employees
where salary>50000
group by department;

--Find departments whose average salary is greater than ₹60,000.
select department, avg(salary) as avg_salary
from employees
group by department
having avg_salary >60000;

--Using the employees table, create a new column called salary_level:
--Salary >= 70,000 → 'High'
--Salary >= 55,000 → 'Medium'
--Otherwise → 'Low'

select employee_id, name, salary,
case when salary >=70000 then 'High'
		when salary >=55000 then 'Medium'
			else 'Low'
		end as salary_level	;


--Count how many employees belong to each salary level:

--Salary >= 70,000 → High
--Salary >= 55,000 → Medium
--Otherwise → Low
select 
 case when salary>=70000 then 'High'
 	when salary>=55000 then 'Medium'
	 else 'Low' end as salary_level,
	 count(distinct employee_id)
	 from employees
	 group by case when salary>=70000 then 'High'
 	when salary>=55000 then 'Medium'
	 else 'Low' end as salary_level ;

--High → salary >= 70,000
--Medium → salary >= 55,000
--Low → otherwise
--Find the total salary paid for each salary level.

select 
	case when salary>70000 then 'High'
		when salary >=55000 then 'Medium'
		else 'Low' end as salary_level,
	sum(salary)salary_paid from employees
	group by 
case when salary>70000 then 'High'
		when salary >=55000 then 'Medium'
		else 'Low' end as salary_level;
		
--Now use the same salary levels, but find the highest salary in each salary level.

select 
	case when salary >= 70000 then 'High'
			when salary >=55000 then 'Medium'
				else 'Low' end as salary_level,
				max(salary)max_salary
					from employees 
	group by 	
case when salary >= 70000 then 'High'
			when salary >=55000 then 'Medium'
				else 'Low' end 		;

--Now use the same salary levels, but find the highest salary in each salary level.
select salary_level,max(salary)
from
	(select salary, 
	case when salary >=70000 then 'High'
			when salary >50000 then 'Medium'
			else 'Low' end as salary_level
			from employees)a
		group by salary_level;	

--High → salary >= 70,000
--Medium → salary >= 55,000
--Low →otherwise

--For each salary level, find:
--Number of employees
--Average salary
--Highest salary

select salary_level, count(distinct employee_id) as number_of_employees,
avg(salary) as avg_salary
	max(salary) as max_salary from (select salary,
	case when salary >=70000 then 'High'
			when salary >= 550000 then 'Medium'
				else 0 end as salary_level
			from employees)a
			group by salary_level;



select salary_level, count(*)as employee_count,
avg(salary) as avg_salary 
from(select salary, age,
		case when salary >= 70000 then 'High'
			when salary >= 55000 then 'Medium'
			else 'Low' END as salary_level
			from employees)a
			where age>=27
			group by salary_level
			having avg(salary) 60000;


select sales_level, 
	count(*)as number_of_sales,
		avg(amount)as avg_amount 
			from(select amount, experience,
		case when amount >=70000 then 'High'
				when amount >=55000 then 'Medium'
					else 'Low' end as sales_level
					from employeees)a
				where experience >=4
			group by sales_level
		having avg(amount)>=60000;


select e.employee_name, d.department, e.salary
from employees e 
left join department d on e.department_id=d.department_id

select e.employee_name, d.department_name
from employees e 
left join departments d on e.department_id=d.department_id;

select e.employee_name, d.department_name
from employees e
inner join departments d on e.department_id=d.department_id
where salary>55000;

select d.department_id, count(distinct e.employee_id) as employee_count 
from employees e
inner join departments d on e.department_id=d.department_id 
group by department_id;

select d.department, avg(e.salary)as avg_salary
from employees e 
inner join departments d on e.department_id=d.department_id
group by d.department_id;


select d.department_name, avg(e.salary)as avg_salary
from employees e 
inner join departments d on e.department_id=d.department_id
group by d.department_id 
having avg_salary >60000;


select e.employee_id, 
e.employee_name,
e.salry,
m.employee_name as manager_name,
m.salary as manager_salary from 
employee e 
self join employees m
on e.employee_id = m.manager_id
where e.salary>m.manager_salary;


select e.employee_id,
e.employee_name,
e.salary,
m.employee_name as manager_name,
m.salary as manager_salary
from employees e
join employees m on e.manager_id=m.employee_id
where e.salary>m.salary;


select d.department_name, count(distinct e.employee_id) as employee_count,
avg(e.salary) as avg_salary
from employees e 
join departments d on e.department_id=d.department_id
group by d.department_name
having  count(distinct e.employee_id) >= 2  and 
avg(e.salary) >85000;

select d.department_name,
sum(e.salary) as total_salary,
max(e.salary) as max_salary
from employees e 
join departments d on e.department_id=d.department_id
group by d.department_name
having sum(e.salary) > 200000 and
		max(e.salary) >100000;

--Find employees whose salary is greater than the average salary of their own department.
select a.employee_id,
	a.employee_name,
	a.department_id,
	a.salary from(select e.employee_id as employee_id,
e.employee_name as employee_name,
d.department_id as department_id,
e.salary as salary
from employees e
join departments d on e.department_id=d.department_id)a
where a.salary >(select avg(e2.salary)from employees e2
where e2.department_id=a.department_id);


--Find employees who earn more than their department's 
--average salary AND less than their department's maximum salary.

select a.employee_id,
	a.employee_name,
		a.department_name,
			a.salary from(select e.employee_id,
	e.employee_name,
	d.department_name,
	e.salary from 
	employeeds e 
	join departments d on e.department_id=d.department_id)a
	where a.salary >(select avg(e2.salary) from employees e2
	where e2.department_id=a.department_id) and 
	a.salary < (select max(e3.salary) from employees e3 
	where e3.department_id=a.department_id);



--greater than their department average AND greater than the company-wide average.
select a.employee_id,
	a.employee_name,
	a.department_id,
	a.salry from (select e.employee_id,
	e.employee_name,
	d.department_id,
	s.salary
	from employees e 
	join departments d on e.department_id=d.department_id)a
	where a.salary > (select avg(e2.salary) from employees e2
		where e2.department_id=a.department_id) and 
	a.salary>(select avg(salary) from employees );	
	

--Find employees who earn the highest salary in their own department.
select a.employee_id,
	a.employee_name,
		a.department_id,
			a.salary from(select e.employee_id,
		e.employee_name,
		e.department_id,
		e.salary from employees e 
		join departments d on e.department_id=d.department_id)a 
	where	a.avg(salary)>(select max(e2.salary) from employees e2 
			where e2.department_id=a.department_id
			group by department_id;
		

--Find employees who have the second-highest salary in their own department.
	select a.employee_id,
			a.employee_name,
			a.department_id,
			a.salary from (select e.employee_id,
		e.employee_name,
		e.department_id,
		e.salry from employees e 
		join departments d on e.department_id=d.department_id)a
		where a.salary=(select max(e2.salary) from employees e2
				where e2.department_id=d.department) and 
				e2.salary<(select max(e3.salary) from employees e3
				where e3.department_id=a.department_id);
				
select department_id,
		employee_name,
			salary from
	(select department_id, employee_name, 
salary, dense_rank(salary) over (partition by department_id order by salary desc)
as rnk from employees)a
where rnk=2;

--Find the second-highest distinct salary in each department, but return all employees who have that salary.
select department_id,
		employee_name,
			salary from(select department_id,
		employee_name,
		salary, dense_rank() over (partition by department_id order by distinct salary)
		as rnk  from employees)a
		where rnk=2;

--Find the highest-paid employee in each department.
--But this time, if two employees have the same highest salary, return both employees.
select department_id,
		employee_name,
			salary from(select department_id,
		employee_name,
		salary dense_rank() over (partition by department_id order by salary desc)
			as rnk from employees)a
			where rnk=1;
			
--Find the top 2 highest-paid employees from each department.
select department_id,
		employee_name,
			salary from (select deparment_id,
			employee_name,
				salary, dense_rank() over (partition by department_id order by salary desc)		
		as rnk from employees )a
	where rnk <=2;				

--Find the 3rd highest salary in each department, but return the employee name(s).
select department_id,
			s, 
				salary from(select department_id,
		employee_name as s,
			salary, dense_rank() over (partition by department_id order by salary)
		as rnk from employees )a
	where rnk=3;			
				
--Find the highest-paid employee in each department,
select department_id,
		employee_name,
			salary from(select department_id,
		employee_name,
			salary, row_number() over (partition by department_id order by salary desc)
				as rnk)a
			where rnk=1;	

select department_id, employee_name, salary, max(salary) from employees;

--Find the top 2 highest-paid employees in each department.
select department_id,
		employee_name,
			salary from(select department_id,
		employee_name,
			salary, row_number() over (partition by departmentz_id order by salary desc)a
				as rnk from employees) a
				where rnk 2;

--Find the top 2 salary levels in each department, and return all employees belonging to those salary levels.
select department_id,
	employee_name,
		salary from (select department_id,
			employee_name,
				salary, dense_rank() over (partition by department_id order by salary desc)
					as rnk from employees
							)	a
					where rnk <=2	;


--Find the highest-paid employee(s) in each department, displaying:
select department_name, 
		employee_name, 
			salary from(select d.department_name, 
			e.employee_name,
				e.salry, dense_rank() over (partition by department_id order by salary desc )
				as rnk from employees e
		join departments d on e.department_id=d.department_id)a
where rnk=1;


---🔥 Q48 — Department-wise 2nd Highest Salary
select department_id,
			employee_name, 
				salary from(select d.department_id,
			e.employee_name,
				e.salary, dense_rank() over (partition by d.department_id order by e.salary )as rnk
					from employees e
				join depertments d on e.department_id=d.department_id)a
			where rnk=2;


---Find the department(s) whose highest-paid employee earns the most across all departments.
select department_id,
		employee_name,
			salary , dense_rank() over (partition by department_id order by salry desc)
			as over_all rnk from (select department_id,
	employee_id, salary from ( select d.department_id, e.employee_name,
e.salry, dense_rank() over (partition by employee_id order by e.salary desc )
	as rnk from employees e 
	join departments d on e.department_id=d.department_id)a
	where rnk=1)b
where over_all rnk=1;


--Q50 — Highest Salary in Each Department Using MAX()
select department_name, 
			employee_name,
				max(salary) as max_salary 
				from employees 
			group by department_name;



select d.department_name,
			e.employee_name,
				e.salary, 
				 from employees e 
				join departments d on e.department_id=d.department_id 
				where e.salry=select(max(e2.salary) from employees e2
				where e2.department_id=e.department_id);


--Find employees whose salary is greater than the average salary of their own department.
select e.department_id,
			e.employee_name,
				e.salary from employees e 
			join departments d on e.department_id=d.department_id
			where e.salary>select avg(e2.salary) from employees e2 
			where e2.department_id=e.department_id;

--Find employees whose salary is greater than the average salary of their department AND less than the maximum salary of their department.
select e.department_id,
			e.employee_name,
				e.salary from employees e 
					join departments d on e.department_id=d.department_id
				where e.salary> (select avg(e2.salary) from employees e2
				where e2.department_id=e.department_id )and 
				e.salry< (select max(e3.salary) from employees 
				where e3.department_id=e.department_id);

--Find employees who have the same salary as at least one other employee in their department.
select department_id ,
		employees_name, salary from(select e.department_id,
			e.employee_name,
				e.salary from employees e 
			join departments d on e.department_id=d.department_id
		where e.salary=count(*) over (partition by  e.department_id, e.salry) as salary_count)
where salary_count >1;			


select department_id,
			employee_name,
				salary, avg(salary) as avg_salary,
			dense_rank() over (partition by department_id, order by salary desc )as salary_rnk
		where salary > avg(salary)	
	group by department;				
						
select department_id,
			employees_name,
				salary,
			avg_salary,
		salary_rnk from(select department_id, 
		employee_name,
			salary,
				avg(salary) over (partition by department_id)as avg_salary,
					dense_rank over (partition by department_id order by salary)as salary_rnk
						from employees)a
						where salry>avg_salary
						order by department_id, salary;
						
--Write a query to find employees whose salary is higher than the previous employee's 
--salary within the same department, based on salary ranking.
select department_id,
		employee_name,
			salary,
				previous_salary,
					salary_difference from(select department_id,
			employee_name,
				salary,
					lag(salary) over (partition by department_id order by salary desc) as 
					previous_salary,
					salary-	lag(salary) over (partition by department_id order by salary desc)
				as salary_difference
					from employees e )a
		where salary>previous_salary
		order by department_id;
				
select department_id, 
		employee_name, 
			salary,
				avg_salary,
					previous_salary,
					salary-previous_salary as salary_difference,
						salary_rnk from
			(select department_id,
		employee_name, 
			salary,
			avg(salary) over (partition by department_id ) as avg_salary,
				lag(salary) over (partition by department_id order by salary)
				as previous_salary,
				dense_rank() over (partition by department_id order by salary)as salary_rnk
				from employees)a
			where salary > avg_salary and 
				salary > previous_salary 
				order by department_id, salary_rnk;
				
--Find the highest-paid employee in each department whose salary is above the department average.
select 
		department_id,
			employee_name,
				salary,
				avg_salary,
			salary_rnk from(select department_id,
		employee_name, 
		salary,
		avg(salary) over (partition by department_id)as avg_salary,
		dense_rank() over (partition by department_id order by salary)as salary_rnk 
		from employees)a
where salary>avg_salary and rnk=1
order by department_id;


select department_id,
		employee_name, 
			salary,
				avg_salary,
					rnk,
					depta_max_salary from (
				select department_id, 
			employee_name, 
				salary,
					avg(salary) over (partition by department_id )as avg_salary,
			dense_rank() over (partition by department_id over order by salary desc )as rnk,
		max(salary) over (partition by department_id )as max_dept_salary from employees)a
	where salary >avg_salary and 
		salary < dept_max_salary order by department_id;

--Find employees whose salary is greater than the average salary of their department, but lower than the highest salary in their department.
select department_id,
		employees_name,
			salary,
				avg_salary,
					max_salary,
					salary_rnk,
					max_salary-salary as salary_gap_from_max from(select department_id,
						employee_name,
							salary,
				avg(salary)over partition  by department_id) as avg_salary,
					max(salary) over (partition by department_id ) as max_salary,
					dense_rank() over (partition by department_id order by salary)as salary_rnk 
					from employees )a
		where salary > avg_salary and 
					salary < max_salary
				order by department_id ;

--For each department, find the 2nd highest-paid employee.
select department_id,
			employee_name, 
				salary, salary_rnk from(select department_id,
			employee_name,
				salary,
					row_number() over (partition by department_id order by salary desc) 
					as salary_rnk from employees)a
					where salary_rnk=2
					order by department_id;

--Find the 2nd highest distinct salary in each department.
select 
		department_id,
			employee_name, 
				salary, 
			salary_rnk from (select department_id,
			employee_name,
				salary,
					dense_rank() over (partition department_id order by distinct salary)
					as salary_rnk from employees)a
				where salary_rnk=2;

--Find the 3rd highest distinct salary in each department, but return only employees whose
--salary is above the department average.
select 
		department_id,
				employee_name,
					salary,
						avg_salary,
					salary_rnk from(select department_id,
			employee_name,
				salary, 
				avg(salary) over (partition by department_id) as avg_salary,
					dense_rank() over (partition by department_id order by salary desc)as salary_rnk
				from employees)a
	where salary_rnk=3 and 
	salary>avg_salary
	order by department_id;
				

--Find the highest-paid employee in each department who is NOT the highest-paid employee overall.
select 
		department_id,
			employee_name,
				salary,
					dept_rnk,
				overall_rnk from(select 
		department_id,
	employee_name,
			salary,
			dense_rank() over (partition by department_id order by salary desc)as dept_rnk,
			dense_rank() over (order by salary desc)as overall_rnk
			max(salary) over ( partition by department_id order by salary desc)as max_salary
		from employees )a
where  dept_rnk=1  and
	 overall_rnk > 1
	order by department_id, salary;


select 
		department_id,
				employee_name,
					salary,
						avg_salary,
							previous_salary,
						salary_rank, 
					amount-previous_salry as salary_difference from (select department_id,
		employee_name,
				salary,
					avg(salary) over (partition by department_id )as avg_salary,
						lag(salary) over (partition by employee_id order by salary) as previous_salary,
					dense_rank() over (partition by department_id order by salary desc)
				as salary_rank from employees)a
			where salary > avg_salary and 
				salary> previous_salary 
				order by department_id;



select 
		employee_name,
			sale_date,
				amount,
			lag(amount) over (partition by employee_id order by salary) as  previous_sale_amount,
			avg(amount) over (partition by employee_id),
			row_number() over (partition by employee_id order by salary desc)as salary_rank
			from employees 
			order by employee_name, salary;
			
--Now we'll make this harder: find employees whose latest sale is greater than their own average sale
--AND whose latest sale increased compared with their previous sale.

select 
		employee_name,
			salae_date,
				amount,
					previous_salary,
						avg_salary,
					rnk from 
				(select employee_name, 
			sale_date,
				amount,
			lag(amount) over (partition by employee_id order by sale_date) as previous_salary,
		avg(amount) over (partition by employee_id) as avg_salary,
	row_number() over (partition by employee_id order by salary_date) as rnk from employees)a
where amount>avg_salary and 
	amount >previous_sale
	order by employee_id, sale_date;

--Find employees whose latest sale is higher than their previous sale, higher than their personal average sale,
--AND is the highest sale they have ever made.
select 
		employee_id,
			employee_name,
				amount, previous_sale,
					avg_salary,
						max_salary,
					rnk from
						(select employee_id,	
			employee_name,
				sale_date,
					amount,
			lag(amount) over (partition by employee_id order by sale_date )as previous_sale,
		avg(amount) over (partition by employee_id)as avg_salary,
	max(amount) over(partition by employee_id order by amount) as max_salary,
		row_number() over (partition by employee_id order by sale_date) as rnk
			from employees )a
where amount>previous_sale and 
		amount > avg_salary and rnk=1;

--Their latest sale is greater than their previous sale, greater than their average sale,
--and the latest sale is NOT their highest-ever sale.

select 
		employee_id,
			amployee_name, sale_date, 
				amount, previous_sale,
					avg_salary,
						max_salary from(select 
		employee_id,
			employee_name,
				sale_date,
					amount,
				lag(amount) over (partition by employee_id order by sale_date)as previous_sale,
			avg(amount) over (partition by employee_id) avg_salary,
		row_number() over (partition by employee_id order by sale_date) as rnk
	max(amount) over (partition by employee_id) as max_salary from employees)a
where amount >previous_sale and 
	amount > avg_salary and 
		amount <max_salary;
					

select 
		employee_id,
			employee_name,
				sale_date, 
				amount,
			lag(amount) over (partition by employee_id order by sale_date ) as previous_sale,
		sum(amount) over (partition by employee_id order by sale_date) as total_sales
	rows between unbounded preceding and current row as running_total from sales,
			avg(amount) over (partition by employee_id order by sale_date) as avg_sales
				rows between unbounded preceding and current row as running_avg,
			order by employee_id, sae_date;


--Now calculate the average of the current sale and the previous 2 sales for every employee.

select 
		employee_id,
			employee_name, 
				sale_date,
					amount,
						lag(amount) over (partition by employee_id order by sale_date) as previous_sale,
			sum(amount) over (partition by employee_id order by sale_date)
				rows between 2 preceding and current row as three_sale_avg;



select 
		employee_id,
			employee_name,
				amount,
					previous_sale,
						3_sale_moving_avg,
						3_sale_moving_avg - amount as diff_amount from (select 
		employee_id,
			employee_name,
				amount, 
					lag(amount) over (partition by employee_id order by sale_date ) as previous_sale,
			avg(amount) over (partition by employee_id order by sale_date)
				rows between 2 preceding and current row as 3_sale_moving_avg from employees)a
	where amount >	3_sale_moving_avg
	order by employee_id;
	

select	
		order_id,
			order_date,
				order_amount, or
						sum(order_amount) over (partition by order_id  
	rows between unbounded preceding and current row )as rows_revenue,
			sum(order_amount) over (partition by order_id
					range between unbounded preceding and current row) as range_revenue from orders
				order by order_id, order_date;



select 
		order_id,
			cudtomer_id,
				order_date,
					order_amount,
						SUM(order_amount) over (partition by order_date
						rows between unbounded preceding and current row ) as rows_revenue,
					sum(order_amount)over (partition by order_date
						range between unbounded preceding and current row) as range_revenue from
					orders 
					order by order_date;
				

select 
		order_id,
			customer_id,
				order_amount,
					order_date,
						sum(order_amount) over (partition by customer_id order by order_date
					rows between unbounded preceding and current row) as rows_revenue,
				sum(order_amount) over (partition by customer_id order by order_date
					range between unbounded preceding and current row) as range_revenue
						from orders 
						order by customer_id, order_date;


--Management wants the average of the current day's amount and the previous physical row.

select 
		sale_id, 
			sale_date,
				amount,
					avg(amount) over (partition by sale_date 
					rows between 1 preceding and current row) as 2_days_avg from orders 
					order by sale_date;


select 
		sale_id,
			sale_date,
				amount,
					sum(amount) over (order by sale_date 
						rows between 2 preceding and current row) as rows_revenue,
							sum(amount) over (order by sale_date 
								range between 2 preceding and current row)as rows_revenue
								from orders 
					order by sale_date;


select order_id, customer_id, amount,	
			first_value(amount) over (partition by order_id order by customer_id)
		as first_order_amount
	order by order_id;

select 
		order_id,
			customer_id,
				order_date,
					amount,
				first_order_amoun,
				amount-first_order_amount as diff_order_amount from (select 
		order_id,
			customer_id,
				order_date,
					amount, 
						first_value(amount) over (partition  by customer_id order by order_date)
								as first_order_amount from orders )a 
								order by order_id;
			

--For every order, find the customer's latest/final order amount,
--so that the same final amount appears on every row belonging to that customer.

select 
		order_id,
			customer_id,
				order_date,
					amount,
					last_value(amount) over (partition by customer_id order by order_date
				rows between unbounded preceding and unbounded following
				)as last_order_amount
				from orders
				order by order_id;


select 
		order_id,
			customer_id,
				amount,
					first_order_amount,
					last_order_amount,
						last_order_amount-first_order_amount as growth from
						(select 
		order_id,
			customer_id,
				amount,
					first_value(amount) over (partition by customer_id order by order_date)as first_order_amount,
				last_value(amount) over (partition by customer_id order by order_date ) as last_order_amount 
				from orders)a
				order by order_id;

--What was each customer's 2nd order amount?
select 
		order_id,
		customer_id,
		order_date,
		amount,
		nth_value(amount, 2) over (partition by customer_id order by order_date 
			rows between unbounded preceding and 
				unbounded following)as nth_order_amount
		from orders  
		order by order_id;



---NTILE---
select 
		employee_id,
			employee_name, 
				sales,
					ntile(4) over ( order by monthly_sales desc) as performence_groups
				from sales_employees 
				order by employee_id ;
					
--Divide employees into 2 performance groups separately within each region, based on monthly_sales.
select 
		employee_id,
			employee_name,
				region,
				monthly_sales,
				ntile(2) over (partition by region order by monthly_sales) as performance_goups
				from sales_employees
				order by employee_id;

--Now we have 10 employees across 3 departments.
--Management wants to divide employees within each department into 3 salary groups.
--But there's a catch: some departments don't have enough employees to fill all 3 buckets.

	select 
			employee_id,
				employee_name,
					region,
						salary, departments,
						ntile(3) over (partition  departments  order by salary desc) as groups
						from sales_employees
						order by employee_id;


select 
		employee_id,
			salary,
				ntile(3) over (order by salary desc) as salary_groups 
				from sales_department
				order by employee_id;


select 
		employee_id,
			employee_name,
				department,
					salary,
				ntile(4) over (partition by department order by salary desc )as salary_tiers
from employees 
order by order_id;


select employeee_id, 
			employee_name,
				salary,
					ntile(4) over (paertition by salay desc)as salary-tiers
					 from employees 
					 order by employee_id;

--HR wants to divide employees into 3 salary tiers within each department.

select employee_id,
	employee_name,
	 department,
	 	salary,
		 ntile(3) over (partition by department order by salary desc) as salary tier 
		 from employees
		 order by employee_id ;


select 
		customer_id,
			city,
				total_spend from (select 
		customer_id,
			city,
				sum(order_amount) over (partition by customer_id order by order_amount)as total_spend
				from orders)a
				ntile(3) over (order by total_spend desc) as spend_tires
				order by order_id;

select 
		customer_id,
			city,
				total_spend,
					ntile(3)over (partition by city order by total_spend desc) as spend_tiers from
					(select 
		customer_id,
			city,
				sum(order_amount) over (partition by customer_id) as total_spend
				from orders 
				group by customer_id, city)a
order by customer_id, city;


select 
		customer_id,
				city,
					total_spending,
					ntile(4) over (partition by city order by total_spending desc)as tier from
					(select customer_id,
			city,
				sum(amount) over (order by order_amount)as total_spending from orders
				group by city, customer_id)a
				order by customer_id, city;
		
select *, from(select *,
row_number() over (partition by tier over order by total_spending desc) as rnk from
(select 
		customer_id, 
			city,
				amount,
					order_date,
						total_spend, 
					ntile(4) over (partition by city order by total spend desc) as tier from (select 
					customer_id,
				city,
					amount,
						order_date,
							sum(amount) over (partition by customer_id )as total_spend 
							from orders 
							group by customer_id, city)a)b)c
							where tier_rnk <2
							order by customer_id, tier;

--First calculate total spending per customer.
--Then within each city, divide customers into 4 spending tiers using NTILE(4), highest spending first.                                                                                  
select * from(select 
		customer_id,
			city,
				order_amount, 
					total_spend,
						tier, 
		row_number() over (partition by city, tier order by total_spend desc) as rnk from
(select 
	customer_id,
		city,
			order_amount,
			ntile(4) over(partition by city order by total_spend) as tier from (select 
		customer_id,	
					city,
						order_amount,
							sum(order_amount) over (partition by customer_id) as total_spend 
								from orders)a)b))
								where rnk <=2
								order by customer_id, tier, total_spend;

select 
		customer_id,
				city,
					order_date,
						order_amount,
								total_spending,
									rnk,
							avg_spending, from(select 
		customer_id,
				city,
					order_date,
						order_amount,
							total_spending,
					dense_rank() over (partition by customer_id order by total_spending desc) as rnk, 
					avg(total_spending) over (partition by city) as avg_spending 
					  from (select 
		customer_id, 
				city,
					order_date,
						order_amount,
						sum(order_amount) as total_spending
						from orders 
						group by customer_id)a)b
					where customer_id > avg_spending and 
									total_spending < avg_spending 
									and rnk=1
									order by customer_id, rnk;
																
select 
		employee_id,
				sale_date,
					amount,
					last_value(amount) over (partition by employee_id order by amount
						rows between unbounded preceding and 
							unbounded following) as last_sale,
					lag(amount) over (partition by employee_id order by amount 
					rows between 1 preceding and unbounded following )as pevious_sale,
					row_number() over (partition by employee_id order by sale_date desc) as rnk
				avg(amount) over (partition by city order by amount) as avg_amount,
			where  latest sale > previous sale AND latest sale > average sale and rnk=1
			order by employee_id, amount;
									
select * from (select 
		employee_id,
				sale_date,
					amount,
						previous_sale,
							avg_amount, 
					row_number ()over (partition by employee_id order by sale_date) as rnk from
								select (
		employee_id, 
				sale_date, 
					amount,
										lag(amount) over (partition by employee_id order by sale_date 
						rows between unbounded preceding and 
						unbounded following) as previous_sale,
						avg(amount) over (partition by employee_id order by sale_date)as avg_amount,
						where  and amount>previous_sale and amount>avg_amount)a)b
					where rnk=1	order by employee_id, sale_date;
					
--For each employee, find the first sale where the amount was lower than the previous sale, and return:								
select 
		employee_id,
			sale_date,
				amount, previous_sale,
					rnk from(select 
		employee_id,
				sale_date, 
					amount, previous_sale,
					row_number () over (partition by employee_id order by sale_date )as rnk from
			(select 
		employee_id,
					sale_date,
							amount,
								lag(amount) over (partition by employee_id order by sale_date)
								as previous_sale from sales)a
								where amount < previous_sale )b
where rnk=1 
		order by employee_id, sale_date;



select * from (select 
		employee_id, 
			sale_date, 
			amount,
				previous_sale ,
					row_number()over (partition by employee_id order by sale_date) as rnk from (select 
		employee_id, 
		sale_date,
		amount,
		lag(amount) over (partition by employee_id order by sale_date) as previous_sale from 
		sales)a
		where amount > previuos_sale+(previous_sale*.20) b)
where rnk=1
	order by employee_id,
			sale_date;

---For each employee, find the first sale where the amount was 
---lower than the previous sale by at least 15%.
select * from (select 
		employee_id,
				sale_date,
					amount, 
						previous_sale, 
				row_number() over (partition by employee_id order by sale_date) as rnk 
				from (select employee_id,
			sale_date,
				amount, 
				lag(amount) over (partition by employee_id order by sale_date) as previous_sale 
				 from sales)a
				 where amount > previous_sale-(previous_sale*0.15))b
			where rnk=1 
		order by employee_id, sale_date;

--For each employee, find the first sale where the amount was greater than the previous sale, 
--but still below that employee's average sale amount.
select * from (select 
		employee_id,
			sale_date, 
				amount,
					previous_sale, 
						avg_sale, 
			row_number() over (partition by employee_id order by sale_date)as rnk
					from(select
		employee_id, 
			sale_date,
				amount,
					lag(amount) over (partition by employee_id order by sale_date) as previous_sale,
					avg(amount) over (partition by employee_id) as avg_sale
					from sales )a
					where amount >previous_sale and 
					amount < avg_sale)b
	where rnk=1
		order by employee_id, sale_date;

--Find the first sale where the amount increased by at
--least 25% compared with their immediately previous sale.
select * from(select 
		employee_id, 
			sale_date,
				amount, previous_sale, 
				row_number() over (partition by employee_id order by sale_date) as rnk
				from(select 
		employee_id,
				sale_date,
					amount, 
					lag(amount) over (partition by employee_id order by sale_date) as previous_sale
					from sales)a
			where amount >previous_sale+(previous_sale*0.25) b)
			where rnk=1
			order by employee_id, sale_date;

select * from(select 
		eployee_id,
				sale_date as drop_date,
				amount as drop_amount
					previous_sale,
						recovery_amount,
						recovery_date,
				row_number () over (partition by employee_id order by sale_date) as rnk from (select 
		employee_id,
			sale_date,
				amount,
					previous_sale, (select 
		employee_id,
				sale_date,
					amount,
						lag(amount) over (partition by employee_id order by sale_date) as previous_sale,
				lead(amount) over (partition by employee_id order by sale_date) as recovery_amount,
	lead(sale_date) over (partition by employee_id order by sale_date) as recovery_date from sales)a)b

where amount <previous_sale and
 recovery_amount<amount and 
 recovery_amount>previous_sale)
 
where rnk=1;

--For each employee, identify every sale where the next sale amount is higher than the current sale amount.
select * from(select 
		employee_id,
			sale_date,
				amount, 
					next_sale_date,
						next_sale_amount,
						next_sale_amount-amount as recovery_amount,
					row_number() over (partition by employee_id order by sale_date) as rnk 
				from (select 
		employee_id,
			sale_date, 
				amount,
					lead(sale_date) as next_sale_date,
					lead(amount) over (partition by employee_id order by sale_date)as next_sale_amount
				from sales)a)b
				where rnk=1 and next_sale_amount>amount 
				order by sale_date;
				
--For each employee, find the first sale after a decrease that represents a recovery.
select 
		employee_id,
				sale_date,
					amount,
						recovery_amount as drop_amount,
							recovery_date as drop_date,
							recovery_amount-amount as recovered_amount from(select 
		employee_id,
			sale_date, 
				amount,	
					lead(amount) over(partition by employee_id order by sale_date)as recovery_amount,
				lead(sale_date) over(order by sale_date) as recovery_date
				from sales)a
			where amount >drop_amount
		order by employee_id, sale_date;

--Departments whose average salary is higher than the overall company average salary.
select 
		employee_id,
			employe_name,
				department_id,
					salary from
				(select
		employee_id,
			employee_name,
				department_id,
					salary,
					avg(salary) over (partition by employee_id order by salary desc) as cmp_avg_salary)a 
					where avg_salary>(select avg(salary)as avg_salary from employees
						order by employee_id;
					


select employee_id,
			employee_name,
				department_id,
				avg(salary)as dept_avg_salary
						from employees,
						group by department_id,
						having avg(salary)>(select avg(salary) from employees);


--Find employees whose salary is greater than the average salary of their own department.
select 
		e.employee_id,
			e.employee_name,
				e.department_id,
					e.salry from employees e 
		where e.salary>(select avg(e2.salary) 
		from employees e2
			where e2.department_id=e.department_id);
						
--Find employees whose salary is the second-highest salary in their department.								
select 
		e.employee_id,
				e.employee_name,
						e.department_id,
									e.salary, 
									from employees e 
								where e.salry<(select max(e2.salary)as max_salary
									from employees e2 
									where e2.department_id=d.department_id);

SELECT
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.salary
FROM employees e
WHERE (
    SELECT COUNT(DISTINCT e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
      AND e2.salary > e.salary
) = 1;

--Find all employees who have placed at least one order greater than ₹50,000.
select 
		e.employee_id,
				e.employee_name,
					e.department_id,
						e.salary from employees e
						where exists (select 1 
								from orders o
								where o.employee_id = e.employee_id and o.order_amount>50000);

--Find employees who have at least 2 orders, where each of those orders is greater than ₹20,000.
select
		e.employee_id,
				e.employee_name,
						e.department_id,
							e.salary from employees e 
							where exists (select 1from orders o
							where e.employee_id=o.employee_id and o.orders >20000
							group by e.employee_id
							having count(*)>=2);

--Find employees who have never placed an order.					
select 
		e.employee_id,
			e.employee_name,
				e.department_id,
					e.salary from employees e
					where not exists (select 1 from
								orders o
								where o.employee_id=e.employee_id);

select 
		e.employee_id,
			e.employee_name,
				e.department_id,
						e.salary from employees e
						join orders o on e.employee_id=o.employee_id
					group by e.employee_id 
					having count(*)<1 and max(o.amount)<=50000;

--Find employees who have at least one order above ₹50,000 AND at least one order below ₹10,000.
  select 
  		e.employee_id,
		  	e.employee_name,
			  	e.department_id,
				  		e.salary from employees e 
						  join orders o on e.employee_id=o.employee_id
						  group by e.employee_id,
						  		e.employee_name,
								  		e.department_id,
										  	e.salary 
				having max(o.order_amount) >50000 and min(o.order_amount)<10000;

select 	
		e.employee_id,
			e.employee_name,
				e.department_id,
					e.salary from employees  e
				where exists (select 1 from orders o
				where e.employee_id=o.employee_id and o.order_amount>5000) and 
			where exists(select 1 from orders o
				where e.employee_id=o.employee_id and o.order_amount <10000);

--Find employees who have at least 3 orders, but none of their orders is above ₹50,000.
select 
		employee_id,
				employee_name,
					e.department_id,
						e.salary from employees e 
			join orders o on e.employee_id=o.employee_id 
			group by employee_id,
								employee_name,
									e.department_id,
										e.salary
									having count(*)>=3 and min(o.order_amount)<=50000;
						
select 
		e.employee_id,
			e.employee_name,
				e.department_id,
					e.salary from employees e 
					where exists ( select 1 from orders o
					where e.employee_id=o.employee_id
					group by e.employee_id,
						e.employee_name,
							e.department_id,
								e.salry
								having count(*)>=3 and min(order_amount)<=50000);


select e.employee_id,
			e.employee_name,
					e.department_id,
							e.salary from employees e
							where exists (select 1 from orders o
							where e.employee_id=o.employee_id
							group by employee_id
							having count(*)>=2) 
							where exists (select 1 from orders o  
							where e.employee_id=o.employee_id and max(o.order_amount)>=50000 and
							where exists(select 1 from orders o
							where e.employee_id=o.employee_id
and max(o.order_amount)<=10000);

select e.employee_id,
			e.employee_name,
					e.department_id,
							e.salary
							from employees e 
							join orders o on e.employee_id=o.employee_id
							group by e.employee_id,
										e.employee_name,
											e.department_id,
													e.salary
			having count(*)>=2 and max(o.order_amount)>50000 and min(o.order_amount)<10000;

------long 15 days GAP------
--Write a SQL query to find the second-highest salary from the employees table.

select 
		employee_id,
			employee_name,
				department_id,
						salary,
						dense_rank() over (order by employee_id) as rnk from employees 
						where rnk=2;

--Find the second-highest distinct salary in each department.

select employee_id,
			employee_name,
				department_id,
					salary from(select 
		employee_id,
			employee_name,
				department_id,
						salary,
				dense_rank()over(order by distinct salary desc)as rnk from employees)e
			where rnk=2
			group by department_id;


---Find all employees whose salary is greater than the average salary of their own department.
select employee_id,
			employee_name,
				department_id,
					salary,
					dept_avg_salary from(select 
		employee_id,
			employee_name,
				department_id,
					salary,
					avg(salary)over (partition by department_id order by salary desc)as dept_avg_salry 
					from employees)e
		
where salary > dept_avg_salary;


select customer_id,
	count(order_id) as total_orders,

	 sum(case when status='Completed' then 1 else 0 end) as completed_orders,
	 sum(case when status='Cancalled' then 1 else 0 end )as cancelled_orders,
	 sum(case when status='Completed' then 'amount' else 0 end )as completed_amount,
	 sum(case when status='Cancelled' then 'amount' else 0 ens ) as canclled_amount,
	 from employees
	 group by customer_id
	 order by customer_id;


select 
		customer_id,
				city,
					completed_amount,
						cancelled_amount from (select 
		customer_id, 
				city,
			sum(case when status='Completed' then ammount else 0 end)as completed_amount,
			sum(case when status='Cancelled' then amount else 0 end ) as cancelled_amount
			from orders 
			group by customer_id, city)as t
			where completed_amount >10000 and cancelled_amount <5000 ;

select 
	customer_id,
		city,
			completed_amount,
				cancelled_amount,
					pending_orders from(select 
		customer_id,
			city, 
			sum(case when status='Completed' then amount else 0 end) as completed_amount,
			sum(case when status='Cancelled' then amount else 0 end) as cancelled_amount,
			sum(case when status='Pending' then 1 else 0 end)as pending_orders
			 from orders 
			 group by customer_id, city )t 
			 where completed_amount >10000 and cancelled_amount <3000
			 and  pending_orders >= 1;


select
		customer_id,
				city,
				sum(amount)as total_amount,
		sum(case when status='Completed' then amount else 0 end) as completed_amount,
		sum(case when amount >5000 then 1 else 0 end ) as high_value_orders
		from orders 
		group by customer_id, city
		having sum(amount)>15000 and sum(case when status='Completed' then amount else 0 end) 
		>=sum(amount)*0.70 and  
		sum(case when amount >5000 then 1 else 0 end )>=2;

select 
		customer_id,
			city,
				sum(amount)as total_amount,
				sum(case when status='Completed' then amount else 0 end) as completed_amount,
				count(order_id)as total_orders,
				sum(case when status='Cancelled' then 1 else 0 end) as cancelled_orders,
				group by customer_id, city
				having total_amount > 20000 and sum(case when status='Completed' then amount else 0 end) >=
				sum(amount)*0.60 and count (order_id) >=3 and sum(case when status='Cancelled' then 1 else 0 end) 
				< count(order_id)*0.25;

select 
		customer_id,
				city,
				sum(amount)as total_amount,
			sum(case when status='Completed' then amount else 0 end)as completed_amount,			
sum(case when order_date >=2026-9-1 and order_date <=2026-9-30 and status='Completed' then 1 else 0 )
			as sep_cmp_orders
sum(case when order_date >=2026-9-1 and order_date <=2026-9-31 and status='Cancelled' then 1 else 0)
			as august_cancelled_orders
			group by customer_id, city
			having total_amount >15000 and sum(case when status='Completed' then amount else 0 end) >=
			sum(amount)*0.60 and sum(case when order_date >=2026-9-1 and order_date <=2026-9-30 and status='Completed' then 1 else 0 )>=1 and 
			sum(case when order_date >=2026-9-1 and order_date <=2026-9-31 and status='Cancelled' then 1 else 0)>=1;


select 
		customer_id,
				city,
	sum(case when  order_date >2026-08-01 and order_date <2026-09-1 then amount else 0 end)as august_amount,
sum(case when order_date >=2026-9-1 and order_date <2026-10-1 then amount else 0 end)as sep_amount,
sum(case when order_date >=2026-9-1 and order_date <2026-10-1 and status='Completed' then amount else 0 end)as
 sep_completed_amount
 group by customer_id, city,
 having august_amount>10000 and sep_amount >8000 and 
 sum(case when order_date >=2026-9-1 and order_date <2026-10-1 and status='Completed' then amount else 0 end) >=
sum(case when order_date >=2026-9-1 and order_date <2026-10-1 then amount else 0 end)*0.70 and
sum(case when order_date >=2026-8-1 and order_date <2026-9-30 then 1 else 0 end) >=1 as order_placedin_bothmonths;


select 
		o.customer_id,
			c.customer_name,
					c.city from customers 
					where exists(select 1 from orders o
					where c.customer_id=o.customer_id
					and status='Completed') and 
					not exists( select 1 from orders o
					where c.customer_id=o.customer_id and
					status='Cancelled') and
					exists(select 1 from orders o
					where c.customer_id=o.customer_id and
					o.order_amount>10000);
					
select customer_id,
		customer_name,
				city from customer c 
				where exists(select 1 from orders o
				where c.customer_id=o.customer_id and
				o.status='Completed'
				group by o.customer_id
				having count(*)>2 and sum(o.amount)>15000
			 and 
				not exists(select 1 from orders o
				where c.customer_id=o.customer_id and status='Cancelled');

select 
		c.customer_id,
			c.customer_name,
				c.city from customer c
				where exists(select 1 from orders o
				where c.customer_id=o.customer_id and o.status='Completed'
				group by customer_id 
				having count(*)>2 and sum(o.amount)>20000 and 
				exists(select 1 from orders o
				where c.customer_id=o.customer_id and having count(*)>=1 and status='Pending') and 
				not exists (select 1 from orders o
				where c.customer_id=o.customer_id and status='Cancelled');
			
select 
		c.customer_id,
			c.customer_name,
					c.city from customer c
					where exists (select 1 from customers c
					where c.customer_id=o.customer_id
					group by customer_id 
					having count(*)>=2 and o.status='Completed' and sum(o.amount>20000))
					and exists (select 1 from customers c where c.customer_id=o.customer_id and 
					o.status='Pending') and not exists(select 1 from customers c 
					where c.customer_id=o.customer_id and status='Cancelled');
select c.customer_id,
			c.customer_name,
				c.city from customers c 
				join orders o on c.customer_id=o.customer_id 
				group by customer_id,
						customer_name, city,
						having count(*)>=3 and 
			count (case when o.status='Completed' then 1 else 0 end)>=2 and 
			avg(case when o.status='Completed' then o.amount else 0 end)>8000 and 
			count (case when o.status='Cancelled' then 1 else 0 end)=0;

select c.customer_id,
		c.customer_name,
			c.city from customers c 
	where exists(select 1 from customers c 
	where c.customer_id=o.customer_id
	group bu c.customer_id and having count(*)>=3) and 
	exists(select 1 from customers c 
	where c.customer_id=o.customer_id and o.status='Completed' group by customer_id and
	having count(*)>=2) and  exists (select 1 from customers c where c.customer_id=o.customer_id and o.status='Completed'
	group by c.customer_id
	having avg(o.amount) >8000) and not exists (select 1 from customers c 
	where c.customer_id=o.customer_id  and status ='Cancelled');


select 
	c.customer_id,
		c.customer_name,
				c.city from customers c 
		where exists (select 1 from orders o 
		where c.cusotmer_id=o.customer_id
		group by c.customer_id
		having count(*)>=4) and exists (select 1 from orders o 
		where c.customer_id=o.customer_id
	 and o.status='Completed' group by c.customer_id
		having count(*)>=2 and sum(o.amount)>30000 and max(o.amount)>12000 and 
		exists (select 1 from orders o where c.customer_id=o.customer_id and status='Pending')and 
	not exists(select 1 from orders o where c.customer_id=o.customer_id and status='Cancelled');

select 
		c.customer_id,
			c.customer_name,
				c.city from customers c 
				join orders o on c.customer_id=o.customer_id
				group by c.customer_id, c.customer_name, c.city
				having count(*)>=4
		sum(case when o.status='Completed ' then 1 else end)>=2 and 
		sum(case when o.status='Completed' then o.amount else 0 end)>30000 and 
		max(case when o.status='Copleted' then o.amount else 0 end)>12000
	count(case when o.stsus='Pending' then 1 end)>1
	count (case when o.status='Cancelled' then 1 end)=0;

select 
		customer_id,
				customer_name,
						city from customers c 
		where exists (select 1 from orders o 
		where c.customer_id=o.customer_id
		group by customer_id
		having count(*)>5) and exists 
		(select 1 from orders o 
		where c.customer_id=o.customer_id and o.status='Completed' group by c.customer_id
		having count(*)>3 and sum(o.amount)>40000 and avg(o.amount)>10000) and
		exists(select 1 from orders o
		where c.customer_id=o.customer_id and o.status='Pending') and
		not exists(select 1 from orders o
		where c.customer_id=o.customer_id and o.status='Cancelled');

--Find employees whose salary is greater than the average salary of their own department.
select 
		e.employee_id,
			e.employee_name,
				d.department_id,
					e.salary,
						avg_dept_salary from(select 
		e.employee_id,
				e.employee_name,
					d.department_id,
							e.salary, avg(e.salary) as avg_dept_salary from employees e 
							group by d.department_id) t

where e.salary>avg_dept_salary;

select e1.employee_id,
		e1.employee_name,
			e1.department_name,
				e1.salary
		where e1.salary>(select avg(e2.salary)from employees e2
		where e2.department_id=e1.department_id);
			
--Find employees whose salary is equal to the highest salary in their own department.
select 
		e1.employee_id,
				e1.employee_name,
					e1.department_id,
						e1.salary
		where e1.salary=(select max(e2.salary) from employees e2
		where e2.department_id=e1.department_id);

--Find employees whose salary is less than the average salary of their department, 
--but greater than the minimum salary of their department.
select 
		e1.employee_id,
			e1.employee_name,
				e1.department_id,
					e1.salary 
		where e1.salary<(select avg(e2.salary)from employees e2 
		where e2.department_id=e1.department_id) and e1.salary>(select min(e3.salary)from employees e3
		where e3.department_id=e1.department_id);


select 
		e1.employee_id,
			e1.employee_name,
				e1.department_id,
					e1.salary 
		where e1.salary>(select avg(e2.salary)from employees e2
			where e2.department_id=e1.department_id) and 
	e1.salary<(select max(e3.salary) from employees e3 
		where e3.department_id=e1.department) and count (e1.employee_id)>=3 from employees e1;

select 
		e1.employee_id,
			e1.employee_name,
				e1.department_id,
					e1.salary
	where e1.salary>(select avg(e2.salary)from employees e2 
		where e2.department_id=e1.department_id) and
	e1.salary < (select max(e3.salary) from employees e3 
		where e3.department_id=e1.department_id) and 
		2>=(select count(*) from employees e4 where e4.department_id=e1.department_id
		and e4.salary>e1.salary);
					
select 
		e1.employee_id,
			e1.employee_name,
				e1.department_id,
					e1.salary 
		where e1.salary > (select avg(e2.salary) from employees e2
		where e1.department_id=e2.department_id) and 
		e1.salary<(select max(e3.salary) from employees e3 
		where e3.department_id=e1.department_id) and 
		(select(count(*) from employees e4 where e4.department_id=e1.department_id
		where e4.salary>e1.salary)>=1 and 
		not exists(select 1 from employees e5
		where e5.department_id=e1.department
		having e1.salary>=100000;
	

select 
		e1.employee_id,
			e1.employee_name,
				e1.department_id,
					e1.salary 
	where e1.salary>(select avg(e2.salary)from employees e1
		where e1.department_id=e2.department_id) and 
		e1.salary<(select max(e3.salary) from employees e3
			where e3.department_id=e1.department_id) and 
			(select count(*) from employees e4 
			where e4.department_id=e1.department_id where e4.salary>e1.salary)>=1 and 
			(select count(*) from employees e5 
			where e5.department_id=e1.department_id and e5.salary>100000)=0;
					
--Find employees whose salary is greater than every employee's 
--salary in their department, excluding themselves.
select 
		e1.employee_id,
			e1.employee_name,
				e1.department_id,
					e1.salary
			where e1.salary >= all  (select e2.salary 
			where e2.department_id=e1.department_id and 
			e2.employee_id<>e1.employee_id);

select 
		e1.employee_id,
			e1.employee_name,
				e1.department_id from employees e1 
				join employees e2 on e1.department_id=e2.department.id
				and e2.employee_id<>e1.employee_id
				group by e1.employee_id
				having e1.salary>=max(e2.salary);

--Find employees whose salary is higher than the average salary of their department 
--AND whose salary is lower than every employee earning more than the department average.
select 
		e1.employee_id,
			e1.employee_name,
				e1.department_id,
					e1.salary 
					where e1.salary>(select avg(e2.salary)from employees e2
					where e2.department_id=e1.department_id) and
					e1.salary <= all (select e3.salary from employees e3
					where e3.department_id=e1.department_id and 
					e3.salary>(select avg(e4.salary) from employees e4
					where e3.department_id=e4.department_id));
					
select 
		e1.employee_id,
				e1.employee_name,
					e1.department_id, 
							e1.salary 
 where e1.salary >(select avg(e2.salary) from employees e2
 	where e2.department_id=e1.department_id) and 
	 e1.salary <(select max(e3.salary) from employees e3
	 where e3.department_id=e1.department_id) and 
	 (select count(*) from employees e4 
	 where e4.department_id=e1.department_id)>=2 and e4.salary>e1.salary and 
	 (select e5.salary from employees e5 where e5.department_id=e1.department_id)=0;
							
-----DATE PART IN SQL=---

-----__________-------_______--------________-------

select 
		order_id,
			order_date,
			extract (year from order_date)as year,
			extract (month from order_date)as month,
				extract(quarter from order_date)as quarter;
			
--Find all orders placed in the year 2026 and month March--
select 
		order_id,
			customer_id,
				order_date,
			amount from orders 
			extract (year from order_date)=2026,
			extract(month from order_date)=3;

--Using the orders table, add 10 days to every order_date.
select 
		order_id,
			order_date,
				order_date+interval '10 days' as new_date 
				from orders;

--Find the date 30 days before each order_date.
select 
		order_id,
			order_date
			order_date- interval '30 days' as previous_date 
			from orders;

--Write a query to calculate how many days each order took to deliver.
select 
		order_id,
			order_date,
				delivery_date,
					order_date-delivery_date as delivery_days 
					from orders;


--Write a query to calculate the exact interval between the two dates using AGE().
select 
		order_id,
			order_date,
				delivery_date,
					age(order_date,delivery_date)as duration
					from orders;

select 
		order_id,
	order_date,
		delivery_date,
			age(delivery_date,order_date) as duration 
			from orders;
			
select 
	order_id,
		order_date,
		date_trunc('month',order_date)as month_start
		from orders;

--Using orders, calculate the total sales for each month.
select 	
		order_id, 
			order_date,
				date_trunc('month', order_date)as month_start,
				sum(amount)as total_sales from orders
				group by date_trunc('month', order_date)
				order by month_start;

--Using the orders table, calculate the total sales for each quarter of each year.s
select  
		extract(quarter from order_date)as quarter,
			sum(amount)as total_sales 
	from orders 
				group by extract(quarter from order_date)
		order by quarter;
		
--Find all orders placed between January 1, 2026 and March 31, 2026.
select 
		order_id,
			order_date, amount
			from orders where 
				order_date between date(2026, 1, 1) and date(2026, 3, 31)as orders_frm_perticular_days;
				
--Find the total sales and number of orders placed between January 1, 2026 and March 31, 2026.
select 
		order_id, 
			order_date, 
				amount ,
			sum(amount)as total_sales
				count(order_id) as order_count from orders where 
			order_date between date '2026-1-1' and date '2026-3-31';


--Using the orders table, calculate total sales for each month in 2026.
select 
		order_id, 
			order_date, 
				amount,
				extract ('month' from order_date)as each_month,
				sum(AMOUNT)as total_sales
				from orders
			where extract ('year' from orders)=2026
			group by extract('year' from orders)
			order by each_month;

select 
	sum(amount)as total_sales,
	extract(month from order_date)as each_month from orders 
	where extract(year from order_date)=2026
	group by extract(month from order_date)
	order by each_month;

--Using orders, calculate monthly total sales for 2026 using DATE_TRUNC().
select 
	date_trunc('month',order_date)as month,
	sum(amount)as total_sales
	from orders
	where date_trunc('year', order_date)=2026
	group by date_trunc('month',order_date)
	order by month;

select 
		date_trunc('month',order_date)as month,
			sum(amount)as total_sales
			from orders
			where date_trunc('year', order_date)=date '2026-1-1'
			group by date_trunc('month',order_date)
			order by month;

--Find the total sales for each month of 2026, but this time return the month as a month name
--(January, February, etc.) instead of a month number or timestamp.
select 
		sum(amount)as total_sales,
		 extract(month from order_date) as january, 
		 extract(month from order_date) as february,
		 extract(month from order_date) as march
		 from orders 
		where extract(year from orders)=2026
		group by  extract(month from order_date) as january, 
		 extract(month from order_date) as february,
		 extract(month from order_date) as march
		 order by 'january', 'february', 'march';

select 
		sum(amount)as total_sales,
		to_char(order_date, 'month')as month_name 
		from orders 
		where extract(year from order_date)=2026
		group by to_char(order_date, 'month'),
		extract(month from order_date)
		order by extract (month from order_date);

--Using the orders table, find the number of orders placed on each day of the week in 2026.
select 
		count(order_id)as num_orders,
		to_char( order_date, 'day')as days,
		extract(week from order_date)as week
		from orders
		where extract(year from order_date)=2026
		group by extract(day from order_date),to_char(order_date,'month')
		order by extract(day from order_date);

select 
		count(order_id)as num_orders,
		to_char(order_date,'fmday')as days
		from orders 
		where extract(year from order_date)=2026
		group by to_char(order_date,'fmday'),
		extract(isodow from order_date)
		order by (isodow from order_date);

--Using orders, find the average order amount for each day of the week in 2026.
select 
		avg(amount)as avg_amount,
		to_char(order_date, 'fmday')as days
		from orders 
		where extract (year from order_date)=2026
		group by to_char(order_date,'fmday'),
			extract(isodow from order_date)
			order by extract (isodow from order_date);

--Find the average order amount for each month of 2026, showing:		
select 
		round(avg(amount),2)as avg_order_amount,
		to_char(order_date, 'fmmonth')as each_month 
		from orders
		where extract (year from order_date)=2026
		group by to_char(order_date, 'fmmonth'),
		extract (month from order_date)
		order by extract(month from order_date);

--Find the total sales for each quarter of 2026.
select 
		sum(amount)as total_sales,
		extract(quarter from order_date)as each_quarter
		from orders
		where extract(year from order_date)=2026
		group by extract(quarter from order_date)
		order by extract(quarter from order_date);

--For each customer, find the number of days between their first order and their latest order.
select cusotmer_id,
		first_order,
			latest_order,
			latest_order-first_order as days_diff
			from orders
			group by customer_id;

select 
	customer_id,
		min(order_date)as first_order,
		max(order_date)as latest_order,
		max(order_date) - min(order_date)as days_diff
		from orders 
		group by customer_id;


select 
		customer_id,
			min(order_date)as first_order,
				max(order_date)as last_order,
			max(order_date) - min(order_date) as days_diff
					count(order_id)as order_count
					from orders
				group by customer_id;
				
select 	
		customre_id, count(order_id)as total_orders
			min(order_date)as first_order
			max(order_date 'interval' 30 days )as latest_order
			max(order_date 'interval' 30 days)-min(order_date)as days_diff
			from orders
			where extract(year from orders)=2026
			group by customer_id
			having count(order_id)>=3;

select 
		customer_id,
			min(order_date)as first_order,
				max(order_date)as latest_order,
			max(order_date)-min(order_date)as days_diff
		sum(order_id)as total_orders
		from orders
		having extract(year from min(order_date))=2026 and 
		extract max(order_date)-min(order_date)>=30 and 
		sum(order_id) >3;
		
--Using the orders table, find the number of days between each customer's consecutive orders.		
select 
		customer_id, 
			order_date,
		lag(order_date) over (partition by customer_id order by order_date) as previous_order,
		order_date - lag(order_date) over (partition by customer_id order by order_date) as days_between
		from orders
		group by customer_id, order_date;
 				

--Now we're ready for Q24 — longest gap between consecutive orders. 🔥
(select 
	customer_id,
		order_date,
			days_gap from (select 
	customer_id,
		order_date,
			previous_order,
				days_gap,
					dense_rnk() over (order by days_gap desc)as rnk from
					(select 
		customer_id,
			order_date, 
			lag(order_date) over (partition by customer_id order by order_date desc)as previous_order,
			order_date - lag(order_date) over (partition by customer_id order by order_date desc) days_gap 
			from orders) t)x where rnk=1;
			
select 
	customerid,
		days_gap,
			max(days_gap) as longest_gap from(select 
		customer_id,
			order_date,
				order_date-lag(order_date) over (partition by customer_id order by order_date)as days_gap
				from orders)t
				having count(days_gap) >0;
				

select 
	customer_id,
		order_date,
			total_orders,
				previous_order,
					orders_within_7days,
						orders_within_7days*100/count(previous_order) as percentage from(select 
		customer_id,
			order_date,
				total_orders,
					previous_order,
					count(case when order_date-previous_order then 1 else 0 end )as orders_within_7days from
					(select 
		customer_id,
			order_date,	
		count(order_id)as total_orders,
	lag(order_date) over (partition by customer_id order by order_date)as previous_order
	from orders)t)
	group by customer_id;


select 
	customer_id,	
		order_date,
			total_orders,
				previous_order,
					gap,
					max(gap)as longest_gap(select
		customer_id,	
			order_date, 
				total_orders,
					previous_order,
			count(case when order_date-previous_order <=30 then 1 else 0 end)as gap from(select 
		customer_id,	
			order_date,
				count(order_id) as total_orders,
			lag(order_date) over(partition by customer_id order by order_date)as previous_order
			from orders)t)v
			group by customer_id;

select 
	customer_id,
		order_date,
			toal_orders,
				previous_order, 
			count(case when order_date-previous_order >30 then 1 elso 0 end)as orders_after_30days,
			max(order_date-previous_order)as longest_gap from
			(select 
		customer_id,
			order_date,
				count(order_id)as total_orders,
			lag(order_date) over (partition by customer_id order by order_date)as previous_order 
			from orders)t 
group by customer_id;

select 
		customer_id,
			order_date,
				first_order,
					latest_order,
						previous_order,
				count(case when order_date-previous_order >30 then 1 else 0 end)orders_after_30days
			max(order_date-previous_order)as long_gap
				from (select 
		customer_id,
				order_date,
					min(order_date)as first_order,
				max(order_date)as latest_order,
	lag(order_date) over(partition by customer_id order by order_date)as previous_order
	from orders)t
	group by customer_id
	having long_gap >30;


select 
	customer_id,
		order_date,
		total_orders,
			previous_order,
	sum(case when order_date - previous_order <=7 then 1 else 0 end) as 7days_orders,
		sum(case when order_date - previous_order >30 then 1 else 0 end) as 30days_orders from 
			max(order_date-previous_order)as long_gap
			to_char(min(order_date),'fmmonth') as first_order_month from(select 
		customer_id,
			order_date,
				count(order_id) as total_orders,
			lag(order_date) over (partition by customer_id order by order_date)as previous_order
			from orders)t
				group by customer_id, order_date
				having total_orders >=3;
		
select 
		customer_id,
			order_date,
				previous_order,	
					sum(order_id) as total_orders,
			avg(order_date-previous_order)as avg_gap, 
		sum(case when order_date-previous_order <=14 then 1 else end)as 14_days_orders,
	sum(case when order_date-previous_order >60 then else end) as after_60_days_orders,
		max(order_date-previous_order)as longest_gap,
		extract (month from max(order_date))as latest_order_month from
		(select 
		customer_id,
			order_date,
		lag(order_date) over (partition by customer_id order by order_Date)as previous_order
		from orders)t
		group by customer_id,
			order_date
			having sum(order_id)>=4;


select 
		customer_id,
			order_date,	
				first_order,
					last_order, count(order_id)as total_orders,
					first_order-last_order as days_between_first_last,
				sum(case when order_date-first_order <=30 then 1 else end) as 30days_orders,
			sum(case when order_date-first_order >90 then 1 else end) as orders_after_90days from 
			(select 
		customer_id,	
			order_date,
				min(order_date)over (partition by customer_id) as first_order,
					max(order_date)over (partition by customer_id) as latest_order
					from orders) t 
					group by customer_id,
						having count(order_id) >=3;

select 
	customer_id,
		order_date,
			previous_order, count(order_id) as total_orders,
		min(order_date) over(partition by customer_id) as first_order_date,
			max(order_date) over (partition by customer_id) as latest_order_date,
			sum(case when order_date-previous_order <=7 then else 0 end) as 7days_orders,
		max(order_date-previous_order) as longest_gap,
		previous>1 as repeat_orders from(select 
		cusstomer_id,	
			order_date,
			lag(order_date) over(partition by customer_id order by order_date)as previous_order
			from orders)t
			group by customer_id, order_date
			having count(order_id) >=4;
		

select 
		customer_id,
			order_date,
			  previous_order,
			  min(order_date) over (partition by customer_id) as first_order,
			  	max(order_date)s over (partition by customer_id)as latest_order,
			sum(case when order_date-previous_order <7 then 1 else 0 end) as 7days_orders,
			sum(case when previous_order is not null then 1 else 0 end)as repeat_orders,
		max(order_date-previous_order)as longest_gap from select(
		customer_id,
			order_date,
				lag(order_date) over (partition by customer_id order by order_date) previous_order
				from orders)t
				group by customer_id
				having count(order_id)>=4;

select 
		customer_id,
			order_date,
				previous_order,
			min(order_date) over (partition by customer_id) as first_order,
				max(order_date) over (partition customer_id)as latest_order,
			sum(amount) as total_spend,
		count(order_id) as total_orders,
	sum(case when previous_order is not null then 1 else 0 end)days_since_previous_order,
		sum(case when previous_order >30 then 1 else 0 end ) 30days_orders,
			max(order_date-previous_order) as longest_gap from (select 
		customer_id,
			order_date,
				lag(order_date) over(partition  by customer_id order by order_date)as previous_order
		from orders)t 
		group by customer_id
		having count(*) >=4;


select 
	customer_id,
			order_date,
				first_order,
					latest_order,
						min(amount) over(partition by customer_id order by order_date)as first_order_amount,
					max(amount) over (partition by customer_id order by order_date)as latest_order_amount,
min(amount) over(partition by customer_id order by order_date)	- 		max(amount) over (partition by customer_id order by order_date)
as sped_diff,
max(order_date-lag(order_date) over (partition by customer_id))as longest_gap
from(select 
		customer_id,
			order_date,
				min(order_date) over (partition by customer_id) as first_order,
			max(order_date) over (partition by customer_id) as latest_order
			from orders)t
		group by customer_id
		having count(*)>=4;


select 
	customer_id,
		order_date,
			first_order_amount,
				latest_order_amount,
					avg_order_amount,
						max(latest_order_amount-avg_order_amount) as diff_amount,
			max(order_date-lag(order_date) over (partition by customer_id order by order_date) as longest_gap, 
		sum(case when order_date-previous_order >30 then 1 else 0 end) as order_after_30_days from
			(select
		customer_id ,
			order_date,
				first_value(amount)over (partition by customer_id order by order_date)as first_order_amount,
		first_value(amount) over (partition by customer_id order by order_date desc)as latest_order_amount,
		avg(amount) over (partition by customer_id)as avg_order_amount
		from orders)t
		group by customer_id
		having count(*)>=4;

select 
		employee_name,
				sale_date,
					amount,
				lag(amount) over(partition by employee_id order by amount )as previous_sale_amount,
		avg(amount) over (partition by employee_id) as employee_avg_amount,
			row_number()over (partition by employee_id order by amount)as sales_rnk
			from employee_sales;


 select 
 			customer_id,
			 	order_date,
				 	amount,
			lag(amount) over (partition by customer_id order by order_date)as previous_amount,
			amount-lag(amount) over (partition by customer_id order by order_date) as diff_from_previous,
			sum(amount) over (partition by employee_id order by order_date,
			rows between preceding rows and current row and 
			rows between unbounded following and current row
			)as running_total
			from employees;



select
		customer_id,
				order_date,
					amount,
				lag(order_date) over(partition by customer_id order by order_date) as previous_amount,
			sum(amount) over(partition by customer_id order by order_date,
				rows between unbounded preceding and current row)as running_total,
		avg(amount)over (partition by customer_id order by order_date,
		range between unbounded preceding and current row)as running_avg,
		row_number() over (partition by customer_id order by amount desc )as rnk
		from employees
		where row_number() over (partition by customer_id order by amount desc ) =1;


select 
		customer_id,
			order_date,
					amount,
				lag(amount) over (partition by customer_id order by order_date)as previous_amount,
		sum(amount)over (partition by customer_id order by order_date,
			rows between unbounded preceding and current row)as running_total,
	avg(amount) over (partition by customer_id order by order_date,
		roes between unbounded preceding and current row) running_avg,
			max(amount) over (partition by customer_id order by order_date,
				rows between unbounded preceding and current row)as highest_amount_so_far
				from employees;

select 
		customer_id, 
			order_date,
				amount,
			lag(ammount) over (partition by customer_id order by order_date)as previous_amount,
	amount- lag(ammount) over (partition by customer_id order by order_date) as amount_change,
		sum(amount) over (partition by customer_id order by order_date,
		rows between unbounded preceding and current row)as running_total,
	max(amount) over (partition by customer_id order by order_date) customer_max_amount,
		row_number() over (order by max(amount) over (partition by customer_id order by order_date) desc)rnk_by_amount
		from employees;

SELECT 
    customer_id,
    order_date,
    amount,

    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS previous_amount,

    amount - LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS amount_change,

    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,

    MAX(amount) OVER (
        PARTITION BY customer_id
    ) AS customer_max_amount,

    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY amount DESC
    ) AS rank_by_amount

FROM orders;


select 
		customer_id,
			order_date,
				amount,
					lag(amount) over (partition by customer_id order by order_date) as previous_amount,
			amount- lag(amount) over (partition by customer_id order by order_date) as amount_change,
		sum(amount`) over (partition by customer_id order by order_date,
			rows between unbounded preceding and current row) as running_total,
	avg(amount) over (partition by customer_id order by order_date,
				rows between unbounded preceding and current row) as running_avg,
	max(amount) over (partition by customer_id order by order_date,
		rows between unbounded preceding and current row) as highest_amount_so_far,
		row_number(amount) over (partition by customer_id order by amount desc)as rnk_by_amount;
				
select 
		customer_id,
			order_date,
				amount,
					previous_order, max(order_date) over (partition by customer_id)as letest_order,
		sum(case when order_date-previous_order then 1 else 0 end)as days_since_previous_order,
		count(order_id) as total_orders from(select 
		customer_id,
			order_date,
				amount,
			lag(order_date) over (partition by customer_id order by order_date)as previous_order
			from orders)t
			group by customer_id, order_date;
		

select 
	customer_id,
		order_date,
			amount,
				previous_order_date,
					total_orders,
				order_date-previous_order_date as days_since_previous_order from(select 
	customer_id,
			order_date,
				amount,
			lag(amount) over (partition by customer_id order by order_id) as previous_order_date,
			count(order_id) over (partiton by customer_id) as total_orders,
		row_number() over (partition by customer_id order by order_date desc)as rnk
		from orders)T
		where rnk=1
		
select 
		customer_id,
			letest_order_date,
				letest_amount,
					avg_amount,
				total_orders from (select 
		customer_id,
		row_number() over (partition by customer_id order by order_date desc)as letest_order_date,
	row_number() over (partition by customer_id order by amount desc)as letest_amount,
		avg(amount) over(partition by customer_id)as avg_amount,
			count(order_id)as total_orders
			from orders)t 
			where letest_amount > avg_amount
			having total_orders >=3;

select 
	customer_id,
		avg_amount,
			total_orders,
				order_date as first_order_date,
					amount as first_order_amount from(select 
		customer_id,
		 	avg(amount) as avg_amount,
			 count(order_id) over (partition by customer_id) as total_orders,
		row_number()over(partition by customer_id order by order_date desc)as rnk
		from orders)t
		where rnk=1
		 and total_orders>=3 and 
		 amount > avg_amount;

select 
	customer_id,
		first_order_date,
			first_order_amount,
				avg_amount,
					total_orders from
					(select 
	customer_id,
		first_value(order_date) over(partition by customer_id order by order_date desc)as first_order_date,
	first_value(amount) over(partition by customer_id order by order_date desc)as first_order_amount,
	avg(amount) over(partition by customer_id)as avg_amount,
	count(order_id) over(partition by customer_id)as total_orders,
	row_number() over (partition by customer_id order by order_date desc)as rnk
	from orders) t 
	where rnk=1 and total_orders>=3 and amount>avg_amount;
			
select
		order_id,
			order_date,
				amount,
					lag(amount) over (partition by customer_id order by order_date)as previous_amount,
			amount-lag(amount) over (partition by customer_id order by order_date) as diff_amount,
		avg(amount) over (partition by customer_id order by order_date,
		rows between unbounded preceding and current row) as running_avg
		from orders;
		
select order_id,
		order_date,
			amount,
			prev_order_date,
				days_since_prev_order,
					max_order_amount,
						first_order_date as first_order_amount from
		(select 
		order_id,
			order_date,
				amount,
					lag(order_date) over(partition by customer_id order by order_date)as previous_order_date,
order_date-	lag(order_date) over(partition by customer_id order by order_date)>='interval 30days' as days_since_prev_order,
	max(amount) over(partition by customer_id order by order_date)as max_order_amount,
min(order_date)as first_order_date)t	
					group by customer_id
						order_date;


select * from(select 
			order_id,
				order_date,
						amount,
				lag(order_date) over (partition by customer_id order by order_date)as previous_order_date,
amount-lag(order_date) over (partition by customer_id order by order_date) as days_diff,
 max(amount) over (partition by customer_id order by order_date,
 	rows between unbounded preceding and current row)as max_order_amount,
	 first value(amount) over(partition by customer_id order by order_date)as  first_order_amount)t
	 where days_diff >30
	 group by customer_id, 	order_date
					
			
select 
	order_id,
		order_date,
			amount,
				previous_amount,
					next_amount,
						from (select
		order_id,
			order_date,
				amount,
		lag(amount) over(partition by customerr_id order by order_date)as previous_amount,
lead(amount) over(partition by customer_id order by order_date)as next_amount,
			row_number() over(partition by customer_id order by amount,order_date desc)as rnk
			from orders)t
where rnk=1
group by customer_id, order_date;


select 
	customer_id,
		total_orders,
			total_amount,
				avg_amount,
					max_order_amount
				orders_above_customers_avg from(select 
		customer_id, 
				count(order_id) over(partition by customer_id)as total_orders,	
			sum(amount) over (partition by customer_id)as total_amount,
		avg(amount) over(partition by customer_id)as avg_amount,
			max(amount) over(partition by customer_id order by order_date)as max_order_amount,
count(*) filter(where amount> avg(amount) over (partition by customer_id)) over (partition by customer_id) as 
		orders_above_customers_avg from orders)t
	where total_orders >3 and orders_above_customers_avg >2;
			
				
select 
		customer_id,
			total_orders,
				avg_amount,
					max_amount,
						orders_above_avg from(select 
		customer_id,
			count(*) over(partition by customer_id)as total_orders,
			avg(amount) over(partition by customer_id)as avg_amount,
		max(amount) over(partition by customer_id ) as max_amount,
	count(*) filter( where amount>avg(amount) over(partition by customer_id ))over(partition by customer_id)
		as order_above_avg from
		(select *, avg(amount) over(partition by customer_id)as avg_amount
		from orders)t)u
		where total_orders >=4 and max_amount >2*amount and orders above_avg >=2;


select 
	customer_id,
			total_orders,
				total_amount,
					avg_amount,
						highest_amount from(select 
		customer_id,
				count(order_id) over (partition by customer_id) as total_orders,
					sum(amount) over (partition by customer_id)as total_amount,
				max(amount) over (partition by customer_id) as highest_amount,
	cout(*) filter(where amount>avg_amount over(partition by customer_id)) over(partition by customer_id) as 
		orders_above_customer_avg
	first_value(amount) over (partition by customer_id order by order_date desc) as latest_order_amount 
			from(select *, avg(amount) over (partition by customer_id)as avg_amount
			 		from orders)t)y
					 having total_orders >=2
					 where amount>(select avg(amount)as avg_amount
					 from orders) and latest_order_amount;
			
select customer_id,
		total_orders,
			total_amount,
				highest_amount,
					orders_above_customer_avg,
						letest_order_amount,
						from(select 
		customer_id,
			count(*) over(partition by customer_id)as total_orders,
			sum(amount) over (partition by customer_id)as total_amount,
			max(amount) over (partition by customer_id) as highest_amount,
	count(*) filter(amount > customer_avg) over (partition by customer_id)as orders_above_customer_avg,
		first_value(amount) over(partition by customer_id order by order_date desc)as latest_order_amount
	 from( select *, avg(amount)over (partition by customer_id)as customer_avg
		from orders)u)
		where total_orders >=2;


select 
		customer_id,
			total_orders,
				total_amount,
					letest_amount as letest_order_date,
						previous_amount as previous_order_date
							letest_amount-previous_amount as amount_diff,
						letest_order_date-previous_order_date as days_diff from
						(select 
		customer_id, 
			count(*) over(partition by customer_id) as total_orders,
			sum(amount) over(partition by customer_id)as total_amount,
			lag(amount) over(partition by customer_id order by order_date desc)as letest_amount,
			lag(amount) over(partition by customer_id order by order_date)as previous_amount
				from orders)t
				group by customer_id,
				having total_orders >=3;
				

select 
		cistomer_id,
			total_orders,
			total_amount,	
				avg_amount,
				orders_above_avg,
			orders_below_avg,
				percentage
				from
					(select 
	customer_id, 
		count(*) as total_orders,
			sum(amount) as total_amount,
		count(*) filter(amount > avg_amount) over(partition by customer_id)as orders_above_avg,
	count(*) filter(amount < avg_amount) over(Partition by customer_id) as orders_below_avg,
	round(count(*) filter(where amount >avg_amount)*100 / count(*), 2 as percentage
				from(select *, avg(ampunt) over(partition by customer_id)as avg_amoumt
				from orders)t)u)
				group by customer_id,
				having total_orders >=3;

select 
	customer_id,
			total_orders,
				avg_amount,
					max_amount,
						orders_above_avg,
							orders_below_avg,
								percentage from
							(select 
		customer_id,
			count(*) over(partition by customer_id) as total_orders,
				avg_amount,
					max_amount,
			count(*) filter(where amount >avg_amount) over(partition by customer_id)as orders_above_avg,
		count(*) filter(where amount=avg_amount) over(partition by customer_id)as orders_equals_to_avg,
	count(*) filter(where amount<avg_amount) over(partition by customer_id)as orders_below_avg,
		round(count(*) filter(where amount>avg_amount)*100 /count(*)over (partition by customer_id),2) as percentage
			from(select 
			customer_id,	
			amount,avg(amount) over(partition by customer_id)as avg_amount,
					max(amount) over (partition by customer_id) as max_amount)t)u
				where total_orders >=3;	
				
select 
		customer_id,
			count(*) over(partition by customer_id)as total_orders,
				avg_amount,
					max_amount,
						min_amount,
		count(*) filter(where amount>avg_mount) over(partition by customer_id)as orders_above_avg,
	count(*) filter(where amount=avg_amount) over(partition by customer_id) as orders_equals_avg,
	count(*) filter(where amount<avg_amount) ovre(partition by customer_id)as orders_below_avg,
		round(count(*) filter(where amount>avg_amount)*100/count(*) over(partition by customer_id),2)as above_percent,
round( count(*) filter(where amount<avg_aount)*100/count(*) over(partition by customer_id),2)as below_percent
		
			from(select 
			customer_id,
				amount,
					avg(amount) over (partition by customer_id)as avg_amount,
						max(amount) over(partition by customer_is) as max_amount,
							min(amount) over(partition by customer_id)as min_amount from orders)t
							group by customer_id,
								avg_amount,	
								max_amount,
									min_amount,
										amount
										having count(*) over(partition by customer_id) >=3;
					

select 
	employee_id,
		max(streak) as longest_streak fro(select 
	employee_id,
		login_date,
			grp
			count(*) over (partition by employee_id, grp)as streak from
			(select 
		employee_id,
				login_date,
			sum(case when login_date=lag(login_date)over(partition by employee_id order by login_date)+1 
			then 0 else 1 end) over (partition by customer_id order by login_date)as grp from 
				employees)t)U
				group by employee_id;

select 
	employee_id,
		streak from
				(select 
	employee_id,
			login_date,
				grp,
				count(*) over(partition by employee_id,grp)as streak
				from(select 
		employee_id,
			login_date,
	sum(case when login_date=lag(login_date) over (partition by employee_id order by login_date)+
			then 0 else 1 end) over (partition by employee_id order by login_date)as grp 
				from employee_logins)t)u
				group by employee_id
				having streak >=3;

select 
	employee_id,
		count(*)as streak from(select 
		employee_id,
			login_date,
				grp,
			sum(new_grp) over(partition by employee_id, new_grp) as grp from
		(select 
		employee_id,
				login_date,
case when login_date=lag(login_date) over(partition by customer_id order by login_date)+1 
	then 0 else 1 end as new_grp
	from employee_logins)t)u 
	group by employee_id, grp)v
	group by employee_id,
		having max(streak) >=3;

select	
	employee_id,
		max(streak) as longest_streak from(select 
		employee_id,
			count(*)  as streak from(select 
	employee_id,
		login_date,
			new_grp,
		sum(new_grp) over (partition by employee_id, new_grp)as grp
	from(select  employee_id,
			login_date,
case when login_date=lag(login_date) over(partition by employee_id order by login_date)+1 then o else 1 end as new_grp
	from employees_login)t)u
	group by employee_id, grp)v
	group by employee_id;


select 
	employee_id,
		streak,
		max(streak) as max_streak_length from(select 
		employee_id,
			grp,
		count(*) as streak from (select 
		employee_id,
			login_date,	
				new_grp,
		sum(new_grp) over (partition by employee_id order by login_date) as grp from
		(select 
		employee_id,
				login_date,
case when login_date=lag(login_date) over (partition by employee_id order by logIn_date)+1 
		then 0 else 1 end as new_grp 
			from employee_logins)t)u
			group by employee_id, grp)v 
			group by employee_id
			having max(streak)=3;
			

select 
	employee_id,
		max(streak)as lonest_streak,
			count( distinct streak) as streak_counts from(select 
		employee_id,
			grp,
	count(*) as streak
	from(select employee_id,
		login_date,
			new_grp,
sum(new_grp) over (partition by employee_id order by login_date ) as grp from
	(select 
		employee_id,
			login_date,
case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1 
		then 0 else 1 as new_grp from employee_logins)t)u group by employee_id, grp)v
			group by employee_id
			having count( disctinct streak)>2;


select	employee_id,
		max(streak) as longest_streak 
		from(select  employee_id, grp, 
		count(*) as streak from (select 
	employee_id,
		login_date,
			new_grp,
	sum(new_grp) over (partition by  employee_id order by login_date) as grp 
	from(select 
	employee_id,
		login_date,
case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1
	then 0 else 1 end as new_grp from employee_logins)t)u
		group by employee_id, grp)v group by employee_id
		having max(streak) >=3;
			
select employee_id, rnk from(select employee_id,
	dense_rank()over (partition by employee_id, streak order by login_date)as rnk
	from(select employee_id,
	count(*)as streak from (select employee_id,
		login_date,
			new_grp,
	sum(case when new_grp=1 then 1 else 0 end) over
			(partition by customer_id order by login_date)as grp from(select 
		employee_id,
			login_date,
case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1
		then 0 else 1 end as new_grp from employee_logins)t)u
		group by employee_id, grp)v group by employee_id)w)x
		group by employee_id
		where rnk=2;


select 
	employee_id,rnk from(select employee_id,
	streak,
		dense_rank()over (partition by employee_id order by streak desc ) as rnk from
		(select 
	employee_id,
		count (*)as streak from  (select 
		employee_id,
			login_date,
				new_grp,
		sum(new_grp) over (partition by employee_id order by login_date) as grp from
		(select 
		employee_id,
			login_date,
case when login_date=lag(login_date) over(partition by employee_id order by login_date)+1 
	then 0 else 1 end as new_grp from employees_logins)t 
	)u group by employee_id, grp)v)w
	where rnk=2;

 
select employee_id,
		login_date,
			grp, 
			min(login_date) as start_date,
				max(login_date) as end_date,
				count(*)as streak from (select 
	employee_id,
			login_date,
				new_grp,
	sum(new_grp) over (partition by employee_id order by login_date) as grp from
	(select 
		employee_id,
				login_date,
case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1
	then 0 else 1 end as new_grp from employee_logins)t)U 
	group by employee_id, grp
having count(*) >=2
order by employee_id;


select 
	employee_id, start_date,
		end_date,
			streak, max(streak) as longest_streak from
		(select 
		employee_id,
			login_date,
				count(*)as streak,
					min(login_date)as start_date,
						max(login_date)as end_date,
				dense_rank() (over partition by employee_id order by count(*) desc)as rnk
				from (select 
		employee_id,
			login_date,
				grp,
	 from 
		(select 
		employee_id,
			login_date,
				new_grp,
	sum(new_grp) over (partition by employee_id order by login_Date) as grp 
		from(select 
		employee_id,
			login_date,
	case when login_date=lag(login_id) over (partition by employee_id order by login_date)+1 then 0 else 1 
		end  as new_grp from employee_logins)t)u group by employee_id, grp)v)
	where rnk=1
			order by employee_id;
			

select 
	employee_id,
		start_date,
		end_date,	
		streak,
			max(streak)as longest_streak  from(select 
		employee_id,
			login_date, grp,
				min(login_date) as start_date,
					max(login_date)as end_date,
					count(*) as streak, 
					dense_rank () over (partition by employee_id order by count(*) desc) as rnk from
					(select 
	employee_id,
			login_date,
				new_grp,
		sum(new_grp) over (partition by employee_id order by login_date) as grp from
		(select 
		employee_id, 
			login_date,
case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1 
	then 0 else 1 end as new_grp from employee_logins)t)u  
	group by employee_id, grp)v
	where rnk=1 
	having streak >=2
	order by employee_id;


select 
		employee_id,
			login_date,
				start_date,
					end_date,
					coalesce(inactive_days,0)as inactive_days from (select 
		employee_id,
		login_date,
			start_date,
				end_date,
				streak,
		start_date-lag(login_date) over (partition by employee_id order by login_date)-1 as inactive_days,
		dense_rank() over (partition by employee_id order by streak desc)as rnk
		from
		(select 
		employee_id,
		login_date,
			min(login_date) as start_date,
			max(login_Date)as end_date,
				count(*)as streak from
				(select 
	employee_id,
		login_date,
	new_grp,
		sum(new_grp) over (partition by employee_id order by login_date)as grp from
	(select 
		employee_id,
			login_date,
	case when login_date=lag(over) (partition by employee_id order by login_date)+1
		then 0 else 1 as new_grp
from employee_logins)t)u group by employee_id, grp)v)w
	where rnk=1
	order by employee_id;

select 
		employee_id,
			login_date,
				streak_length,
				inactive_days_after, 
				inactive_days_before from (select employee_id,
		login_date,
			sum(streak)as streak_length,
start_date-lag(login_date) over (partition by employee_id order by login_date) -1 as inactive_days_before,
start_date-lead(login_date) over (partition by employee_id order by login_date)+1 as inactive_days_after,
dense_rank() over (partition by employee_id order by streak)as rnk
from
(select 
		employee_id,
			login_date,
				grp,
				count(*) as streak,
			min(login_date)as start_date,
				max(login_date) as end_date from(select 
		employee_id,
			login_date,
				new_grp,
sum(new_grp) over (partition by employee_id order by login_date)as grp from
	(select 
		employee_id,
			login_date,
case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1 
	then 0 else 1 end as new_grp from employee_logins)t)u 
	group by employee_id, grp)v)w
	where streak_length=1
	order by employee_id;

select 
		employee_id,
			login_date,
				start_date,
					end_date,
						coalesce (inactive_days_before,0) as inactive_days_before,
						coalesce (inactive_days_after,0)as inactive_days_after 
						from(select 
	employee_id,
		login_date,
		start_date,
			end_date,
	start_date-lag(end_date) over (partition by employee_id order by start_date)-1 as inactive_days_before,
lead(start_date) over (partition by employee_id order by start_date)-end_date - 1 as inactive_days_after,
	dense_rank() over (partition by employee_id order by streak desc )as rnk from
	(select 
	employee_id,
		login_date,
			grp,
				count(*)as streak,
				min(login_date) as start_date,
				max(login_date) as end_date from(select 
	employee_id,
		login_date,
			new_grp,
		sum(new_grp) over (partition by employee_id order by login_date) as grp from
		(select 
		employee_id,
			login_date,
case when login_date=lag(login-date) over (partition by employee_id order by login_date)+1 
		then 0 else 1 end as new_grp 
		from employee_logins)t)u group by employee_id, grp)v)w
		where rnk=1
		order by employee_id;


select employee_id,
	streak,
		min(login_date) as streak_start,
			max(login_date) as streak_end
			from(select employee_id,
		grp,
			count(*)as streak,
			dense_rank() over (partition by employee_id order by count(*) desc) as rnk
			from  (select 
		employee_id,
			login_date,
				new_grp,
		sum(new_grp) over (partition by employee_id order by login_date)as grp
		from (select 
		employee_id,
			login_date,
	case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1 
		then 0 else 1 end as new_grp from employee_logins)t)u group by employee_id, grp)v
		where rnk=1
		order by employee_id;


select 
		employee_id,
			min(salary_month)as start_date,
				max(salary_month) as end_date,
				streak from(select 
		employee_id,
			salary_month,
				grp,
					count(*)as streak, 
					dense_rank() over (partition by employee_id order by count(*) desc)as rnk
					from (select 
		employee_id,
			salary_month,
	sum(new_grp) over (partition by employee_id order by salary_month)as grp  from
			(select 
		employee_id,
			salary_month,
case when login_date=lag(salary) over (partition by employee_id order by salary_month )+1
	then 0 else 1 end as new_grp from employee_salary)t)
		group by employee_id, grp)
		where rnk=1
		order by  employee_id, min(salary_month);
		
select employee_id,
		streak_start,
		streak_end,
		salary_increse,
				streak as streak_months
 from(select 
		employee_id,
			grp,
			count(*) as streak,  
			dense_rank() over (partition by employee_id order by count(*))as rnk,
			min(salary_month)as streak_start,
			max(salary_month) as streak_end,  
			max(salary_month)-min(salary_month) as salary_increse
			from(select 
		employee_id,
			salary_month,
	sum(new_grp) over (partition by employee_id order by salary_month)as grp
		from (select 
		employee_id,
			salary_month,
	salary,
case when salary> lag(salary) over (partition by employee_id order by salary_month)
		then 0 else 1 end as new_grp from employee_salary)t)u group by employee_id, grp
		having streak_months >=3)v
		where rnk=1, 
		order by employee_id, streak_start;


select 
		employee_id,
			streak as streak_months,
			streak_start,
				streak_end,
				salary_increse
				from
				(select 
		employee_id,
			grp,
				count(*) as streak, 
				min(salary_month)as streak_start,
					max(salary_month)as streak_end,
					max(salary)-min(salary) as salary_increase
			dense_rank() over (partition by employee_id order by count(*))as rnk
			(select 
	employee_id,
			salary_month,
	new_grp,
		sum(new_grp) over (partition by employee_id order by salary_month)as grp
		from (select 
		employee_id,
			salary_month,
case when salary>lag(salary) over (partition by employee_id order by salary_month)+1 
	then 0 else 1 as new_grp from employee_salary)t)u 
	group by employee_id, grp)v
	where rnk=1
	order by employee_id, streak_start;

select 
	employee_id,
		streak_start,
			streak_end,
				streak as streak_nelgth from(select 
		employee_id,
			badge_number,
			grp, count(*)as streak,
			min(badge_number)as streak_start,
				max(badge_number)as streak_end,
		dense_rank() over (partition by employee_id order by count(*) )as rnk
			from (select 
		employee_id,
			badge_number, new_grp,
	sum(new_grp) over (partition by employee_id order by  bedge _number) as grp from
	(select 
		employee_id,
			badge_number,
case when badge_number=lag(badge_number) over (partition by employee_id order by badge_number)+1 
		then 0 else 1 as new_grp from employee_bedges)t)u 
			group by employee_id, grp)v
			having streak>=3
			order by employee_id, start_streak;


select 
		employee_id,
			streak_start,
				streak_end,
					streak_days from(select 
		employee_id,
			login_date,
				grp,
				count(*)as streak_days,
			min(login_date)as streak_start,
				max(login_date) as streak_end,
		dense_rank() over (partition by employee_id order by count(*) )as rnk from
				(select 
	employee_id,
		login_date,
			new_grp,
	sum(new_grp) over (partition by employee_id order by login_date)as grp from
			(select 
	employee_id,
		login_date,
case when login_date=lag( login_date) over (partition by employee_id order by login_date)+1	
			then 0 else 1 end as new_grp 
			(select distinct employee_id,
			login_date
			from employee_logins)s)t 
			group by employee_id, grp
			having count(*) >=3)U)
			v
			where rnk=1
			order by employee_id, streak_start;
	
 														
select 
		employee_id,
			streak_start,
				streak_end,
					streak_days from(select 
		employee_id,
			login_date,
				grp,
			min(login_date)as streak_start,
				max(login_date)as streak_end,
				count(*)as streak_days,
				dense_rank() over (partition by employee_id order by grp desc)as rnk
				from(select 
		employee_id,
			login_date,
				new_grp,
			sum(new_grp) over (partition by employee_id order by login_date)as grp
				from (select 
	employee_id,
			login_date,
	case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1 
			then 0 else 1 end as new_grp from  employee_logins) t)u
			group by employee_id, grp)v
			order by employee_id, streak_days
			where rnk<=2;

select 
		employee_id,
			start_date,
				end_date,
					streak_days from (select 
	employee_id,
		login_date,
			grp,
			count(*)as streak_days,
		min(login_date)as start_date,
				max(login_date)as end_date,
	dense_rank() over (partition by employee_id order by count(*) desc)as rnk
				
		(select 
	employee_id,
		login_date,
			new_grp,
	sum(new_grp) over (partition by employee_id order by login_date)as grp
		from (select 
		employee_id,
			login_date,
case when login_date=lag(login_date) over (partition by employee_id order by login_date)+<=2 
	then 0 else 1 end as new_grp from employee_logins)t)u
		group by employee_id, grp
	having count(*) >=3)v
	order by employee_id, streak_start;


select 
		employee_id,
			sequence_start,
				sequence_end,
			sequence_length 
			from(select 
	employee_id,
		login_id,
			grp,
			count(*)as sequence_lenghth,
				min(login_id)as sequence_start,
			max(login_id)as sequence_end,
			dense_rank() over (partition by employee_id order by count(*) desc)as rnk
			from (select 
	employee_id,
		login_id,
			new_grp,
	sum(new_grp) over (partition by employee_id order by login_id)as grp
		from (select 
		employee_id,
			login_id,		
	case when login_id=lag(login_id) over (partition by employee_id order by login_id)+1 
		then 0 else 1 end as new_grp from employee_logins)t)u
			group by employee_id, 	grp
			having count(*) >=2)
			where rnk<=2
			order by employee_id,sequence_length;
	
select * from (select 
	employee_id,
		streak_start,
			streak_end,
				streak_days,
					previous_streak_end,
					streak_start-previous_streak_end as gap_days,
			dense_rank() over (partition by employee_id order by streak_start-previous_streak_end desc )as rnk
			from 
				(select 
		employee_id,
			streak_days,
				streak_start,
					streak_end,
				lag(streak_end) over (partition by employee_id order by login_date )as previous_streak_end
				from (select 
	employee_id,
		login_date,
		grp,
		count(*)as streak_days, 
		min(login_date)as streak_start,
		max(login_date)as streak_end
		from (select 
		employee_id,
			login_date,
				new_grp,
	sum(new_grp) over (partition by employee_id order by login_date)as grp
	from(select 
	employee_id,
			login_date,
	case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1 
			then  0 else 1 end as new_grp from employee_logins)t)u
			group by employee_id, grp)v)w)x 
			where rnk=1
			order by employee_id, gap_days;
			

select 
		user_id,
			event_time,
				grp 
			count(*)as event_count,
				min(event_time)as session_start,
				max(event_time)as session_end,
				(select 
	user_id,
		event_time,
			new_grp,
	sum(new_grp) over (partition by user_id order by event_time)as grp
	from (select 
		user_id,
			event_time,
case when event_time-lag(event_time) over (partition by user_id order by event_time) < interval '30minutes'
	then 0 else 1 end as new_grp from user_events)t)u
	group by user_id, grp
	order by user_id, grp;

select 
	employee_id,
		streak_start,
			streak_end,
				streak_days,
				rnk from(select 
		employee_id,
			login_date,
				regular_type,
				grp,
				count(*)as streak_days,
					min(login_date)as streak_start,
						max(login_date) as streak_end,
		dense_rank () over (partition by employee_id order by count(*) desc)as rnk
							from (select 
		employee_id,
			login_date,
				regular_type,
				new_grp, 
			sum(new_grp) over (partition by employee_id order by login_date)as grp
			from(select 
		employee_id,
			login_date,	
			regular_type,
case when regular_type=lag(login_type) over (partition by employee_id order by login_date)+'Regular' 
	then 0 else 1 end as new_grp from employee_logins)t)u 
	group by employee_id, grp
	having count(*)>=2) v 
	where rnk=1
	order by employee_id, streak_days;
	
			
select 
	employee_id,
		login_type,
			streak_start,
				streak_end,
					streak_days from(select 
		employee_id,
			login_date,
			login_type,
				grp,
			count(*)as streak_days,
		min(login_date)as streak_start,
			max(login_date)as streak_end, (select 
		employee_id,
			login_date,
			login_type,
			new_grp,
	sum(new_grp) over (partition by employee_id order by login_date)as grp
	from(select 
		employee_id,
			login_date,
				login_type,
case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1 
	and
case when login_type=lag(login_type) over (partition by employee_id order by login_date)='regular' 
			then 0 else 1 end as new_grp from employee_logins)t)u
			group by employee_id,grp)v
			order by employee_id,
			streak_start;

select 
	employee_id,
		streak_start,
			streak_end,
			streak_start-previous_streak_end as inactive_days,
				streak_days 
				from(select 
		employee_id,
			grp,
			streak_days,
			streak_end,
			streak_start
			lag(streak_end) over (partition by employee_id order by streak_start)as previous_streak_end
			from(select 
		employee_id,
			login_date,
				grp,
			count(*)as streak_days,
	min(login_date)as streak_start,
		max(login_date)as streak_end
		from(select 
	employee_id,
		login_date,
			new_grp,
		sum(new_grp) over (partition by employee_id order by login_date)as grp
		from (select 
		employee_id,
			login_date,

case when login_date=lag(login_date) over (partition by employee_id order by login_date)+1 
	then 0 else 1 end as new_grp from employee_logins)t)u 
	group by employee_id, grp)v)w;

select 
	employee_id,
	login_type,
		streak_start,
		streak_end,
			streak_days 
			from(select 
		employee_id,
				login_type,
				grp,
	count(*)as streak_days,
	min(login_date)as streak_start,
		max(login_date)as streak_end 
		from (select 
		employee_id,
			login_date,
				login_type,
				new_grp,
	sum(new_grp) over (partition by employee_id order by login_date)as grp
	from (select 
		employee_id,
			login_date,
				login_type,
	case when
		lag(login_date) over (partition by employee_id order by login_date) is not null 
		and  
		login_date=lag(login_date) over (partition by employee_id order by login_date)+1 
	and
	login_type=lag(login_type) over (partition by employee_id order by login_date)='Regular' 
	 then  0 else 1 end as new_grp from employee_logins)t)u
	 group by employee_id, grp)v
	 order by employee_id, streak_start;
 
select 
	employee_id,
		login_type,
			streak_stat,
				streak_end,
			streak_days 
			from (select 
	employee_id,	
		login_type,
			grp,
		count(*)as streak_days,
		min(login_date)as streak_start,
			max(login_date)as streak_end,
			dense_rank () over (partition by employee_id order by count(*) desc )as rnk
			from (select 
		employee_id,
			login_date,
			login_type,
			new_grp,
		sum(new_grp) over (partition by employee_id order by login_date)as grp
		from (select 
		employee_id,
			login_date,
				login_type,
	case when lag(login_date) over (partition by employee_id order by login_date) is not null 
			and 
	login_date=lag(login_date) over (partition by employee_id order by login_date)+1 then
			and
		login_type=lag(login_type) over (partition by employee_id order by login_date) 
				then 0 else 1 end as new_grp from employee_logins)t)u
				group by employee_id, grp)v
				where rnk=1
				order  by employee_id,streak_days;

select 
	employee_id,
		streak_start,
			streak_end,
				streak_days,
			starting_salary,
		end_salary,
		(select 
	employee_id,
		grp,
		count(*)as streak_months,
		min(salary_month)as streak_start,
		max(salary_month)as streak_end,
		min(salary)as starting_salary,
		max(salary)as end_salary,
			streak_end-streak_start as total_increse
			from
			(select 
	employee_id,
		salary_month,
		salary,
			new_grp,
		sum(new_grp) over (partition by employee_id order by salary_date)as grp
		from (select 
		employee_id,
			salary_month,
				salary,
	case when salary>lag(salary) over (partition by employee_id order by salary_month)+1 
		then 0 else 1 end as new_grp from employee_salary)t)u
		group by employee_id, grp)v
		order by employee_id, streak_days;

select 
	employee_id,
		streak_months,
			streak_start,
		streak_end,
	starting_salary,
end_salary,
	end_salary - start_salary as total_increase 
	from (select 
	employee_id,
		grp,
		count(*)as streak_months,
	min(salary_month)as streak_start,
	 max(salary_month)as streak_end,
	 	min(salary)as starting_salary.
		 	max(salary)as end_salary, (select 
	employee_id,
		salary_month,
			salary,
				new_grp,
			sum(new_grp) over (partition by employee_id order by salary_month)as grp
			from (select 
		employee_id,
			salary_month,
				salary,
	case when lag(salary) over (partition by employee_id order by login_date) is not null
	 and 
	 salary_month=lag(salary_month) over (partition by employee_id order by salary_month)
	 + interval '1 month'
				 and
		salary>lag(salary) over (partition by employee_id order by salary) 
		 then 0 else 1 end as new_grp from employee_salary)t)u
		 group by employee_id, grp)v
		 order by employee_id, streak_months;


















































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































