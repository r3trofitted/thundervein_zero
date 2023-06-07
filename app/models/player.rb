class Player < ApplicationRecord
  has_many :participations
  has_many :games, through: :participations
  
  has_many :orders
  has_many :turns, through: :orders
end
