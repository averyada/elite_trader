#!/usr/bin/ruby

require 'json'
require 'pp'

File.open("data/commodities.json") do |f|
  puts "Parsing commodities.json into JSON..\n\n"
  @commodities = Hash.new
  JSON.parse(f.read).each do |c|
    buy_price, sell_price = c['min_buy_price'], c['max_sell_price']
    unless buy_price.nil? or sell_price.nil?
      profit = sell_price - buy_price
      @commodities[profit] = c
      #pp @commodities.sort
    end
  end
  for c in @commodities.sort.reverse[0..10]
    j = c[1]
    puts j['name']
    puts "Profit: #{c[0]}"
    puts "Minimum Buy Price: #{j['min_buy_price']}"
    puts "Maximum Sell Price: #{j['max_sell_price']}"
    puts "\n"
  end
end
