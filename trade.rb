require 'json'
require 'csv'
require 'sqlite3'
require 'time'
require 'pp'

class Systems
  def initialize
    @systems = Hash.new
    File.open("data/systems_populated.json") do |f|
      puts "Parsing systems_populated.json into JSON.."
      JSON.parse(f.read).each do |c|
        system_id = c['id']
        @systems[system_id] = c
      end
    end
  end

  def find(system_search_id)
    system = @systems.fetch(system_search_id)
    puts "System Name  : #{system['name']}"
    puts "Allegiance   : #{system['allegiance']}"
    puts "Security     : #{system['security']}"
    puts "Needs permit : #{system['needs_permit']}"
    puts "X coordinate : #{system['x']}"
    puts "Y coordinate : #{system['y']}"
  end
end

class Stations
  def initialize
    @stations = Hash.new
    File.open("data/stations.json") do |f|
      puts "Parsing stations.json into JSON.."
      JSON.parse(f.read).each do |c|
        station_id = c['id']
        @stations[station_id] = c
      end
    end
  end

  def find(station_search_id)
    station = @stations.fetch(station_search_id)
    puts "Station Name       : #{station['name']}"
    puts "Landing Pad Size   : #{station['max_landing_pad_size']}"
    puts "Distance from star : #{station['distance_to_star']} Ls"
    puts "Market updated at  : #{Time.at(station['market_updated_at'])}"
    puts "Planetary station  : #{station['is_planetary']}"
    return station['system_id']
  end
end

class Commodities
  def initialize
    @commodities = Hash.new
    File.open("data/commodities.json") do |f|
      puts "Parsing commodities.json into JSON.."
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
    puts "Best trading deals in the bubble (disregarding distance)"
    puts
    for c in @commodities[0..10]
      j = c[1]
      puts j['name']
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

    lowest_buy_price_data   = @db.execute(buy_price_sql)[0]
    highest_sell_price_data = @db.execute(sell_price_sql)[0]

    lowest_buy_price   = lowest_buy_price_data[5]
    highest_sell_price = highest_sell_price_data[6]
    buy_station_id     = lowest_buy_price_data[1]
    sell_station_id    = highest_sell_price_data[1]

    puts "-------------------------------------------"
    puts "Lowest buy price   : #{lowest_buy_price} CR"
    puts "Highest sell price : #{highest_sell_price} CR"
    puts "Profit per trip    : #{highest_sell_price - lowest_buy_price} CR"
    puts "-------------------------------------------"


    return buy_station_id, sell_station_id
  end
end

systems = Systems.new
stations = Stations.new
commodities = Commodities.new
listings = Listings.new

puts "-------------------------------------------"

commodities.print_top_10

buy_station_id, sell_station_id = listings.find(commodities.first_result)

puts
puts "-- Purchase commodity from --"
buy_system_id  = stations.find(buy_station_id)
systems.find(buy_system_id)

puts
puts "-- Sell commodity at --"
sell_system_id = stations.find(sell_station_id)
systems.find(sell_system_id)
