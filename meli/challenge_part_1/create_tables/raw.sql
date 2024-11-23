-- CREATING

CREATE TABLE raw."customers" (
  "customer_id" serial PRIMARY KEY,
  "e_mail" text,
  "name" text,
  "last_name" text,
  "gender" text,
  "birth_date" date,
  "is_active" bool,
  "creation_date" timestamp,
  "update_date" timestamp
);

CREATE TABLE raw."sellers" (
  "seller_id" serial PRIMARY KEY,
  "customer_id" integer,
  "store_name" text
);

CREATE TABLE raw."adresses" (
  "adress_id" serial PRIMARY KEY,
  "customer_id" integer,
  "label" text,
  "street" text,
  "number" integer,
  "complement" text,
  "neighborhood" text,
  "state" text,
  "zip_code" integer,
  "country" text,
  "creation_date" timestamp
);

CREATE TABLE raw."items" (
  "item_id" serial PRIMARY KEY,
  "seller_id" integer,
  "item_name" text,
  "description" text,
  "category_id" integer,
  "amount" float,
  "available_quantity" integer,
  "create_date" timestamp,
  "updated_date" timestamp,
  "end_date" timestamp
);

CREATE TABLE raw."categories" (
  "category_id" serial PRIMARY KEY,
  "category_name" text,
  "path" text,
  "description" text,
  "creation_date" timestamp,
  "update_date" timestamp
);

CREATE TABLE raw."orders" (
  "order_id" serial PRIMARY KEY,
  "item_id" integer,
  "customer_id" integer,
  "amount" float,
  "status" text, -- Aqui o status é se a compra foi criada, cancelada, finalizada e etc
  "creation_date" timestamp,
  "update_date" timestamp
);


-- REFERENCING

ALTER TABLE raw."adresses" ADD FOREIGN KEY ("customer_id") REFERENCES raw."customers" ("customer_id");

ALTER TABLE raw."sellers" ADD FOREIGN KEY ("seller_id") REFERENCES raw."customers" ("customer_id");

ALTER TABLE raw."items" ADD FOREIGN KEY ("seller_id") REFERENCES raw."sellers" ("seller_id");

ALTER TABLE raw."items" ADD FOREIGN KEY ("category_id") REFERENCES raw."categories" ("category_id");

ALTER TABLE raw."orders" ADD FOREIGN KEY ("item_id") REFERENCES raw."items" ("item_id");

ALTER TABLE raw."orders" ADD FOREIGN KEY ("customer_id") REFERENCES raw."customers" ("customer_id");


-- POPULATING
-- Assumindo que os dados vem direto do banco de dados de produção como estão