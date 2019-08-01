delete from beverages;
insert into beverages values ('Orange', 'regular', 100); --pass
insert into beverages values ('Orange', 'large', 200); -- fail
insert into beverages values ('Cola', 'regular', 100); -- pass
insert into beverages values ('Apple', 'regular', 100); --pass
insert into beverages values ('Apple', 'large', 500);--pass
insert into beverages values ('Apple', 'regular', 400);--fail

-- should fail
update beverages set calories = 500
   where beverage_name = 'Apple' and beverage_size = 'regular';

-- should fail
update beverages set calories = 200
  where beverage_name = 'Apple' and beverage_size = 'large';

-- should pass
  update beverages set calories = 600
    where beverage_name = 'Apple' and beverage_size = 'large';
