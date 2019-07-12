4. Sequences of Cabinets. For each country, report the cabinets formed over time

create view almost as
select c.name as countryName, cab.id as cabinetId, cab.start_date as startDate,
ed.enddate as endDate, c.id as countryID
from cabinet cab join country c on c.id = cab.country_id
full join enddate ed on cab.id = ed.id;

select a.countryName, a.cabinetId, a.startDate, a.endDate, party.name as pmParty
from almost a left join cabinet_party cp on a.cabinetId = cp.cabinet_id
join party on party.id = cp.party_id
where cp.pm
order by a.countryName desc, a.startDate asc;

# finding end date
create view enddate as
select c2.id as cabid, c.start_date as enddate
from cabinet c, cabinet c2
where c.previous_cabinet_id = c2.id;
