STATIONS = "data/stations.json"

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
