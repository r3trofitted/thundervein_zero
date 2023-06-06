class Board
  ##
  # Represents an update to apply to the board.
  #
  # Updates are the results of carried out orders. They are composed of one or more 
  # +Zone+ objects, keyed to regions of the board, and qualified with a _type_.
  #
  # Since updates usually represent units movements, they are often composed of 
  # two zones, of qualified of +:origin+ (where the units move from) and +:target+
  # (where the units move to). But single-zone updates are possible, too (when 
  # units are removed from the board, for example).
  class Update
    delegate :size, :[], :delete, to: :@zones_with_types
    
    # Updates expect at least one Zone, but any number can be passed. Zones should 
    # be passed as keyword arguments, the keyword being the name of the zone on 
    # the board, and the value a 2-tuple (an Array) whose first value is a Zone 
    # object and the second a type (e.g +:origin+ or +:target+_). For example:
    #
    #   # (This update is probably the result of player_a moving from :north to occupy :south with 2 units, leaving 1 behind.)
    #   Board::Update.new(
    #     north: [Board::Zone.new(occupant: player_a, units: 1), :origin], 
    #     south: [Board::Zone.new(occupant: player_a, units: 3), :target]
    #   )
    def initialize(**zones_with_types)
      @zones_with_types = zones_with_types
    end
    
    def zones
      @zones_with_types.transform_values(&:first)
    end
    
    # Returns the zones that overlap with another update (e.g. when a player moves to a 
    # region that another player partially leaves).
    def overlaping_zones_with(other)
      zones.keys & other.zones.keys
    end
    
    # Indicates if for a given region of the board (e.g. +:north+, +:west+, etc.) 
    # this update has a zone of the +:origin+ type.
    def origin_in?(zone)
      @zones_with_types[zone].last == :origin
    end
  end
end
