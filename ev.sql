create database if not exists evcars;
use evcars;
SET SQL_SAFE_UPDATES = 0;
create table date (date1 varchar(100),
					year1 int(100),
                    quater varchar(100));
UPDATE date 
SET date1 = STR_TO_DATE(date1, '%d-%b-%y');
alter table date modify year1 year;
ALTER TABLE date MODIFY quater ENUM('Q1', 'Q2', 'Q3', 'Q4');
select * from date;
describe date;

create table maker (date varchar(10),
					cate varchar(10),
                    maker varchar(100),
                    ev_sold int); 
select * from maker;
describe maker;
update maker set date=str_to_date(date,'%d-%b-%y');

create table state(date varchar(10),
			 state varchar(50),
             cate varchar(50),
             evcate int,
             totat_sales int);
update state
set date =str_to_date(date,'%d-%b-%y');
UPDATE state
SET state = REPLACE(state, 'Andaman & Nicobar Island', 'Andaman & Nicobar')
WHERE state LIKE '%Andaman & Nicobar Island%';

select * from state;

-- 1. List the top 3 and bottom 3 makers for the fiscal years 2023 and 2024 in
-- terms of the number of 2-wheelers sold.
with c1 as (select * from maker where cate='2-Wheelers' and (date like '2023%' or date like '2024%'))
(select maker,sum(ev_sold) as total_ev_sold from c1
group by maker
order by sum(ev_sold) desc
limit 3)
union all
select 'bottom 3' as maker,'' total_ev_sold
union all
(select maker,sum(ev_sold) as total_ev_sold from c1
group by maker
order by sum(ev_sold)
limit 3);

-- 2. Identify the top 5 states with the highest penetration rate in 2-wheeler
-- and 4-wheeler EV sales in FY 2024.
(select state,((sum(evcate)/sum(totat_sales))*100) as penetration from state 
where date like '2024%' and cate='2-Wheelers'
group by state
order by ((sum(evcate)/sum(totat_sales))*100) desc
limit 5)
union 
select '4 wheeler' as state , '-------------------' as penetration
union
(select state,((sum(evcate)/sum(totat_sales))*100) as penetration from state 
where date like '2024%' and cate='4-Wheelers'
group by state
order by ((sum(evcate)/sum(totat_sales))*100) desc
limit 5);

-- 3. List the states with negative penetration (decline) in EV sales from 2022
-- to 2024?
with c3 as (select date_format(date,'%y') as year ,state,((sum(evcate)/sum(totat_sales))*100) as pent from state group by date_format(date,'%y'),state 
having (year in ('22','24'))) ,
c30 as (select state,pent - lag(pent) over (partition by state order by state,year) as pent1 from c3)
select * from c30 where pent1 is not null order by pent1;

-- 4. What are the quarterly trends based on sales volume for the top 5 EV
-- makers (4-wheelers) from 2022 to 2024?
with c4count as (select maker,sum(ev_sold) as sev from maker
				where cate='4-Wheelers' and (date like '2022%' or date like '2023%' or date like '2024%')
				group by maker 
				order by sum(ev_sold) desc limit 5)
select maker.maker,date.year1,date.quater,sum(maker.ev_sold) from maker
right join c4count on maker.maker=c4count.maker
right join date on date.date1=maker.date
where maker.maker is not null
group by maker.maker,date.year1,date.quater
order by maker.maker desc;

-- 5 How do the EV sales and penetration rates in Delhi compare to
-- Karnataka for 2024?

select state ,sum(evcate) as total_evsales,((sum(evcate)/sum(totat_sales))*100) as  penetration from state
where state in ('Delhi','Karnataka')
group by state;

-- 6 List down the compounded annual growth rate (CAGR) in 4-wheeler
-- units for the top 5 makers from 2022 to 2024.

with c1 as (SELECT maker,SUM(ev_sold) AS total_ev_sold,
RANK() OVER (ORDER BY SUM(ev_sold) DESC) AS sales_rank FROM maker where cate='4-Wheelers' GROUP BY maker  limit 5),
c2 as (select maker.maker,year(maker.date) as year,sum(maker.ev_sold) as sum_ev from c1
inner join maker on c1.maker=maker.maker
where maker.date in (2022,2024)
group by maker.maker,year(maker.date)
order by maker.maker,year(maker.date) desc)
select maker , power(sum_ev/(lead(sum_ev) over (partition by maker order by maker,year desc)),1/2)-1 as cagr,sum_ev,year from c2 ;

-- 7 List down the top 10 states that had the highest compounded annual
-- growth rate (CAGR) from 2022 to 2024 in total vehicles sold.

with c1 as (select distinct year(date) as year,state,sum(totat_sales) over (partition by year(date),state order by state,year(date) desc  ) as sales1 from state
where year(date) in (2022,2024) )
select c1.state,power((c2.sales2024/c1.sales1),1/3)-1 as cagr from c1
inner join (select sales1 as sales2024,state from c1 where year=2024) c2 on c1.state=c2.state
where c1.year=2022
order by power((c2.sales2024/c1.sales1),1/2)-1 desc
limit 10;

-- 8 What are the peak and low season months for EV sales based on the data from 2022 to 2024?

select month(date) as month, monthname(date) as month ,sum(evcate) as ev_sales from state
where  year(date) between 2022 and 2024 
group by month(date), monthname(date)
order by sum(evcate);



