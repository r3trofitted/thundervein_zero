class Move < Order
  validates :target, presence: true, empty_or_occupied_by_player: true
  validates :units, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than: ->(m) { m.origin.units } }
end
