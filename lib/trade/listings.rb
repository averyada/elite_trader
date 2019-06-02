LISTINGS_DB = "data/listings.db"

## id,station_id,commodity_id,supply,supply_bracket,buy_price,sell_price,
## demand,demand_bracket,collected_atq
class Listings
  def initialize
    puts "Creating connection to #{LISTINGS_DB}.."
    @db = SQLite3::Database.new LISTINGS_DB
    @listings = Array.new
  end

  def find(commodity_search_id)
    buy_price_sql = <<~SQL
    SELECT * FROM listings
    WHERE commodity_id == #{commodity_search_id}
    ORDER BY buy_price=0, buy_price ASC
    SQL

    sell_price_sql = <<~SQL
    SELECT * FROM listings
    WHERE commodity_id == #{commodity_search_id}
    ORDER BY sell_price DESC
    SQL

    lowest_buy_price_data   = @db.execute(buy_price_sql)[0]
    highest_sell_price_data = @db.execute(sell_price_sql)[0]

    buy_station_id     = lowest_buy_price_data[1]
    sell_station_id    = highest_sell_price_data[1]

    return buy_station_id, sell_station_id
  end
end
