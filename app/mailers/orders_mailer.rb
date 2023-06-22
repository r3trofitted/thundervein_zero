class OrdersMailer < ApplicationMailer
  before_action { @order = params[:order] }

  default from: -> { @order.game.arbiter_email_address },
          to:   -> { @order.player_email_address }

  def confirmation
    mail subject: "Order received (game ##{@order.game_id}, turn #{@order.turn_number})"
  end
end
