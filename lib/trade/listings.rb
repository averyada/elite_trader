LISTINGS_DB = "data/listings.db"

## id,station_id,commodity_id,supply,supply_bracket,buy_price,sell_price,
## demand,demand_bracket,collected_atq
class Listings
  attr_reader :buy_listings, :sell_listings

  def initialize
    puts "Creating connection to #{LISTINGS_DB}.."
    @db = SQLite3::Database.new LISTINGS_DB
    @buy_listings  = Array.new
    @sell_listings = Array.new
  end

  def find(commodity_search_id)
    buy_listings_sql = <<~SQL
    SELECT * FROM listings
    WHERE commodity_id == #{commodity_search_id}
    ORDER BY buy_price=0, buy_price ASC
    SQL

    sell_listings_sql = <<~SQL
    SELECT * FROM listings
    WHERE commodity_id == #{commodity_search_id}
    ORDER BY sell_price DESC
    SQL

    @buy_listings  = @db.execute(buy_listings_sql)
    @sell_listings = @db.execute(sell_listings_sql)
  end
end
