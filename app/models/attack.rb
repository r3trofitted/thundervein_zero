class Attack < Order
  validates :target, presence: true, occupied_by_another_player: true
  validates :units, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: ->(a) { a.board.units_in(a.origin) } }
  validates :engagement, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: ->(a) { a.units } }
  
  def pending?
    result.pending?
  end
  
  def successful?
    result.successful?
  end
  
  def failed?
    result.failed?
  end
  
  def result
    case guess
    when nil then "pending"
    when engagement then "failed"
    else "successful"
    end.inquiry
  end
end
