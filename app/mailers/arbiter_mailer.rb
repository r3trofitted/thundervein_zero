class ArbiterMailer < ApplicationMailer
  before_action { @game, @recipient = params[:game], params[:recipient] }

  default from: -> { arbiter_address },
          to:   -> { @recipient }

  def participation
    mail
  end

  def command_failed(errors)
    Rails.logger.debug errors
    mail
  end
  
  private
  
  def arbiter_address
    "arbiter@#{@game.id}.thundervein-0.game" # TODO: make the domain configurable?
  end
end
