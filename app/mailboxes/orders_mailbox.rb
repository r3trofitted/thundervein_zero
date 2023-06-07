class OrdersMailbox < ApplicationMailbox
  before_processing :ensure_player_is_a_participant
  
  def process
    order = Order.from_text(mail.body.to_s) do |o|
      o.player = player
      o.turn   = turn
    end
    
    order.save!
  end
  
  private
  
  def ensure_player_is_a_participant
    bounced! if player.nil?
      
    unless player.in? game.players
      bounce_with OrdersMailer.error_no_participation(game, player)
    end
  end
  
  def player
    @player ||= Player.find_by(email_address: mail.from)
  end

  def game
    @game ||= begin
      game_id = mail.to_addresses.map(&:domain).map(&:to_i)
      Game.includes(:players, :turns).find_by(id: game_id)
    end
  end
  
  def turn
    @turn ||= game.turns.started.last
  end
end
