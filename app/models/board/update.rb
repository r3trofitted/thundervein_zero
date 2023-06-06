class Board
  ##
  # Represents an update to apply to the board.
  #
  # Updates are the results of carried out orders. They are composed of one or more 
  # +Hex+ objects, keyed to zones of the board, and qualified with a _type_.
  #
  # Since updates usually represent units movements, they are often composed of 
  # two Hex objects, qualified of +:origin+ (where the units move from) and +:target+
  # (where the units move to) respectively. But single-Hex updates are possible, 
  # too (when units are removed from the board, for example).
  class Update
    delegate :size, :[], :delete, to: :@hexes_with_types
    
    # Updates expect at least one Hex, but any number can be passed. Hexes should 
    # be passed as keyword arguments, the keyword being a zone of the board, 
    # and the value a 2-tuple (an Array) whose first value is a Hex and the 
    # second a type (e.g +:origin+ or +:target+_). For example:
    #
    #   # (This update is probably the result of player_a moving from :north to occupy :south with 2 units, leaving 1 behind.)
    #   Board::Update.new(
    #     north: [Board::Hex.new(occupant: player_a, units: 1), :origin], 
    #     south: [Board::Hex.new(occupant: player_a, units: 3), :target]
    #   )
    def initialize(**hexes_with_types)
      @hexes_with_types = hexes_with_types
    end
    
    def hexes
      @hexes_with_types.transform_values(&:first)
    end
    
    # Returns the zones that overlap with another update (e.g. when a player moves to a 
    # zone that another player partially leaves).
    def overlaping_zones_with(other)
      hexes.keys & other.hexes.keys
    end
    
    # Indicates if for a given region of the board (e.g. +:north+, +:west+, etc.) 
    # this update has a hex of the +:origin+ type.
    def origin_in?(zone)
      @hexes_with_types[zone].last == :origin
    end
  end
end
