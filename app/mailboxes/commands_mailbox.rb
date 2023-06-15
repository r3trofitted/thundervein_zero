require "action_mailbox_ext"
using ActionMailboxExt

class CommandsMailbox < ApplicationMailbox
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
      # TODO: call a more specializer mailer, if available? (e.g. OrdersMailer if commanded is a +Order+)
      bounce_with CommandsMailer.with(game:, player: commanded.player)
                                .command_failed(commanded),
                                deliver_now: true # skipping ActiveJob because player may not be serializable
    end
  end
  
  def game
    @game ||= Game.find_by(id: mail.to.grep(MATCHER) { $1 })
  end
  
  private
  
  def new_participation
    @game.participations.build(player_attributes: {
                                                    email_address: mail.from_address.address, 
                                                    name: mail.from_address.display_name
                                                  })
  end
  
  def new_order
    Order.from_text(mail.body.to_s) do |o|
      o.player = Player.find_by email_address: mail.from
      o.turn   = game.current_turn
    end
  end
  
  def new_status_report
    # TODO
    game.status_report
  end
end
