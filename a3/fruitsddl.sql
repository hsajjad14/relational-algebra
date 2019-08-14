

DROP SCHEMA IF EXISTS fruits CASCADE;
CREATE SCHEMA fruits;

set SEARCH_PATH to fruits;

-- Store table,
-- Every tuple is a fruit juice store
-- every crity has a single store,
-- city is the key
create table store(
  -- city where the store is located
  city VARCHAR(50) primary key,
  -- phone number of each store, only in the format:
  -- 1234445678, no '-' or any characters in the number
  phone VARCHAR(10)  not null,
  -- name of the manager
  manager VARCHAR(50) not null

);

-- beverage sizes can only be large or regular
create type size as enum(
  'large', 'regular');

-- beverages table, every beverage
-- has a name, size, and number of calories
  create table beverages(
    -- name of the beverage
    beverage_name VARCHAR(50) not null,
    -- size of the beverage
    beverage_size size not null,
    -- number of calories in each beverages
    calories int not null,
    -- unique(beverage_name, beverage_size),
    primary key(beverage_name, beverage_size)
    );

-- trigger function to assure a large
-- beverage has 200 more calories than it's
-- regular sized counterpart
create or replace function bevdelete()
      returns trigger as
    $BODY$
    begin
        if ((new.beverage_size = 'large' and new.beverage_name in
            (select beverage_name from
              beverages where beverage_size = 'regular'
              and calories >= new.calories - 200
            )
        ) or
          (new.beverage_size = 'regular' and new.beverage_name in
            (select beverage_name from
              beverages where beverage_size = 'large'
              and calories - 200 <= new.calories

            )
        ))
        then
              return null;
        end if;
        return new;
    end;
    $BODY$
    language 'plpgsql';

-- trigger to control above function
-- triggers for insertions or updates on beverages table
  create trigger bev_cal_ins
    before insert or update
    on beverages
    for each row
    execute procedure bevdelete();





-- beverages in-stock table
-- holds the beverages in in-stock
-- in a store, Every beverage is identified
-- by its name, size and store (city)
create table juice_stock(
      -- city where the store is located
      city VARCHAR(50) references store(city),
      -- name of the beverage
      beverage_name VARCHAR(50),
      -- size of the beverage
      beverage_size size,
      -- quantity of the juice in stock at a store
      in_stock INT NOT NULL check(in_stock >= 0),
      -- beverage name and size is a subset from beverages table
      foreign key (beverage_name, beverage_size) references beverages(beverage_name, beverage_size),
      primary key(city, beverage_name, beverage_size)
);

-- incrementer function
-- to keep track of the in-stock
-- if a tupple with a existing key is inserted
-- the new in-stock changes to be new + old
create or replace function increment_instock()
      returns trigger as
      $BODY$
      begin
          if ((new.city, new.beverage_name, new.beverage_size) in
          (select city, beverage_name, beverage_size from juice_stock) )
          then
                update juice_stock
                  set in_stock = in_stock + new.in_stock
                where
                  city = new.city and beverage_name = new.beverage_name
                  and beverage_name = new.beverage_name;

                return null;
          end if;
          return new;
      end;
      $BODY$
      language 'plpgsql';

-- trigger for above function
-- works before insert on juice_stock table
create trigger tigger_increment_instock
  before insert
  on juice_stock
  for each row
  execute procedure increment_instock();



-- holds the price of each beverage
-- a beverage price may be dependent on
-- its name, size, and loyalty card used
-- if no loyalty card is use replace null
-- with 'None'
create table beverage_prices(
  -- name of the beverage
  beverage_name VARCHAR(50),
  -- size of the beverage
  beverage_size size,
  -- loyalty card is also a factor in a beverage's price
  loyalty VARCHAR(50),
  -- price of the beverage
  price real not null,
  -- beverage name and size is a subset from beverages table
  foreign key (beverage_name, beverage_size) references beverages(beverage_name, beverage_size),
  primary key(beverage_name, beverage_size, loyalty)
);

-- function to replace null loyalty
-- with 'None'
create or replace function bprice_checknull()
      returns trigger as
      $BODY$
      begin
          if (new.loyalty is null)
          then
                new.loyalty = 'None';
                --return new;
          end if;
          return new;
      end;
      $BODY$
      language 'plpgsql';

-- trigger for above function
-- for beverage_prices
create trigger check_null_bp
  before insert
  on beverage_prices
  for each row
  execute procedure bprice_checknull();

-- loyalty_card table, keeps track
-- of the loyalty_card, the customer who
-- holds it, number of transactions on it
-- and home city.
create table loyalty_card(
  -- loyalt card
  loyalty VARCHAR(50) not null,
  -- customer id
  customer_id int not null,
  -- number of transactions made with this card
  number_transactions int not null check(number_transactions >= 0),
  -- city whith the store they visit most frequently
  home_store VARCHAR(50) references store(city),

  primary key(loyalty, customer_id)

);

