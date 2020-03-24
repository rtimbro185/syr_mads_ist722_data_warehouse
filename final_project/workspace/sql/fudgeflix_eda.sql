select * from ff_plans where plan_current = 1
order by plan_price asc
;



select count(*) from ff_accounts
group by account_plan_id
;

select * from ff_accounts
;

select * from ff_account_billing
;

select * from ff_account_titles
where at_shipped_date is null
;

Select t.title_name, t.title_bluray_available, t.title_dvd_available, t.title_instant_available
From ff_account_titles act
inner join ff_titles t on act.at_title_id = t.title_id
Where act.at_shipped_date is null
;


select count(*) from ff_accounts
group by account_zipcode
;


select plan_id as Current_PlanId
from ff_plans
where plan_current = 1;


select ab.ab_plan_id, p.plan_current as IsCurrentPlan, p.plan_name as Plan_Type, p.plan_price as Plan_Price,sum(ab.ab_billed_amount) as Total_Plan_Billed_Amount
from ff_account_billing ab
join ff_plans p on ab.ab_plan_id = p.plan_id
group by ab.ab_plan_id, p.plan_name, p.plan_current, p.plan_price
order by Total_Plan_Billed_Amount
;

select a.account_plan_id, p.plan_name as Plan_Type, p.plan_price as Plan_Price,count(a.account_plan_id) as Total_Plan_Count
from ff_accounts a
join ff_plans p on a.account_plan_id = p.plan_id
group by a.account_plan_id, p.plan_name, p.plan_price
order by Total_Plan_Count desc
;


select act.at_title_id as Title_ID, t.title_name as Title_Name, count(act.at_title_id) as Total_Title_Purchased_Count, 
	avg(act.at_rating) as Average_Title_Rating
from ff_account_titles act
join ff_titles t on act.at_title_id = t.title_id
group by act.at_title_id, t.title_name
order by Total_Title_Purchased_Count desc
;

select t.title_type, count(t.title_id) as Total_Titles
from ff_titles t
group by t.title_type
;

select g.tg_genre_name as Genera, t.title_name as Title
from ff_title_genres g
join ff_titles t on g.tg_title_id = t.title_id
;

select g.tg_genre_name as Genra, count(g.tg_title_id) as Total_Titles
from ff_title_genres g
group by g.tg_genre_name
order by Total_Titles desc
;