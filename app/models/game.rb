class Game < ApplicationRecord
  has_many :turns, -> { order(number: :asc) }
  has_one :current_turn, -> { order(number: :desc) }, class_name: "Turn"
  
  has_many :participations
  has_many :players, through: :participations
  
  def started?
    turns.any?
  end
  
  def full?
    players.count >= max_players
  end
end
