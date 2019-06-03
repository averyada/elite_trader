SYSTEMS_POPULATED_JSON = "data/systems_populated.json"

module EliteTrader
  class Systems
    def initialize(verbose=false)
      @systems = Hash.new
      File.open(SYSTEMS_POPULATED_JSON) do |f|
        puts "Parsing systems_populated.json into JSON.." if verbose
        JSON.parse(f.read).each do |c|
          system_id = c['id']
          @systems[system_id] = c
        end
      end
    end

    def find(system_search_id)
      return @systems.fetch(system_search_id)
    end
  end
end
