class Participation < ApplicationRecord
  include Commandable
  
  belongs_to :game
  belongs_to :player
  
  validates_uniqueness_of :player, scope: :game
  validates_presence_of :game, :player
  validates_associated :player
  
  after_create :notify
  
  def notify
    ArbiterMailer.with(game:, player:).participation.deliver_later
  end
end
