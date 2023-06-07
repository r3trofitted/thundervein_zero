class OrdersMailbox < ApplicationMailbox
  def process
    order = Order.from_text(mail.body) do |o|
      o.player = player
      o.turn   = turn
    end
    
    order.save!
  end
  
  private
  
  def game
    @game ||= Game.find_by(id: mail.to_addresses.map(&:domain).map(&:to_i))
  end
  
  # TODO: either find the game through the player, or the player through the game, or 
  # check that the player is indeed playing the game (and that the game is open to orders…)
  def player
    @player ||= Player.find_by(email_address: mail.from)
  end
  
  def turn
    @turn ||= game.turns.started.last
  end
end
