class Turn < ApplicationRecord
  belongs_to :game
  has_many :orders
  
  serialize :board, Board
  
  def resolve!
    new_turn = dup.tap { |t| t.increment :number }
    moves.each do |move|
      origin = Board::Zone.new occupant: move.player, units: move.origin.units - move.units
      target = Board::Zone.new occupant: move.player, units: move.target.units + move.units
      
      new_turn.board.public_send "#{move.origin_before_type_cast}=", origin
      new_turn.board.public_send "#{move.target_before_type_cast}=", target
    end
    new_turn.save!
    yield new_turn if block_given?
    true
  end
  
  def moves
    orders.where(type: "Move")
  end
end
