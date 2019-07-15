
--electionSequence
--ElectionCabinetResult

--: A method that, given a country, returns the list of elections in that country, in descending
--order of years, and the cabinets that have formed after that election and before the next election of the same
--type.

--find query
select elecid, cabid, elecdate from temp
where name = 'Japan'
order by elecdate desc;

create view temp as
(select elecid, cabid, name, elecdate
  from almostparlel)
Union
(select elecid, cabid, name, elecdate
  from almostEPel);

--final query? no
select e.id, cab.id
from country c join election e on e.country_id = c.id
join cabinet cab on cab.country_id = c.id and cab.start_date >= e.e_date
join nextparlelection npe on e.id = npe.id and cab.start_date <= npe.enddate
where c.name = 'Canada';

create view almostparlel as
select c.name, cab.id as cabid, cab.start_date as cabstartdate, e.e_date as elecdate, e.id as elecid,
npe.enddate as nextelectiondate
from parlgov.country c join parlgov.election e on e.country_id = c.id
left join parlgov.cabinet cab on cab.country_id = c.id and cab.start_date >= e.e_date
join nextparlelection npe on e.id = npe.id and cab.start_date <= npe.enddate;
-- where c.name = 'United Kingdom';

create view almostEPel as
select c.name, cab.id as cabid, cab.start_date as cabstartdate, e.e_date as elecdate, e.id as elecid,
npe.enddate as nextelectiondate
from parlgov.country c join parlgov.election e on e.country_id = c.id
left join parlgov.cabinet cab on cab.country_id = c.id and cab.start_date >= e.e_date
join nextEPelection npe on e.id = npe.id and cab.start_date <= npe.enddate;
-- where c.name = 'United Kingdom';


create view cabenddate as
select c2.id as cabid, c.start_date as enddate
from cabinet c, cabinet c2
where c.previous_cabinet_id = c2.id;

create view nextparlelection as
select e1.id, e2.e_date as enddate
from parlgov.election e1, parlgov.election e2
where e2.previous_parliament_election_id = e1.id;

create view nextEPelection as
  select e1.id, e2.e_date as enddate
  from parlgov.election e1, parlgov.election e2
  where e2.previous_ep_election_id = e1.id;
  -----------------------------------------------------------
  --same as above ^
  --: A method that, given a country, returns the list of elections in that country, in descending
  --order of years, and the cabinets that have formed after that election and before the next election of the same
  --type.
  create view intro as
  select e.e_type as type, c.name, e.id as elecid, cab.id as cabid, e.e_date as elecdate, cab.start_date as cabstartdate
  from parlgov.election e join parlgov.country c on e.country_id = c.id
  join parlgov.cabinet cab on cab.country_id = c.id and cab.start_date > e.e_date;

--temp
  select e.e_type as type, c.name, e.id as elecid, cab.id as cabid, e.e_date as elecdate, cab.start_date as cabstartdate
  from parlgov.election e join parlgov.country c on e.country_id = c.id
  join parlgov.cabinet cab on cab.country_id = c.id and cab.start_date > e.e_date
  where c.name = 'United Kingdom'
  order by cab.start_date desc;
  -- if e_type == European Parliament:
  --   find enddate using  previous_ep_election_id
  -- else:
  --   find enddate using  previous_parliament_election_id

  -- European Parliament
create view ep as
select i.type as type, i.name as name, i.elecid as elecid, i.cabid as cabid,
i.elecdate as elecdate, i.cabstartdate as cabstartdate, e.e_date as nxtelectiondate
from intro i join parlgov.election e on i.elecid = e.previous_ep_election_id
and i.cabstartdate < e.e_date
order by i.cabstartdate desc;

-- Parliamentary election
create view pe as
select i.type as type, i.name as name, i.elecid as elecid, i.cabid as cabid,
i.elecdate as elecdate, i.cabstartdate as cabstartdate, e.e_date as nxtelectiondate
from intro i join parlgov.election e on i.elecid = e.previous_parliament_election_id
and i.cabstartdate < e.e_date
order by i.cabstartdate desc;

create view temp as
  (select type, elecid, cabid,cabstartdate,name
  from ep) Union
  (select type, elecid, cabid,cabstartdate,name
  from pe);

