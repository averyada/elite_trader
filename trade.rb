require 'json'
require 'csv'
require 'sqlite3'
require 'pp'

class Commodities
  def initialize
    @commodities = Hash.new
  end

  def open_and_parse
    File.open("data/commodities.json") do |f|
      puts "Parsing commodities.json into JSON..\n\n"
      @commodities = Hash.new
      JSON.parse(f.read).each do |c|
        buy_price, sell_price = c['min_buy_price'], c['max_sell_price']
        unless buy_price.nil? or sell_price.nil?
          profit = sell_price - buy_price
          @commodities[profit] = c
        end
      end
    end
    @commodities = @commodities.sort.reverse
  end

  def print_top_10
    for c in @commodities[0..10]
      j = c[1]
      puts j['name']
      puts j['id']
      puts "Profit: #{c[0]}"
      puts "Minimum Buy Price: #{j['min_buy_price']}"
      puts "Maximum Sell Price: #{j['max_sell_price']}"
      puts "\n"
    end
  end

  def first_result
    @commodities[0][1]['id']
  end
end

## id,station_id,commodity_id,supply,supply_bracket,buy_price,sell_price,
## demand,demand_bracket,collected_atq
class Listings
  def initialize
    @db = SQLite3::Database.new "listings.db"
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
    lowest_buy_price = @db.execute(buy_price_sql)[0][5]
    highest_sell_price = @db.execute(sell_price_sql)[0][6]
    puts "-------------------------------------------"
    puts "Lowest buy price   : #{lowest_buy_price} CR"
    puts "Highest sell price : #{highest_sell_price} CR"
    puts "Profit per trip    : #{highest_sell_price - lowest_buy_price} CR"
  end
end

c = Commodities.new
c.open_and_parse
c.print_top_10

l = Listings.new
l.find(c.first_result)
