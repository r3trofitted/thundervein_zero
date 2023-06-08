class Participation < ApplicationRecord
  belongs_to :game
  belongs_to :player
  
  after_create :notify
  
  def notify
    GamesMailer.with(game:, player:).participation.deliver_later
  end
end
