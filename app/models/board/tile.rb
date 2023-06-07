class Board
  ##
  # Represents a tile of the board.
  #
  # Tile have an occupant (a Player) and a number of units.
  # 
  # Tiles are like the physical pieces of the board on which the units 
  # are placed. Each tile represents a zone of the board; when a player 
  # occupies a zone, it is as if physical tiles where actually swapped on 
  # the board.
  #
  # (Note: I'm using Data here simply to try this new feature out; at the moment, 
  # I'm not convinced that the immutability it offers over Struct is worth 
  # anything here, but we'll see…)
  Tile = Data.define(:occupant, :units) do
    def occupied_by?(player)
      occupant == player
    end
  end
end
