class Player < ApplicationRecord
  belongs_to :game
  has_many :orders
  has_many :turns, through: :orders
end
