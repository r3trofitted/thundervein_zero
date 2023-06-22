class CommandsMailer < ApplicationMailer
  before_action { @game = params[:game] }

  default from: -> { @game.arbiter_email_address }

  def command_failed(commanded)
    @failure_message = failure_message(commanded)
    mail to: commanded.player.email_address
  end
  
  private
  
  def failure_message(commanded)
    # TODO Order :missing_attribute
    # TODO Participation.player (e.g. player.name blank or player.email_address blank)
    case [commanded, commanded.errors.where(:base).map(&:type).first]
    in [Order, :player_not_participating]
      "Unfortunately, it appears that you are not a participating in this game."
    in [Order, :game_not_started]
      "Unfortunately, the game has not started yet. Your order has been ignored; please send it again once the game has started."
    in [Order, :game_over]
      "Unfortunately, the game is over."
    in [Order, :turn_resolution_in_progress]
      "Unfortunately, the window for giving orders during the current turn is closed."
    in [Order, :order_already_given]
      "Unfortunately, it appears that you already gave an order this turn."
    in [Participation, :game_already_started]
      "Unfortunately, the game has already started, and I must refuse your request for participating."
    in [Participation, :game_already_full]
      "Unfortunately, the game is already full, and I must refuse your request for participating."
    in [Participation, :player_already_participating]
      "Unfortunately, it appears that you are already participating in this game."
    else
      "Unfortunately, I could not understand your message. You may want to rephrase it and send it again."
    end
  end
end
