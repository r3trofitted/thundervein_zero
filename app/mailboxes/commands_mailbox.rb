require "action_mailbox_ext"
using ActionMailboxExt

##
# Handles the command-related incoming emails
#
# At the moment, a "command" is basically the equivalent of a +create+ action on applicable resources, such as 
# +Order+ or +Participation+. (Commands involving other actions, such as +destroy+, could possibly be introduced 
# in the future.)
#
# This mailbox's is responsible for several things:
#
# - Identify the resource to be created (this is currently done by analysing the mail's subject).
# - Build the new resource from the information available in the email. (This should eventually involve some kind of NLP.)
# - Attempt to save the new resource.
# - If the resource *cannot* be saved, send a notification (via a bounce email).
#
# Do note that if the resource *is* saved (in other words, if the command succeeds), the mailbox does nothing. 
# Confirmations/positive feedback are under the responsibility of the resources themselves.
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
      bounce_with CommandsMailer.with(game:, player: commanded.player)
                                .command_failed(commanded),
                                deliver_now: true # skipping ActiveJob because the +player+ param may not be serializable
    end
  end
  
  def game
    @game ||= Game.find_by(id: mail.to.grep(MATCHER) { $1 })
  end
  
  private
  
  def new_participation
    game.participations.build(
      player_attributes: {
        email_address: mail.from_address.address,
        name: mail.from_address.display_name
      }
    )
  end
  
  # Creates an Order object from instructions in the email body.
  #
  # This is a *very* crude implementation – the instructions have to follow 
  # a very precise format, like "move X units from A to B" or 
  # "attack with X units from A to B".
  #
  # A smarter implementation, with possibly actual lexing, should eventually replace 
  # this system. And be handed off to a dedicated object.
  def new_order
    text = mail.body.to_s
    
    type   = /(move|attack)(?=\s+)/i.match(text).to_s.capitalize
    units  = /\d+(?=\s+units?)/i.match(text).to_s
    # for origin and target, a lookbehind cannot be used because Ruby only allows fixed-length lookbehinds
    origin = /(?:from\s+)(\w+)/i.match(text) { |m| m[1].downcase }
    target = /(?:to\s+)(\w+)/i.match(text) { |m| m[1].downcase }
    
    game.current_turn.orders.build type:, units:, origin:, target:, player: Player.find_by(email_address: mail.from)
  end
  
  def new_status_report
    # TODO
    game.status_report
  end
end
