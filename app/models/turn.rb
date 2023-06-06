class Turn < ApplicationRecord
  FinishedTurn = Class.new(StandardError)
  
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
  
  ##
  # Resolves a turn.
  #
  # The resolution in the last phase of a turn; once in progress, no more orders can be passed.
  # Resolving a turn is a process with several steps:
  #
  # - Canceling the colliding orders, if any.
  # - Carrying out the other orders, thus collecting a list of _updates_ (+Board::Update+) to the game board.
  # - Merging the updates, so that conflicting states can be resolved (see below).
  # - Building a new +Turn+ object with an updated board.
  #
  # On top of this process, the turn status has to be updated when the resolution starts and ends.
  #
  # == Merging the updates
  #
  # Because all orders are supposed to happen simultaneously, the updates follows two orders may contradict
  # one another. For example:
  #
  # - If players A and B attack each other (a "switcheroo attack"), and both attacks succeed, then the 
  #   no update should include a directive to leave some units from an attack on its origin. (In other words: the units 
  #   left behind by A are removed to make room for B's attacking units, and vice versa.)
  # - If player A successfully attacks B and player B successfully attacks C, then update for B's attack 
  #   should not include the leaving of units on its origin, since they are replaced by A's occupying units.
  #
  # == New turn
  #
  # When a turn is resolved, a new +Turn+ is created, *but not started*. This new turn is yielded.
  #
  # == Result
  #
  # Returns true if the resolution went through, false otherwise (e.g. if some orders are still pending).
  def resolve!
    raise FinishedTurn if finished?
    
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
    new_turn = Turn.create!(game: game, number: number + 1, board: board.revise(updates)) do |t|
      yield t if block_given?
    end
    
    orders_to_carry_out.each &:carried_out!
    finished!
  end
end
