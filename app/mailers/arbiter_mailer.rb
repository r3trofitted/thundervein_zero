class ArbiterMailer < ApplicationMailer
  before_action { @game, @player = params[:game], params[:player] }

  default from: -> { arbiter_address },
          to:   -> { @player.email_address }

  def participation
    mail
  end

  def command_failed(errors)
    p errors
    mail
  end
  
  private
  
  def arbiter_address
    "arbiter@#{@game.id}.thundervein-0.game" # TODO: make the domain configurable?
  end
end
