require 'json'
require 'csv'
require 'sqlite3'
require 'time'
require 'thor'
require 'pp'

# Data sources
SYSTEMS_POPULATED = "data/systems_populated.json"
STATIONS          = "data/stations.json"
COMMODITIES       = "data/commodities.json"

# Database
LISTINGS_DB       = "listings.db"

class TradeHopFinder
  attr_reader :systems, :stations, :commodities, :listings
  def initialize
    @systems     = Systems.new
    @stations    = Stations.new
    @commodities = Commodities.new
    @listings    = Listings.new
  end

  def top_profitable_commodity
    return @commodities.first_result
  end

  def find_best_single_hop
    commodity = @commodities.first_result
    buy_station_id, sell_station_id = @listings.find(commodity['id'])

    buy_station  = @stations.find(buy_station_id)
    sell_station = @stations.find(sell_station_id)
    buy_system   = @systems.find(buy_station['system_id'])
    sell_system  = @systems.find(sell_station['system_id'])

    puts "-------------------------------------------"
    puts "Trade route distance: #{calculate_distance(buy_system, sell_system)} LY"
    puts "Buy #{commodity['name']}"
    print_system_info(buy_system)
    print_station_info(buy_station)

    puts
    puts "Sell #{commodity['name']}"
    print_system_info(sell_system)
    print_station_info(sell_station)
    puts "-------------------------------------------"

  end

  private
  def print_system_info(system)
    puts "System Name  : #{system['name']}"
    puts "Allegiance   : #{system['allegiance']}"
    puts "Security     : #{system['security']}"
    puts "Needs permit : #{system['needs_permit']}"
    puts "X coordinate : #{system['x']}"
    puts "Y coordinate : #{system['y']}"
  end

  def print_station_info(station)
    puts "Station Name       : #{station['name']}"
    puts "Landing Pad Size   : #{station['max_landing_pad_size']}"
    puts "Distance from star : #{station['distance_to_star']} Ls"
    puts "Market updated at  : #{Time.at(station['market_updated_at'])}"
    puts "Planetary station  : #{station['is_planetary']}"
  end

  def calculate_distance(a, b)
    a_x, a_y, a_z, b_x, b_y, b_z = a['x'], a['y'], a['z'], b['x'], b['y'], b['z']

    dist = (Integer.sqrt( (a_x - b_x)**2 + (a_y - b_y)**2 + (a_z - b_z)**2 )).abs
  end
end

class Systems
  def initialize
    @systems = Hash.new
    File.open(SYSTEMS_POPULATED) do |f|
      puts "Parsing systems_populated.json into JSON.."
      JSON.parse(f.read).each do |c|
        system_id = c['id']
        @systems[system_id] = c
      end
    end
  end

  def find(system_search_id)
    return @systems.fetch(system_search_id)
  end
end

class Stations
  def initialize
    @stations = Hash.new
    File.open(STATIONS) do |f|
      puts "Parsing stations.json into JSON.."
      JSON.parse(f.read).each do |c|
        station_id = c['id']
        @stations[station_id] = c
      end
    end
  end

  def find(station_search_id)
    return @stations.fetch(station_search_id)
  end
end

class Commodities
  def initialize
    @commodities = Hash.new
    File.open(COMMODITIES) do |f|
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
    @commodities[0][1]
  end
end

## id,station_id,commodity_id,supply,supply_bracket,buy_price,sell_price,
## demand,demand_bracket,collected_atq
class Listings
  def initialize
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

    lowest_buy_price   = lowest_buy_price_data[5]
    highest_sell_price = highest_sell_price_data[6]
    buy_station_id     = lowest_buy_price_data[1]
    sell_station_id    = highest_sell_price_data[1]

    return buy_station_id, sell_station_id
  end
end

class App < Thor
  package_name "eett"

  map "-B" => :besthop

  def self.exit_on_failure?
    true
  end

  desc "besthop", "Calculate the most profitable single hop trade route"
  def besthop
    tradehops = TradeHopFinder.new
    tradehops.find_best_single_hop()
  end
end

App.start
