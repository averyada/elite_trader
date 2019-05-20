#!/usr/bin/ruby

require 'json'
require 'csv'
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

  def return_first_result
    @commodities[0][1]['id']
  end
end

## id,station_id,commodity_id,supply,supply_bracket,buy_price,sell_price,
## demand,demand_bracket,collected_atq
class Listings
  def initialize
    @listings = Array.new
  end

  def find(commodity_search_id)
    File.open("data/listings.csv") do |f|
      CSV.parse(f.read) do |c|
        commodity_id = c[2].to_i
        if commodity_search_id == commodity_id then
          @listings.push commodity_id
        end
        @listings.sort
      end
    end
    puts "Listings size: #{@listings.count}"
  end
end

c = Commodities.new
c.open_and_parse
c.print_top_10

l = Listings.new
puts l.find(c.return_first_result)
