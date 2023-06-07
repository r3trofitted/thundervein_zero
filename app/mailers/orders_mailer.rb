class OrdersMailer < ApplicationMailer
  before_action { @order = params[:order] }

  default from: -> { orders_address(@order.game) }

  def confirmation
    mail to: @order.player_email_address
  end

  # SMELL: no @order variable instance is needed – is this method in the right mailer?
  def error_no_participation(game, player)
    @game   = game
    @player = player
    
    mail to: player.email_address
  end
end
