module EliteTrader
  class Route
    attr_reader :commodity, :buy_system, :sell_system, :buy_station, :sell_station

    def initialize(commodity, buy_system, sell_system, buy_station, sell_station)
      @commodity    = commodity
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
  end
end
