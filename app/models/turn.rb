class Turn < ApplicationRecord
  belongs_to :game
  has_many :orders
  
  serialize :board, Board
  
  def resolve!
    new_turn = dup.tap { |t| t.increment :number }
    new_turn.save!
    new_turn
  end
end
