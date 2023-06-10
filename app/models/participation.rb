class Participation < ApplicationRecord
  belongs_to :game
  belongs_to :player
  
  validates_uniqueness_of :player_id, scope: :game_id
  validates_associated :game, :player
  
  with_options on: :create do
    validate :game_must_not_be_already_started, :game_must_not_be_full
    validate :player_must_not_be_already_participating
  end
  
  accepts_nested_attributes_for :player
  
  after_create :notify
  
  def notify
    ArbiterMailer.with(game:, player:).participation.deliver_later
  end
  
  def game_must_not_be_already_started
    errors.add :base, :game_already_started if game.started?
  end

  def game_must_not_be_full
    errors.add :base, :game_already_full if game.full?
  end

  def player_must_not_be_already_participating
    errors.add :base, :player_already_participating if game.participations.excluding(self).exists?(player: player)
  end
end
