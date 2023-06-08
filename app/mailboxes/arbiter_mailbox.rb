class ArbiterMailbox < ApplicationMailbox
  MATCHER = /^arbiter@(\d+)?/i # e.g. arbiter@123456.thundervein-0.game for game 123456
  
  before_processing :ensure_player_is_a_participant, if: -> { command.order? }
  
  def process
    case
    when command.order?
      order = Order.from_text(mail.body.to_s) do |o|
        o.player = player
        o.turn   = game.current_turn
      end
      
      order.save!
    when command.join?
      # SLIME
      game.add_participant name: mail.from_address.display_name, email_address: mail.from_address.address
    end
  end
  
  def command
    @command ||= case mail.subject
                 when /^join$/i then "join"
                 when /^(move|attack|order)$/i then "order"
                 else ""
                 end.inquiry
  end
  
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
      if game_id = mail.to.grep(MATCHER) { $1 } # finds the first matching address and returns the captured group
        Game.find_by(id: game_id)
      end
    end
  end
  
end
