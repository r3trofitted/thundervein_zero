class Move < Order
  validates :target, presence: true, empty_or_occupied_by_player: true
  validates :units, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than: ->(m) { m.board.units_in(m.origin) } }
  
  def resolve
    board.update_for_move(units, from: origin, to: target)
  end
end
