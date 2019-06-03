require_relative 'systems'
require_relative 'stations'
require_relative 'commodities'
require_relative 'listings'
require_relative 'route'

module EliteTrader
  class TradeHopFinder
    attr_reader :systems, :stations, :commodities, :listings
    def initialize(verbose=false)
      @systems     = Systems.new(verbose)
      @stations    = Stations.new(verbose)
      @commodities = Commodities.new(verbose)
      @listings    = Listings.new(verbose)

      @routes      = Array.new
    end

    def find_best_single_hop(options)
      commodity = @commodities.top_commodity
      @listings.find(commodity['id'])

      for x in 0..options[:listings]
        for y in 0..options[:listings]
          buy_listing  = @listings.buy_listings[x]
          sell_listing = @listings.sell_listings[y]
          buy_station  = @stations.find(@listings.buy_listings[x][1])
          sell_station = @stations.find(@listings.sell_listings[y][1])
          buy_system   = @systems.find(buy_station['system_id'])
          sell_system  = @systems.find(sell_station['system_id'])
          r = Route.new(commodity, buy_listing, sell_listing, buy_system,
                        sell_system, buy_station, sell_station)
          @routes.push(r)
        end
      end

      @routes.sort! {|a,b| a.profit_per_ly <=> b.profit_per_ly }.reverse!

      @routes.delete_if do |r|
        buy_padsize  = r.buy_station['max_landing_pad_size']
        sell_padsize = r.sell_station['max_landing_pad_size']
        options[:large_pads] && (buy_padsize != "L" || sell_padsize != "L")
      end

      @routes.delete_if do |r|
        buy_sec  = r.buy_system['security']
        sell_sec = r.sell_system['security']
        options[:ignore_anarchy] && (buy_sec == "Anarchy" || sell_sec == "Anarchy")
      end

      puts "-------------------------------------------"
      @routes.first(options[:results]).each_with_index do |r, idx|
        puts "Route ##{idx+1}"
        puts "-------------------------------------------"
        puts "Trade route distance: #{r.distance} LY"
        puts "Profit: #{r.profit} CR/ton"
        puts "Profit per LY: #{r.profit_per_ly} CR/LY"
        puts
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
      puts "System Name        : #{system['name']}"
      puts "Population         : #{system['population']}"
      puts "Government         : #{system['government']}"
      puts "Allegiance         : #{system['allegiance']}"
      puts "Security           : #{system['security']}"
      puts "Primary Economy    : #{system['primary_economy']}"
      puts "Needs permit       : #{system['needs_permit']}"
    end

    def print_station_info(station)
      puts "Station Name       : #{station['name']}"
      puts "Landing Pad Size   : #{station['max_landing_pad_size']}"
      puts "Distance from star : #{station['distance_to_star']} Ls"
      puts "Market updated at  : #{Time.at(station['market_updated_at'])}"
      puts "Planetary station  : #{station['is_planetary']}"
    end
  end
end
