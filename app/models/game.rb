class Game < ApplicationRecord
  has_many :turns, -> { order(number: :asc) }
  has_one :current_turn, -> { order(number: :desc) }, class_name: "Turn"
  
  has_many :participations
  has_many :players, through: :participations
  
  def add_participant(name:, email_address:)
    player = Player.find_or_initialize_by(email_address: email_address)
    player.name = name
    
    players << player
  end
end
