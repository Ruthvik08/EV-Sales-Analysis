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
(select maker,sum(ev_sold) from c1
group by maker
order by sum(ev_sold) desc
limit 3)
union
(select maker,sum(ev_sold) from c1
group by maker
order by sum(ev_sold) group by state

limit 3);

-- 2. Identify the top 5 states with the highest penetration rate in 2-wheeler
-- and 4-wheeler EV sales in FY 2024.
(select state,((sum(evcate)/sum(totat_sales))*100) as pent from state 
where date like '2024%' and cate='2-Wheelers'
group by state
order by ((sum(evcate)/sum(totat_sales))*100) desc
limit 5)
union 
(select state,((sum(evcate)/sum(totat_sales))*100) as pent from state 
where date like '2024%' and cate='4-Wheelers'
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
group by maker.maker,date.year1,date.quater;



