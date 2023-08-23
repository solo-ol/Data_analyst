---
select count(*)
from company
where status = 'closed'
---
select funding_total
from company
where country_code = 'USA'
AND category_code = 'news'
order by funding_total desc
---
select sum(price_amount)
from acquisition
where extract(year from cast(acquired_at as date)) between 2011 and 2013
AND term_code = 'cash'
---
select first_name, last_name, twitter_username from people
where twitter_username LIKE 'Silver%'
---
select * from people
where twitter_username LIKE '%money%'
AND last_name LIKE 'K%'
---
select country_code, sum(funding_total) as total_sum from company
group by country_code
order by total_sum desc
---
select funded_at, min(raised_amount), max(raised_amount) from funding_round
group by funded_at
having min(raised_amount) != 0
AND min(raised_amount) != max(raised_amount)
---
select *, 
case 
    when invested_companies >= 100 then 'high_activity'
    when invested_companies between 20 and 100 then 'middle_activity'
    when invested_companies < 20 then 'low_activity'
end as category
from fund 
---
SELECT 
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity,  round(avg(investment_rounds)) as average
FROM fund
group by activity
order by average
---
select country_code, min(invested_companies), max(invested_companies), avg(invested_companies) as average
from fund
where (EXTRACT(year from cast(founded_at as timestamp)) between 2010 and 2012)
group by country_code
having min(invested_companies) > 0
order by average desc, country_code
limit 10
---
select first_name, last_name, instituition
from people as p
left join education as ed ON p.id = ed.person_id
---
select c.name, count(distinct(ed.instituition)) as uni_count
from company as c
left join people as p ON c.id = p.company_id
left join education as ed ON p.id = ed.person_id
group by c.id
order by uni_count desc
limit 5
---
select distinct(c.name)
from company as c
left join funding_round as fr ON c.id = fr.company_id
where status = 'closed'
and is_first_round = 1
AND is_last_round = 1
---
with 
t as (select distinct(c.name), c.id as uniq
from company as c
left join funding_round as fr ON c.id = fr.company_id
where status = 'closed'
and is_first_round = 1
AND is_last_round = 1)

select distinct(p.id)
from people as p
join t on p.company_id = t.uniq
---
with 
t as (select distinct(c.name), c.id as uniq
from company as c
left join funding_round as fr ON c.id = fr.company_id
where status = 'closed'
and is_first_round = 1
AND is_last_round = 1)

select distinct(p.id)
from people as p
join t on p.company_id = t.uniq

---
with
t2 as (
with 
t as (select distinct(c.name), c.id as uniq
from company as c
left join funding_round as fr ON c.id = fr.company_id
where status = 'closed'
and is_first_round = 1
AND is_last_round = 1)

select distinct(p.id)
from people as p
join t on p.company_id = t.uniq)

select distinct(t2.id) as qq, count(ed.instituition) from t2
join education as ed ON t2.id = ed.person_id
group by qq
---
with
t3 as (
with
t2 as (
with 
t as (select distinct(c.name), c.id as uniq
from company as c
left join funding_round as fr ON c.id = fr.company_id
where status = 'closed'
and is_first_round = 1
AND is_last_round = 1)

select distinct(p.id)
from people as p
join t on p.company_id = t.uniq)

select distinct(t2.id) as qq, count(ed.instituition) as ww from t2
join education as ed ON t2.id = ed.person_id
group by qq)
select avg(ww)
from t3
---
with
t as (select distinct ed.person_id, count(instituition) as count_uniq
from people as p
join company as c on c.id = p.company_id
join education as ed on ed.person_id = p.id
where name = 'Facebook'
group by ed.person_id)

select avg(t.count_uniq) from t
---
SELECT f.name AS name_of_fund, 
       C.name AS name_of_company, 
       fr.raised_amount AS amount
FROM investment AS i
JOIN company AS c ON i.company_id=c.id
JOIN fund AS f ON i.fund_id=f.id
JOIN funding_round AS fr ON i.funding_round_id = fr.id
WHERE EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2012 AND 2013
   AND c.milestones > 6;

---
select c1.name as pokupka, ac.price_amount, c2.name as kupili, c2.funding_total, round(sum(ac.price_amount / c2.funding_total))
from acquisition as ac
left join company as c1 on c1.id = ac.acquiring_company_id
left join company as c2 on c2.id = ac.acquired_company_id
where c2.funding_total > 0
group by c1.name, ac.price_amount, c2.name, c2.funding_total
order by ac.price_amount desc, c2.name
limit 10
---
select c.name, EXTRACT(month FROM CAST(fr.funded_at AS date)) as month
from company as c
join funding_round as fr ON c.id = fr.company_id
where c.category_code = 'social'
and fr.raised_amount != 0
and EXTRACT(year FROM CAST(fr.funded_at AS date)) between 2010 and 2013
---
with 
t1 as (select extract(month from cast(funded_at as date)) as fr_month, count(distinct(f.name)) as uniq
from funding_round as fr
left join investment as i ON fr.id = i.funding_round_id
left join fund as f ON i.fund_id = f.id
      where extract(year from cast(fr.funded_at as date)) between 2010 and 2013
      and f.country_code = 'USA'
      group by extract(month from cast(funded_at as date))),
    
t2 as (select extract(month from cast(a.acquired_at as date)) as ac_month, count(a.acquired_company_id) as comp, sum(a.price_amount) as total 
from acquisition as a
where extract(year from cast(a.acquired_at as date)) between 2010 and 2013
group by extract(month from cast(a.acquired_at as date)))

select t2.ac_month, t1.uniq, t2.comp, t2.total
from t2 join t1 on t2.ac_month = t1.fr_month
---
with 
t1 as (select country_code, avg(funding_total) as year2011
from company as c
where extract(year from cast(founded_at as date)) = 2011
group by country_code, extract(year from cast(founded_at as date))), 

t2 as (select country_code, avg(funding_total) as year2012
from company as c
where extract(year from cast(founded_at as date)) = 2012
group by country_code, extract(year from cast(founded_at as date))),

t3 as (select country_code, avg(funding_total) as year2013
from company as c
where extract(year from cast(founded_at as date)) = 2013
group by country_code, extract(year from cast(founded_at as date)))

select t1.country_code, t1.year2011, t2.year2012, t3.year2013
from t1
inner join t2 ON t1.country_code = t2.country_code
inner join t3 on t1.country_code = t3.country_code
order by t1.year2011 desc