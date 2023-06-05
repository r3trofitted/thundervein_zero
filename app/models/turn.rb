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
    resolution_in_progress!
    
    return false if attacks.any? &:pending?
    
    # less efficient that +.update_all+, but perf is not an issue yet, so 
    # let's keep the callbacks and have the timestamps be taken care of along the status
    orders.colliding.each &:canceled!
    
    new_turn = dup.tap { |t| t.increment :number }
    
    moves.to_carry_out.each do |move|
      new_turn.board.move(move.units, from: move.origin, to: move.target)
      move.carried_out!
    end
    
    attacks.to_carry_out.each do |attack|
      if attack.successful?
        if attack.units < board.units_in(attack.origin)
          new_turn.board.move(attack.units, from: attack.origin, to: attack.target)
        else
          new_turn.board.remove(:all, from: attack.target)
        end
      else
        new_turn.board.remove(attack.engagement, from: attack.origin)
      end
      attack.carried_out!
    end
    
    new_turn.save!
    
    yield new_turn if block_given?
    
    finished!
  end
  
  def moves
    orders.where(type: "Move")
  end
  
  def attacks
    orders.where(type: "Attack")
  end
end
