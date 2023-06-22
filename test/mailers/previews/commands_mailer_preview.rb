class CommandsMailerPreview < ActionMailer::Preview
  def command_failed_player_not_participating
    eisha = Player.find_by email_address: "eisha@example.com"
    game  = Game.includes(:participations).where.not(participations: { player: eisha }).first
    
    order = Move.new turn: game.current_turn, player: eisha
    order.validate
    
    CommandsMailer.with(game: game, player: eisha).command_failed(order)
  end

  def command_failed_game_not_started
    # TODO
  end
  
  def command_failed_game_over
    # TODO
  end
  
  def command_failed_turn_resolution_in_progress
    # TODO
  end
  
  def command_failed_order_already_given
    # TODO
  end
  
  def command_failed_game_already_started
    # TODO
  end
  
  def command_failed_game_already_full
    # TODO
  end
  
  def command_failed_player_already_participating
    # TODO
  end
end
