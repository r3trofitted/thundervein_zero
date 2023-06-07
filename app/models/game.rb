class Game < ApplicationRecord
  has_many :turns, -> { order(number: :asc) }
  has_one :current_turn, -> { order(number: :desc) }, class_name: "Turn"
  
  has_many :players
  
  def turn
    current_turn.number
  end
end
