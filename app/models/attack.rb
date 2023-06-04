class Attack < Order
  validates :target, presence: true, occupied_by_another_player: true
  validates :units, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: ->(a) { a.origin.units } }
  validates :engagement, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: ->(a) { a.units } }
end
