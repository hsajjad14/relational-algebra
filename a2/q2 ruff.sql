
# country, election id, date electorate (num ppl), and num ppl voted, and ratio of every election

select e.id, c.name, e.e_date, e.electorate, date_part('year', e.e_date) as year,
e.votes_valid, round(cast(e.votes_valid as decimal) / cast(e.electorate as decimal), 2) as ratio
from election e join country c on e.country_id = c.id join
election e2 on e2.country_id = c.id where e2.id <> e.id and date_part('year', e2.e_date) = date_part('year', e.e_date)
order by year;


#countries with more than 1 election in a year

select e.id, c.name, e.e_date, e.electorate, date_part('year', e.e_date) as year,
e.votes_valid, round(cast(e.votes_valid as decimal) / cast(e.electorate as decimal), 2) as ratio
from election e join country c on e.country_id = c.id join
election e2 on e2.country_id = c.id where e2.id <> e.id and date_part('year', e2.e_date) = date_part('year', e.e_date)
order by year;

# avg election ratio for every year in france

select c.name, date_part('year', e.e_date) as year,
avg(round(cast(e.votes_valid as decimal) / cast(e.electorate as decimal), 2)) as ratio
from election e join country c on e.country_id = c.id where c.name = 'France'
group by c.name, year
order by year;

# same but for every country
# year is between 2001 and 2016

create view almostCompleted as
select c.name as countryName, date_part('year', e.e_date) as year,
round(avg(cast(e.votes_cast as decimal) / cast(e.electorate as decimal)), 6) as participationRatio
from election e join country c on e.country_id = c.id
where date_part('year', e.e_date) >= 2001 and date_part('year', e.e_date) <= 2016
group by c.name, year
having avg(cast(e.votes_cast as decimal) / cast(e.electorate as decimal)) is not null
order by c.name desc, year desc;

select *
from almostCompleted
where name = 'Germany';

select c.name as countryName, date_part('year', e.e_date) as year,
round(avg(cast(e.votes_cast as decimal) / cast(e.electorate as decimal)), 3) as participationRatio
from election e join country c on e.country_id = c.id
where date_part('year', e.e_date) >= 2001 and date_part('year', e.e_date) <= 2016 and c.name = 'Germany'
group by c.name, year
order by c.name desc, year desc;


create view notNonDecreasing as
select a1.name
from almostComplete a1 join almostComplete a2 on a1.name = a2.name
where a1.year < a2.year and a1.ratio < a2.ratio;



------------------------------------------------------
redoing
=======================================================

select e.id, e.votes_cast, e.electorate,  c.name,
round(cast(e.votes_cast as decimal) / cast(e.electorate as decimal), 6) as ratio, --selecting ratio
date_part('year', e.e_date) as year -- selection
from election e join country c on e.country_id = c.id
where c.name = 'Germany' and date_part('year', e.e_date) >= 2001 and date_part('year', e.e_date) <= 2016
order by year desc;

-- finding ave for every 2001- 2016 specific country
select c.name,
date_part('year', e.e_date) as year, -- selection year
round(avg(cast(e.votes_cast as decimal) / cast(e.electorate as decimal)),6) as ratio --selecting ratio
from election e join country c on e.country_id = c.id
where c.name = 'United Kingdom' and date_part('year', e.e_date) >= 2001 and date_part('year', e.e_date) <= 2016
group by c.name, year
order by year desc;

-- finding ave from 2001- 2016 every country
select c.name,
date_part('year', e.e_date) as year, -- selection year
round(avg(cast(e.votes_cast as decimal) / cast(e.electorate as decimal)),6) as ratio --selecting ratio
from election e join country c on e.country_id = c.id
where date_part('year', e.e_date) >= 2001 and date_part('year', e.e_date) <= 2016
group by c.name, year
order by c.name desc, year desc;

-- final answer ?
create view final as
select c.name as countryName,
date_part('year', e.e_date) as year, -- selection year
round(avg(cast(e.votes_cast as decimal) / cast(e.electorate as decimal)),6) as participationRatio --selecting ratio
from election e join country c on e.country_id = c.id
where date_part('year', e.e_date) >= 2001 and date_part('year', e.e_date) <= 2016
group by c.name, year;

create view q2 as
select c.name as countryName,
date_part('year', e.e_date) as year, -- selection year
round(avg(cast(e.votes_cast as decimal) / cast(e.electorate as decimal)),6) as participationRatio --selecting ratio
from election e join country c on e.country_id = c.id
where date_part('year', e.e_date) >= 2001 and date_part('year', e.e_date) <= 2016
group by c.name, year;


create view notNonDecreasing as
select distinct q21.countryName
from q2 q21 join q2 q22 on q21.countryName = q22.countryName
where q21.year < q22.year and q21.participationRatio > q22.participationRatio;
