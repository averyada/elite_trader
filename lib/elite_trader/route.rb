module EliteTrader
  class Route
    attr_reader :commodity, :buy_system, :sell_system, :buy_station,
                :sell_station, :buy_listing, :sell_listing

    def initialize(commodity, buy_listing, sell_listing, buy_system, sell_system,
                   buy_station, sell_station)
      @commodity    = commodity
      @buy_listing  = buy_listing
      @sell_listing = sell_listing
      @buy_system   = buy_system
      @sell_system  = sell_system
      @buy_station  = buy_station
      @sell_station = sell_station
    end

    def distance
      a, b = @buy_system, @sell_system
      a_x, a_y, a_z, b_x, b_y, b_z = a['x'], a['y'], a['z'], b['x'], b['y'], b['z']
      (Integer.sqrt( (a_x - b_x)**2 + (a_y - b_y)**2 + (a_z - b_z)**2 )).abs
    end

    def profit
      @sell_listing[6] - @buy_listing[5]
    end

    def profit_per_ly
      (profit / distance.to_f).round(2)
    end
  end
end
