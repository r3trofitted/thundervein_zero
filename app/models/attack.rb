class Attack < Order
  validates :target, presence: true, occupied_by_another_player: true
  validates :units, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: ->(a) { a.board.units_in(a.origin) } }
  validates :engagement, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: ->(a) { a.units } }
  
  def all_in?
    units == board.units_in(origin)
  end
  
  def pending?
    result.pending?
  end
  
  def successful?
    result.successful?
  end
  
  def failed?
    result.failed?
  end
  
  def resolve
    case result
    when "successful"
      if all_in?
        board.remove(:all, from: target)
      else
        board.move(units, from: origin, to: target)
      end
    when "failed"
      board.remove(engagement, from: origin)
    else
      # TODO: fail silently instead?
      raise "Cannot resolve a pending attack"
    end
  end
  
  # TODO: renaming to outcome would make sense, since we now have a +#result+ method
  # (and "result" sounds like what you get once you _resolve_ the attack)
  def result
    case guess
    when nil then "pending"
    when engagement then "failed"
    else "successful"
    end.inquiry
  end
end
