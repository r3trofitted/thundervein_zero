class Turn < ApplicationRecord
  belongs_to :game
  has_many :orders
  
  serialize :board, Board
  
  def resolve!
    new_turn = dup.tap { |t| t.increment :number }
    moves.each do |move|
      new_turn.board.move(move.units, from: move.origin, to: move.target)
    end
    new_turn.save!
    yield new_turn if block_given?
    true
  end
  
  def moves
    orders.where(type: "Move")
  end
end
