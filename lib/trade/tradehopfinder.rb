require_relative 'systems'
require_relative 'stations'
require_relative 'commodities'
require_relative 'listings'
require_relative 'route'

class TradeHopFinder
  attr_reader :systems, :stations, :commodities, :listings
  def initialize
    @systems     = Systems.new
    @stations    = Stations.new
    @commodities = Commodities.new
    @listings    = Listings.new
    @routes      = Array.new
  end

  def find_best_single_hop
    commodity = @commodities.top_commodity
    buy_station_id, sell_station_id = @listings.find(commodity['id'])

    for i in 0..10
      buy_station  = @stations.find(@listings.buy_listings[i][1])
      sell_station = @stations.find(@listings.sell_listings[i][1])
      buy_system   = @systems.find(buy_station['system_id'])
      sell_system  = @systems.find(sell_station['system_id'])
      r = Route.new(commodity, buy_system, sell_system, buy_station, sell_station)
      @routes.push(r)
    end

    @routes.each do |r|
      puts "-------------------------------------------"
      puts "Trade route distance: #{calculate_distance(r.buy_system, r.sell_system)} LY"
      puts "Buy #{r.commodity['name']}"
      print_system_info(r.buy_system)
      print_station_info(r.buy_station)

      puts "        >>>>>>>>>>>>>>>>>>>>>>>>>>>        "

      puts "Sell #{r.commodity['name']}"
      print_system_info(r.sell_system)
      print_station_info(r.sell_station)
      puts "-------------------------------------------"
    end
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
    (Integer.sqrt( (a_x - b_x)**2 + (a_y - b_y)**2 + (a_z - b_z)**2 )).abs
  end
end
