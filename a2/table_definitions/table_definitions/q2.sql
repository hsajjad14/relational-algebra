-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.


-- the answer to the query
-- old answer
-- insert into q2 select c.name as countryName,
-- date_part('year', e.e_date) as year, -- selection year
-- round(avg(cast(e.votes_cast as decimal) / cast(e.electorate as decimal)),6) as participationRatio --selecting ratio
-- from election e join country c on e.country_id = c.id
-- where date_part('year', e.e_date) >= 2001 and date_part('year', e.e_date) <= 2016
-- group by c.name, year;


-- changed q2
create view almostComplete as
select c.name as countryName,
date_part('year', e.e_date) as year, -- selection year
round(avg(cast(e.votes_cast as decimal) / cast(e.electorate as decimal)),6) as participationRatio --selecting ratio
from election e join country c on e.country_id = c.id
where date_part('year', e.e_date) >= 2001 and date_part('year', e.e_date) <= 2016
group by c.name, year;


create view notNonDecreasing as
select distinct q21.countryName
from almostComplete q21 join almostComplete q22 on q21.countryName = q22.countryName
where q21.year < q22.year and q21.participationRatio > q22.participationRatio;


insert into q2 select * from almostComplete
  where countryName not in (
    select distinct q21.countryName
    from almostComplete q21 join almostComplete q22 on q21.countryName = q22.countryName
    where q21.year < q22.year and q21.participationRatio > q22.participationRatio
  );
