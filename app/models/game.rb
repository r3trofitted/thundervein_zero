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
  
  def arbiter_email_address
    "arbiter@#{id}.thundervein-0.game" # TODO: make the domain configurable?
  end
end
