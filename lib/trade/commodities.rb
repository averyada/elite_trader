COMMODITIES       = "data/commodities.json"

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
    puts "-------------------------------------------"
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
