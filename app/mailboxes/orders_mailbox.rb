class OrdersMailbox < ApplicationMailbox
  MATCHER = /^orders@(\d+)/i # e.g. orders@123456.thundervein-0.game for game 123456
  
  before_processing :ensure_player_is_a_participant
  
  # TODO: handle errors (e.g. if the current turn doesn't accept orders anymore)
  def process
    order = Order.from_text(mail.body.to_s) do |o|
      o.player = player
      o.turn   = game.current_turn
    end
    
    order.save!
  end
  
  private
  
  def ensure_player_is_a_participant
    bounced! if player.nil?
      
    unless player.in? game.players
      bounce_with GamesMailer.error_no_participation(game, player)
    end
  end
  
  def player
    @player ||= Player.find_by(email_address: mail.from)
  end

  def game
    @game ||= begin
      game_id = mail.to.grep(MATCHER) { $1 } # finds the first matching address and returns the captured group
      Game.includes(:players, :turns).find_by(id: game_id)
    end
  end
end