-- check for duplicates
-- select * from (select * from temp
-- order by cabstartdate desc) s1, (select * from temp
-- order by cabstartdate desc) s2
-- where s1.elecid = s2.elecid and s1.cabid = s2.cabid AND
-- s1.cabstartdate <> s2.cabstartdate;

-- final
select * from temp
where name = 'United Kingdom' order by cabstartdate desc





  -----------------------------------------------------------

  --findSimilarPoliticians

  --A method that, given a president, returns other presidents that have similar
--comments and descriptions in the database. See section Similar Politicians below for details.

-- This method identifies similar politicians using the descriptions that are available about them in this parlgov
-- database. In other words, two politicians are potentially similar if the textual information available about them is
-- similar enough.

-- “Jaccard similarity” provides a simple but effective similarity score (between 0 and 1) for two given sets of
-- strings. It is defined as the size of the intersection divided by the size of the union of two sets. For instance, the
-- Jaccard similarity of S1 = {Ontario, Toronto} and S2 = {Alberta, Ontario, Manitoba} is 0.25. The helper
-- method similarity computes the Jaccard similarity of two sets of strings. Your job is to use the similarity
-- method to find the politians whose description attributes have similarity is above a given threshold.
select p.id as id1, p2.id as id2,
 p.description as desc1, p2.description as desc2,
 p.comment as comm1,  p2.comment as comm2
from parlgov.politician_president p, parlgov.politician_president p2
where p.id <> p2.id and p.id = 9;

create table testp2q4(
  id int,
  description VARCHAR(1000),
  comment VARCHAR(1000)
);

insert into testp2q4 values
  (9, 'Ontario Toronto', 'Canada'),
  (10, 'Alberta Ontario Manitob', 'Canada'),
  (11, 'Alberta Ontario Manitoba London Boston', 'Canada'),
  (12, 'Ontario Toronto', 'Canada Alberta Toronto Vinland');
---------------------------------------------------------------

--electionSequence
--ElectionCabinetResult

--: A method that, given a country, returns the list of elections in that country, in descending
--order of years, and the cabinets that have formed after that election and before the next election of the same
--type.

--find query

----------------------------------
every election in a country
create view everyelection as
select e1.id, c1.name, e1.e_type, e1.e_date as eldate, e2.e_date as nxteldate
from parlgov.election e1 join parlgov.country c1 on e1.country_id = c1.id
full join parlgov.election e2 on e2.e_type = e1.e_type
and (e2.previous_ep_election_id = e1.id or e2.previous_parliament_election_id = e1.id)
where c1.name = 'Germany'
order by e1.e_date desc;

select e.id, e.name, c.id as cabid, e.eldate, c.start_date as cabdate, e.nxteldate
from everyelection e left join everycabinet c
on c.start_date >= e.eldate and c.start_date <= e.nxteldate
and c.name = e.name
order by e.eldate desc;

-------------------------------------
select e1.id, e1.e_type, c1.name, cb.id as cabid , cb.start_date ,e1.e_date as eldate
from parlgov.election e1 join parlgov.country c1 on e1.country_id = c1.id
full join parlgov.election e2 on e2.e_type = e1.e_type
and e2.previous_parliament_election_id = e1.id
full join parlgov.cabinet cb on cb.country_id = c1.id and date_part('year',cb.start_date) >= date_part('year',e1.e_date)
and cb.election_id = e1.id
where c1.name = 'Germany'
order by e1.e_date desc;

