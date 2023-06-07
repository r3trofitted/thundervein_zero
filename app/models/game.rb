class Game < ApplicationRecord
  has_many :turns, -> { order(number: :asc) }
  has_one :current_turn, -> { order(number: :desc) }, class_name: "Turn"
  
  has_many :players
  
  def self.find_by_email_domain(domain_or_domains)
    Game.find_by id: Array(domain_or_domains).map { |d| d[/\d+(?=\.)/] }
  end
  
  def turn
    current_turn.number
  end
end
