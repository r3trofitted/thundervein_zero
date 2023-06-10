class ArbiterMailbox < ApplicationMailbox
  MATCHER = /^(?:arbiter|commands?)@(\d+)/i # e.g. arbiter@123456.thundervein-0.game for game 123456
  
  before_processing :bounced!, if: -> { game.blank? }
  
  def process
    commanded = case mail.subject
                when /^join$/i
                  new_participation
                when /^(move|attack|order)$/i
                  new_order
                when /^status(\s+(report|update))?$/i
                  new_status_report
                end
  
    unless commanded.save
      bounce_with ArbiterMailer.with(game:, player: commanded.player).command_failed(commanded.errors.details)
    end
  end
  
  def game
    @game ||= Game.find_by(id: mail.to.grep(MATCHER) { $1 })
  end
  
  private
  
  def new_participation
    player = Player.find_or_initialize_by(email_address: mail.from_address.address).tap { |p| p.name ||= mail.from_address.display_name }
    # TODO: @game.participations.build_for_new_or_existing_player(email_address: …)
    # TODO: or use accepts_nested_attributes instead?
    
    @game.participations.build(player: player)
  end
  
  def new_order
    Order.from_text(mail.body.to_s) do |o|
      o.player = Player.find_by email_address: mail.from
      o.turn   = game.current_turn
    end
  end
  
  def new_status_report
    game.status_report
  end
end