or?
------------------
select e1.id, e1.e_type, c1.name, cb.id as cabid , cb.start_date ,e1.e_date as eldate, e2.e_date as nxteldate
from parlgov.election e1 join parlgov.country c1 on e1.country_id = c1.id
full join parlgov.election e2 on e2.e_type = e1.e_type
and e2.previous_parliament_election_id = e1.id
full join parlgov.cabinet cb on cb.country_id = c1.id and date_part('year',cb.start_date) >= date_part('year',e1.e_date)
and (date_part('year',e2.e_date) >= date_part('year',cb.start_date) or cb.election_id = e1.id)
where c1.name = 'Germany'
order by e1.e_date desc;
----------------------------------------------
select *
from
((select e1.id, c1.name, cb.id as cabid , cb.start_date ,e1.e_date as eldate
from parlgov.election e1 join parlgov.country c1 on e1.country_id = c1.id
full join parlgov.election e2 on e2.e_type = e1.e_type
and e2.previous_parliament_election_id = e1.id
left join parlgov.cabinet cb on cb.country_id = c1.id and date_part('year',cb.start_date) >= date_part('year',e1.e_date)
and date_part('year',e2.e_date) >= date_part('year',cb.start_date) and cb.election_id = e1.id
where c1.name = 'Germany' and e1.id not in (
  select e.id
  from parlgov.election e
  join parlgov.country c on e.country_id = c.id
 join parlgov.cabinet cb on cb.start_date >= e.e_date
  and cb.country_id = c.id
  where e.e_date >= ALL (
    select e_date
    from parlgov.election e1
    join parlgov.cabinet cb1 on cb1.start_date >= e1.e_date
    and cb1.country_id = c.id
    where e1.country_id = c.id
    and cb.id is not null and e1.id is not null
  )
  and c.name = 'Germany'
)
) union (
  select e.id, c.name, cb.id as cabid, cb.start_date, e.e_date as eldate
  from parlgov.election e
  join parlgov.country c on e.country_id = c.id
  join parlgov.cabinet cb on cb.start_date >= e.e_date
  and cb.country_id = c.id
  where e.e_date >= ALL (
    select e_date
    from parlgov.election e1
    join parlgov.cabinet cb1 on cb1.start_date >= e1.e_date
    and cb1.country_id = c.id
    where e1.country_id = c.id
    and cb.id is not null and e1.id is not null
  )
  and c.name = 'Germany'
)) done
order by done.eldate desc;
--------------------------------------------------

select e1.id as election, c1.name as country, e1.e_date as eldate, e2.id as nextelection, e2.e_date as nextelectiondate
from parlgov.election e1 join parlgov.country c1 on e1.country_id = c1.id
join parlgov.election e2 on e2.e_type = e1.e_type
and (e2.previous_ep_election_id = e1.id or e2.previous_parliament_election_id = e1.id)
where c1.name = 'Japan'
order by e1.e_date desc;

every cabinet
create view  everycabinet as
select c.id, cc.name, c.start_date
from parlgov.cabinet c join parlgov.country cc on c.country_id = cc.id
where cc.name = 'Germany'
order by c.start_date desc;


--almost?
create view
select * from
((select e1.id, c1.name, cb.id as cabid ,e1.e_date, cb.start_date
from parlgov.election e1 join parlgov.country c1 on e1.country_id = c1.id
join parlgov.cabinet cb on cb.country_id = c1.id and cb.start_date >= e1.e_date
 join parlgov.election e2 on e2.e_type = e1.e_type
and e2.previous_parliament_election_id = e1.id
and e2.e_date >= cb.start_date
where c1.name = 'Germany'
and cb.election_id = e1.id)
Union (
  select e.id, c.name, cb.id as cabid, cb.start_date, e.e_date
  from parlgov.election e
  join parlgov.country c on e.country_id = c.id
 join parlgov.cabinet cb on cb.start_date >= e.e_date
  and cb.country_id = c.id
  where e.e_date >= ALL (
    select e_date
    from parlgov.election e1
    join parlgov.cabinet cb1 on cb1.start_date >= e1.e_date
    and cb1.country_id = c.id
    where e1.country_id = c.id
    and cb.id is not null and e1.id is not null
  )
  and c.name = 'Germany')
) done
order by done.e_date desc;


select e.id, c.name, cb.id as cabid, cb.start_date, e.e_date
from parlgov.election e
join parlgov.country c on e.country_id = c.id
join parlgov.cabinet cb on cb.start_date >= e.e_date
and cb.country_id = c.id
where e.e_date >= ALL (
  select e_date
  from parlgov.election e1
  join parlgov.cabinet cb1 on cb1.start_date >= e1.e_date
  and cb1.country_id = c.id
  where e1.country_id = c.id
  and cb.id is not null and e1.id is not null
)
and c.name = 'Germany';



select e.id, c.name, e.e_date
from parlgov.election e
join parlgov.country c on e.country_id = c.id
where c.name = 'Germany'
order by e.e_date desc;




--temp
select e1.id, c1.name, e1.e_type
from parlgov.election e1 join parlgov.country c1 on e1.country_id = c1.id
join parlgov.cabinet cb on cb.country_id = c1.id and cb.start_date >= e1.e_date
where c1.name = 'Japan'
order by e1.e_date desc;
