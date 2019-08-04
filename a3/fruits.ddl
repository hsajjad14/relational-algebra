

DROP SCHEMA IF EXISTS fruits CASCADE;
CREATE SCHEMA fruits;

set SEARCH_PATH to fruits;

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


  create table beverages(
    -- name of the beverage
    beverage_name VARCHAR(50) not null,
    -- size of the beverage
    beverage_size size not null,
    -- number of calories in each beverages
    calories int not null,
    -- unique(beverage_name, beverage_size),
    primary key(beverage_name, beverage_size)
    --
    -- check((beverage_size = 'large' and beverage_name in (
    --   select beverage_name from beverages where beverage_size = 'regular')
    --   and calories > (select calories from beverages b where b.beverage_name = beverage_name
    --   and b.beverage_size = 'regular') + 200)
    --   or beverage_size = 'regular')
    );

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

  create trigger bev_cal_ins
    before insert or update
    on beverages
    for each row
    execute procedure bevdelete();






create table juice_stock(
      -- city where the store is located
      city VARCHAR(50) references store(city),
      -- name of the beverage
      beverage_name VARCHAR(50),
      -- size of the beverage
      beverage_size size,
      -- quantity of the juice in stock at a store
      in_stock INT NOT NULL check(in_stock >= 0),
      foreign key (beverage_name, beverage_size) references beverages(beverage_name, beverage_size),
      primary key(city, beverage_name, beverage_size)
);


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

create trigger tigger_increment_instock
  before insert
  on juice_stock
  for each row
  execute procedure increment_instock();




create table beverage_prices(
  -- name of the beverage
  beverage_name VARCHAR(50),
  -- size of the beverage
  beverage_size size,
  -- loyalty card is also a factor in a beverage's price
  loyalty VARCHAR(50),
  -- price of the beverage
  price real not null,

  foreign key (beverage_name, beverage_size) references beverages(beverage_name, beverage_size),
  primary key(beverage_name, beverage_size, loyalty)
);


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

create trigger check_null_bp
  before insert
  on beverage_prices
  for each row
  execute procedure bprice_checknull();


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

create trigger tigger_increment_transactions
  before insert
  on loyalty_card
  for each row
  execute procedure increment_transactions();


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
  foreign key (beverage_name, beverage_size) references beverages(beverage_name, beverage_size)

);
