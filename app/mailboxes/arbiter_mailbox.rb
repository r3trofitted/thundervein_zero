class ArbiterMailbox < ApplicationMailbox
  MATCHER = /^(?:arbiter|commands?)@(\d+)/i # e.g. arbiter@123456.thundervein-0.game for game 123456
  
  before_processing :bounced!, if: -> { game.blank? }
  
  def process
    command = Command.from_mail(mail, game:)
    
    unless command.execute
      bounce_with ArbiterMailer.with(game:, player: command.try(:player)).command_failed(command.errors)
    end
  end
  
  def game
    @game ||= Game.find_by(id: mail.to.grep(MATCHER) { $1 })
  end
end
