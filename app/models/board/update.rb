class Board
  class Update
    delegate :size, :[], :delete, to: :@zones_with_types
    
    def initialize(**zones_with_types)
      @zones_with_types = zones_with_types
    end
    
    def zones
      @zones_with_types.transform_values(&:first)
    end
    
    def overlaping_zones_with(other)
      zones.keys & other.zones.keys
    end
    
    def origin_in?(zone)
      @zones_with_types[zone].last == :origin
    end
  end
end
