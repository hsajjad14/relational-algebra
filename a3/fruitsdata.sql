delete from loyalty_card;
delete from beverage_prices;
delete from juice_stock;
delete from beverages;
delete from store;

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


-- stores
--delete from store;
insert into store values ('Toronto', '4167084988', 'Zain');
insert into store values ('Toronto', '4161334000', 'Tom');
insert into store values ('Boston', '2222', 'Brady');
insert into store values ('Chicago', '5197084988', 'James');


-- juice stock
--delete from juice_stock;
insert into juice_stock values ('Toronto','Apple', 'regular', 2);
insert into juice_stock values ('Toronto','Apple', 'regular', 3); -- add to 5
insert into juice_stock values ('Boston','Apple', 'regular', 2);

-- juice prices
--delete from beverage_prices;
insert into beverage_prices values ('Apple', 'regular',null ,2.5);


-- loyalty_card
insert into loyalty_card values ('premium', 111 , 1 ,'Toronto');
insert into loyalty_card values ('premium', 111 , 4,'Toronto'); -- add to 5
insert into loyalty_card values ('premium', 113 , 4,'New York'); -- fails, no city NewYork
insert into loyalty_card values ('premium', 131 , 4,'Chicago');
