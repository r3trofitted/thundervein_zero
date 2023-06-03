class Turn < ApplicationRecord
  belongs_to :game
  
  serialize :board, Board
end
