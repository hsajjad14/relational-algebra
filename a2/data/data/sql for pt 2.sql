
--electionSequence
--ElectionCabinetResult

--: A method that, given a country, returns the list of elections in that country, in descending
--order of years, and the cabinets that have formed after that election and before the next election of the same
--type.

--find query
select elecid, cabid, elecdate from temp
where name = 'United Kingdom'
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
join parlgov.cabinet cab on cab.country_id = c.id and cab.start_date >= e.e_date
join nextparlelection npe on e.id = npe.id and cab.start_date <= npe.enddate;
-- where c.name = 'United Kingdom';

create view almostEPel as
select c.name, cab.id as cabid, cab.start_date as cabstartdate, e.e_date as elecdate, e.id as elecid,
npe.enddate as nextelectiondate
from parlgov.country c join parlgov.election e on e.country_id = c.id
join parlgov.cabinet cab on cab.country_id = c.id and cab.start_date >= e.e_date
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
 p.description as desc1, p2.description as desc2
from politician_president p, politician_president p2
where p.id < p2.id and p.id = 1;
