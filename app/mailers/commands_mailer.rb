class CommandsMailer < ApplicationMailer
  before_action { @game = params[:game] }

  default from: -> { @game.arbiter_email_address }

  def command_failed(commanded)
    # p commanded.errors
    Rails.logger.debug commanded.errors
    
    # case [commanded, commanded.errors[:base]]
      # in 
    
    # == Participation
    # game_already_full
    # game_already_started
    # game_already_full
    # could_not_create_player_player_name_blank
    # already_playing
    
    # == Order
    # doesnt_participate_in_indicated_game
    # game_not_started
    # game_over
    # turn_being_resolved
    # order_already_given
    # missing_attribute
    
    mail to: commanded.player.email_address # TODO: will there always be a player?
  end
end