class Board
  ##
  # Represents a zone on the board. A Hex can be occupied (by a Player) and have 
  # units.
  #
  # (Note: I'm using Data here simply to try this new feature out; at the moment, 
  # I'm not convinced that the immutability it offers over Struct is worth 
  # anything here, but we'll see…)
  Hex = Data.define(:occupant, :units) do
    def occupied_by?(player)
      occupant == player
    end
  end
end
