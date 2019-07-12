-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.

CREATE TABLE q4(
        countryName VARCHAR(50),
        cabinetId INT,
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
create view enddate as
select c2.id, c.start_date as enddate
from cabinet c, cabinet c2
where c.previous_cabinet_id = c2.id;

create view almost as
select c.name as countryName, cab.id as cabinetId, cab.start_date as startDate,
ed.enddate as endDate, c.id as countryID
from cabinet cab join country c on c.id = cab.country_id
full join enddate ed on cab.id = ed.id;

-- the answer to the query
insert into q4 select a.countryName, a.cabinetId, a.startDate, a.endDate, party.name as pmParty
from almost a left join cabinet_party cp on a.cabinetId = cp.cabinet_id
join party on party.id = cp.party_id
where cp.pm;
--order by c.name desc, cab.start_date asc;
