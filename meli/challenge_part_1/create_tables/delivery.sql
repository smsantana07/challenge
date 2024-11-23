-- CREATING

CREATE TABLE "dim_sellers" (
  "seller_id" integer PRIMARY KEY,
  "customer_id" integer,
  "customer_name" text,
  "store_name" text,
  "birth_date_id" integer
);

CREATE TABLE "dim_date" (
  "date_id" integer PRIMARY KEY,
  "year" integer,
  "month" integer,
  "day" integer
);

CREATE TABLE "dim_categories" (
  "category_id" integer PRIMARY KEY,
  "category_name" text,
  "path" text,
  "description" text
);

CREATE TABLE "dim_items" (
  "item_id" integer,
  "item_name" text,
  "amount" float,
  "end_date_id" integer,
  "processed_at_date_id" integer
);

CREATE TABLE "fact_sales" (
  "seller_id" integer,
  "order_date_id" integer,
  "category_id" text,
  "total_items" integer,
  "total_amount" float
);

CREATE TABLE "fact_daily_item_status" (
  "item_id" integer,
  "item_name" text,
  "amount" float,
  "status" integer, -- Aqui vai ser 1 quando o produto tiver ativo e 0 quando tiver inativo (ou disponível ou indisponível)
  "processed_at_date_id" integer
);


-- REFERENCING

ALTER TABLE "fact_sales" ADD FOREIGN KEY ("seller_id") REFERENCES "dim_sellers" ("seller_id");

ALTER TABLE "fact_sales" ADD FOREIGN KEY ("order_date_id") REFERENCES "dim_date" ("date_id");

ALTER TABLE "fact_sales" ADD FOREIGN KEY ("category_id") REFERENCES "dim_categories" ("category_id");

ALTER TABLE "dim_sellers" ADD FOREIGN KEY ("birth_date_id") REFERENCES "dim_date" ("date_id");

ALTER TABLE "fact_daily_item_status" ADD FOREIGN KEY ("processed_at_date_id") REFERENCES "dim_date" ("date_id");

ALTER TABLE "dim_items" ADD FOREIGN KEY ("processed_at_date_id") REFERENCES "dim_date" ("date_id");

ALTER TABLE "fact_daily_item_status" ADD FOREIGN KEY ("item_id") REFERENCES "dim_items" ("item_id");


-- POPULATING

-- dim_date
INSERT INTO delivery."dim_date"
SELECT
  CAST(TO_CHAR(dimension_date, 'YYYYMMDD') AS INTEGER) AS date_id,
  EXTRACT(YEAR FROM dimension_date) AS year,
  EXTRACT(MONTH FROM dimension_date) AS month,
  EXTRACT(DAY FROM dimension_date) AS day
FROM generate_series(
  DATE('1990-01-01'), 
  DATE('2100-12-31'),
  INTERVAL '1 day'
) AS dimension_date;

-- dim_sellers
INSERT INTO delivery."dim_sellers"
SELECT 
  s.seller_id,
  s.customer_id,
  (c.name || ' ' || c.last_name) AS customer_name,
  s.store_name,
  c.birth_date_id
FROM raw."sellers" AS s
LEFT JOIN raw."customers" AS c
  ON s.seller_id = c.customer_id;

-- dim_categories
INSERT INTO delivery."dim_categories"
SELECT
  c.category_id,
  c.category_name,
  c.path, 
  c.description
FROM raw."categories" AS c;

-- dim_items
INSERT INTO delivery."dim_items"
SELECT
  i.item_id,
  i.item_name,
  i.amount, 
  CAST(TO_CHAR(i.end_date, 'YYYYMMDD') AS INTEGER) AS end_date_id,
  CAST(TO_CHAR(CURRENT_DATE(), 'YYYYMMDD') AS INTEGER) AS processed_at_date_id
FROM raw."items" AS i;

-- fact_sales
INSERT INTO delivery."fact_sales"
SELECT 
  i.seller_id,
  CAST(TO_CHAR(o.creation_date, 'YYYYMMDD') AS INTEGER) AS date_id,
  c.category_id,
  count(o.order_id) AS total_items,
  sum(o.amount) AS total_amount
FROM raw."orders" AS o
LEFT JOIN raw."items" AS i
  ON o.item_id = i.item_id
LEFT JOIN raw."categories" AS c
  ON i.category_id = c.category_id ;

-- fact_daily_item_status
CREATE TABLE delivery."fact_daily_item_status" (
  "item_id" integer,
  "item_name" text,
  "amount" text,
  "status" integer,
  "order_date_id" integer,
  "processed_at_date_id" integer
);