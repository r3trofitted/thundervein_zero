class Turn < ApplicationRecord
  belongs_to :game
  has_many :orders do
    def colliding
      received.merge(Order.colliding)
    end
    
    def to_carry_out
      received.merge(Order.not_colliding)
    end
  end
  
  serialize :board, Board
  enum :status, %i(started resolution_in_progress finished), default: :started
  
  def resolve!
    new_turn = dup.tap { |t| t.increment :number }
    
    # less efficient that +.update_all+, but perf is not an issue yet, so 
    # let's keep the callbacks and have the timestamps be taken care of along the status
    orders.colliding.each &:canceled!
    
    moves.to_carry_out.each do |move|
      new_turn.board.move(move.units, from: move.origin, to: move.target)
      move.carried_out!
    end
    
    new_turn.save!
    
    yield new_turn if block_given?
    
    finished!
  end
  
  def moves
    orders.where(type: "Move")
  end
end
