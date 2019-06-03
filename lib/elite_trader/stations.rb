STATIONS_JSON = "data/stations.json"

module EliteTrader
  class Stations
    def initialize(verbose=false)
      @stations = Hash.new
      File.open(STATIONS_JSON) do |f|
        puts "Parsing stations.json into JSON.." if verbose
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
end
