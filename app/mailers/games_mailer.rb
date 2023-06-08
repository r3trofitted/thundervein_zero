class GamesMailer < ApplicationMailer
  before_action { @game, @player = params[:game], params[:player] }

  default from: -> { arbiter_address },
          to:   -> { @player.email_address }

  def participation
    mail
  end

  def error_no_participation
    mail
  end
  
  private
  
  def arbiter_address
    "arbiter@#{@game.id}.thundervein-0.game" # TODO: make the domain configurable?
  end
end
