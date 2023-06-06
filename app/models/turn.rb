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
  enum :status, %i(started resolution_in_progress finished)
  
  def resolve!
    resolution_in_progress!
    
    return false if orders.any? { |o| o.try(:pending?) } # TODO: add a dummy #pending to Order instead?
    
    # less efficient that +.update_all+, but perf is not an issue yet, so 
    # let's keep the callbacks and have the timestamps be taken care of along the status
    orders.colliding.each &:canceled!
    
    orders_to_carry_out = orders.to_carry_out # caching to avoid another query later on
    
    # collecting all the board updates and managing "conflicts"
    updates = orders_to_carry_out.flat_map(&:resolve)
    updates.repeated_combination(2) do |a, b|
      next if a == b
    
      a.overlaping_zones_with(b).each do |zone|
        [a, b].find { |u| u.origin_in? zone }.delete(zone)
      end
    end
    
    # creating the new turn with its updated board
    new_turn = Turn.new(game: game, number: number + 1, board: board.revise(updates)) do |t|
      yield t if block_given?
    end
    
    orders_to_carry_out.each &:carried_out!
    finished!
  end
end
