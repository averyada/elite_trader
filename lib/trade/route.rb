class Route
  attr_reader :commodity, :buy_system, :sell_system, :buy_station, :sell_station

  def initialize(commodity, buy_system, sell_system, buy_station, sell_station)
    @commodity    = commodity
    @buy_system   = buy_system
    @sell_system  = sell_system
    @buy_station  = buy_station
    @sell_station = sell_station
  end
end
