class ArbiterMailbox < ApplicationMailbox
  MATCHER = /^(?:arbiter|commands?)@(\d+)/i # e.g. arbiter@123456.thundervein-0.game for game 123456
  
  before_processing :bounced!, if: -> { game.blank? }
  
  def process
    case mail.subject
    when /^join$/i
      join_game
    when /^(move|attack|order)$/i
      receive_order
    end
  end
  
  def game
    @game ||= Game.find_by(id: mail.to.grep(MATCHER) { $1 })
  end
  
  private
  
  def join_game
    player = Player.find_or_initialize_by(email_address: mail.from_address.address).tap { |p| p.name ||= mail.from_address.display_name }
    participation = @game.participations.build(player: player)
    
    unless participation.save
      bounce_with ArbiterMailer.with(game:, player:).command_failed(participation.errors.details)
    end
  end
  
  def receive_order
    player = Player.find_by email_address: mail.from
    
    order = Order.from_text(mail.body.to_s) do |o|
      o.player = player
      o.turn   = game.current_turn
    end
    
    unless order.save
      bounce_with ArbiterMailer.with(game:, player:).command_failed(order.errors.details)
    end
  end
end
