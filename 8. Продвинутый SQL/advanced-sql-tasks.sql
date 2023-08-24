---
SELECT count(title)
FROM stackoverflow.posts
where score > 300
or favorites_count >= 100
---
select round(avg(qop)) from
(
    select count(id) as qop
from stackoverflow.posts
where post_type_id = 1
group by cast(date_trunc('day', creation_date) as date)
having cast(date_trunc('day', creation_date) as date) between '1-11-2008' AND '18-11-2008') as t1
---
select count(distinct u.id)
from stackoverflow.badges as b
inner join stackoverflow.users as u ON u.id = b.user_id
where u.creation_date::date = b.creation_date::date
---
select count(distinct p.id)
from stackoverflow.posts as p
join stackoverflow.users as u on p.user_id = u.id
join stackoverflow.votes as v on p.id = v.post_id
where u.display_name = 'Joel Coehoorn'
and v.id is not null
---
select *, row_number() over (order by id desc) as rank
from stackoverflow.vote_types
order by id
---
select v.user_id, count(v.id) as cnt
from stackoverflow.votes as v
join stackoverflow.vote_types as vt on v.vote_type_id = vt.id
where vt.name = 'Close'
group by v.user_id
order by cnt desc limit 10
---
select u.id, count(b.id) as cnt, DENSE_RANK() over (order by count(b.id) desc)
from stackoverflow.users as u
join stackoverflow.badges as b on u.id = b.user_id
where b.creation_date::date between '15-11-2008' and '15-12-2008'
group by u.id
order by cnt desc, u.id limit 10
---
with t as 
(select title, user_id, score, avg(score) over (partition by user_id) as avge
from stackoverflow.posts
where title is not null
and score <> 0)
select title, user_id, score, round(avge)
from t
---
with t1 as 
(select p.title, count(b.id) as cnt
from stackoverflow.posts as p
join stackoverflow.users as u on p.user_id = u.id
join stackoverflow.badges as b on b.user_id = u.id
where p.title is not null
group by p.title
having count(b.id) > 1000)
select title
from t1
---
select id, views,
case
    when views >= 350 then 1
    when views < 100 then 3
    when views < 350 then 2
end
from stackoverflow.users
where location like '%United States%'
and views <> 0
---

with t1 as (
select id,
case
    when views >= 350 then 1
    when views < 100 then 3
    when views < 350 then 2
end as qq,
views
from stackoverflow.users
where location like '%United States%'
and views <> 0
),

t2 as (select id, qq, views, max(views) over (partition by qq) 
from t1
order by views desc, id)
select id, qq, views from t2
where views = max
---
with t1 as(
select  EXTRACT(day FROM CAST(creation_date AS timestamp)) as days, count(id) as cnt
from stackoverflow.users
where cast(date_trunc('day', creation_date) as date) between '2008-11-01' and '2008-11-30'
group by EXTRACT(day FROM CAST(creation_date AS timestamp))
)
select *, sum(cnt) over (order by days)
from t1
---
with t1 as (
select u.id, p.creation_date, row_number() over (partition by p.user_id order by p.creation_date) as first_post, u.creation_date as rega
from stackoverflow.posts as p
join stackoverflow.users as u on p.user_id = u.id
--where p.title is not null
)
select id, creation_date - rega
from t1
where first_post = 1 
---
select cast(date_trunc('month', creation_date) as date), sum(views_count) as summa
from stackoverflow.posts
group by cast(date_trunc('month', creation_date) as date)
order by summa desc
---
select u.display_name, count(distinct u.id)
from stackoverflow.posts as p
join stackoverflow.users as u on u.id = p.user_id
join stackoverflow.post_types as pt on p.post_type_id = pt.id
where p.creation_date::date between u.creation_date::date and (u.creation_date::date + INTERVAL '1 month')
and pt.type = 'Answer'
group by u.display_name
having count(p.id) > 100
order by u.display_name
---
with t1 as (
    select u.id
from stackoverflow.posts as p
join stackoverflow.users as u on p.user_id = u.id
where cast(date_trunc('month', u.creation_date) as date) = '2008-09-01'
and cast(date_trunc('month', p.creation_date) as date) = '2008-12-01'
group by u.id
having count(p.id) > 0
)
select count(p.id), 
cast(date_trunc('month', p.creation_date) as date)
from stackoverflow.posts as p
where p.user_id IN (select * from t1)
AND DATE_TRUNC('year', p.creation_date)::date = '2008-01-01'
group by cast(date_trunc('month', p.creation_date) as date)
order by cast(date_trunc('month', p.creation_date) as date)  desc
---
select user_id, creation_date, views_count,
sum(views_count) over (partition by user_id order by creation_date)
from stackoverflow.posts
---
with t1 as (
    select user_id, count(distinct creation_date::date) as cnt
from stackoverflow.posts
where creation_date::date between '2008-12-01' and '2008-12-07'
group by user_id
)
select round(avg(cnt)) 
from t1
---
with t1 as (
    select EXTRACT(MONTH FROM CAST(creation_date AS date)) as month, count(distinct id) as cnt
from stackoverflow.posts
where creation_date::date between '2008-09-01' and '2008-12-31'
group by month
    )
    select *, round(((cnt::numeric / LAG(cnt) over (order by month)) - 1) * 100, 2)
    from t1
---
with t1 as (
    select user_id, count(distinct id) as cnt
from stackoverflow.posts 
group by user_id
order by cnt desc
limit 1
    ),

t2 as (
select p.user_id, p.creation_date,
EXTRACT('WEEK' FROM CAST(p.creation_date AS timestamp)) as week_number
from from stackoverflow.posts as p
join t1 on t1.user_id = p.user_id
where cast(DATE_TRUNC('month', p.creation_date)as date) = '2008-10-01'
    )
    select distinct week_number::numeric, max(creation_date) over (partition by week_number)
    from t2
    order by week_number