-- function to increment number of transactions
-- used by a loyalty_card.
-- if a tupple with an existing key is added
-- increment the number of transactions by new + old
create or replace function increment_transactions()
      returns trigger as
      $BODY$
      begin
          if ((new.loyalty, new.customer_id) in
          (select loyalty, customer_id from loyalty_card) )
          then
                update loyalty_card
                  set number_transactions = number_transactions + new.number_transactions
                where
                  loyalty = new.loyalty and customer_id = new.customer_id;

                return null;
          end if;
          return new;
      end;
      $BODY$
      language 'plpgsql';

-- trigger for above function
create trigger tigger_increment_transactions
  before insert
  on loyalty_card
  for each row
  execute procedure increment_transactions();

-- transaction table
-- records every transaction (reciept), its date,
-- city (store), beverage bought, and customer who bought it
create table transactions(
  -- transaction number
  transaction_id int primary key,
  -- city (store) where the transaction happened
  city VARCHAR(50) references store(city),
  -- name of beverage bought
  beverage_name VARCHAR(50),
  -- size of the beverage bought
  beverage_size size,
  -- date of transaction
  t_date date not null,
  -- loyalty card used, if any
  loyalty VARCHAR(50), -- references loyalty_card?
  -- id of the customer in the transaction
  customer_id int not null,
  -- beverage name and size is a subset from beverages table
  foreign key (beverage_name, beverage_size) references beverages(beverage_name, beverage_size)

);

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
insert into beverages values ('Mountain Dew', 'regular', 400);--pass
insert into beverages values ('Mountain Dew', 'large', 700);--fail
insert into beverages values ('Mountain Dew', 'large', 800);--pass
insert into beverages values ('Pineapple', 'regular', 250);--pass
insert into beverages values ('Pineapple', 'large', 400);--fail
insert into beverages values ('Pineapple', 'large',500);--pass



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
insert into store values ('Balitamore', '5199085977', 'James');
insert into store values ('Miami', '224567890', 'Jenny');
insert into store values ('Malibu', '9875698456', 'David');

-- juice stock
--delete from juice_stock;
insert into juice_stock values ('Toronto','Apple', 'regular', 2);
insert into juice_stock values ('Toronto','Apple', 'regular', 3); -- add to 5
insert into juice_stock values ('Boston','Apple', 'regular', 2);
insert into juice_stock values ('Balitamore','Cola','large',5);--fail  because Cola in beverages table thus violating foreign key constraint
insert into juice_stock values ('Balitamore','Cola','large',3);--fail  because Cola in beverages table thus violating foreign key constraint
insert into juice_stock values ('Balitamore','Cola','regular',5);
insert into juice_stock values ('Balitamore','Cola','regular',3);--pass and should sum up to 8


-- juice prices
--delete from beverage_prices;
insert into beverage_prices values ('Apple', 'regular',null ,2.5);
insert into beverage_prices values ('Apple', 'regular','premium' ,0.5);
insert into beverage_prices values ('Cola', 'regular','premium' ,4.0);--pass
insert into beverage_prices values ('Cola', 'large','premium' ,4.0); -- fail because no large cola in beverages table
insert into beverage_prices values ('Mint', 'large','premium' ,4.0);--fail because no mint drink in beverages table
insert into beverage_prices values ('Mojito', 'regular','premium' ,3.0);--fail because no mojito drink in beverages table


-- loyalty_card
insert into loyalty_card values ('premium', 111 , 1 ,'Toronto');
insert into loyalty_card values ('premium', 111 , 4,'Toronto'); -- add to 5
insert into loyalty_card values ('premium', 113 , 4,'New York'); -- fails, no city NewYork
insert into loyalty_card values ('premium', 131 , 4,'Chicago');
insert into loyalty_card values (null, 131 , 4,'Chicago');--violates null constraint
insert into loyalty_card values ('premium', 131 , 4,'Chicago');--fail
insert into loyalty_card values ('premium', 131 , 3,'Chicago');--should add upto 7 fro customer id 131
insert into loyalty_card values ('premium', 144 , 4,'Montreal');--fails because no montreal city in store table
insert into loyalty_card values ('premium', 131 , 3,'Toronto');-- passes as it increments the transactions for user 131.

-- transactions
insert into transactions values (1 , 'Toronto', 'Apple', 'regular', '2015-12-17', null, 011);
insert into transactions values (1,'Toronto','Apple','regular','2019-05-05','premium',111);--fail because key 1 already exists
insert into transactions values (5,'Madison','Mango','regular','2019-04-05','premium',111);--fail due to violation of foreign key values
insert into transactions values (2,'Montreal','Apple','regular','2019-04-05',null,112);--fails due to montreal not being in store table
insert into transactions values (2,'Balitamore','Apple','regular','2019-06-05',null,112);--pass
insert into transactions values (3,'Balitamore','Cola','regular','2019-06-05',null,197);--pass
insert into transactions values (3,'Balitamore','Aoole','regular','2018-06-07','premium',201);--fails because transaction id 3 already exists
