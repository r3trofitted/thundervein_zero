class OrdersMailer < ApplicationMailer
  before_action { @game, @player = params[:game], params[:player] }

  default to:   -> { @player.email_address },
          from: -> { orders_address(@game) }

  def error_no_participation
    mail
  end
end
