.mode csv
.open data/listings.db
BEGIN;
CREATE TABLE listings(
  "id" INTEGER NOT NULL,
  "station_id" INTEGER NOT NULL,
  "commodity_id" INTEGER NOT NULL,
  "supply" INTEGER NOT NULL,
  "supply_bracket" INTEGER NOT NULL,
  "buy_price" INTEGER NOT NULL,
  "sell_price" INTEGER NOT NULL,
  "demand" INTEGER NOT NULL,
  "demand_bracket" INTEGER NOT NULL,
  "collected_at" INTEGER NOT NULL
);
COMMIT;
.import data/listings.csv listings
