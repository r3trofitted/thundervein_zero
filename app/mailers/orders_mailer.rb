class OrdersMailer < ApplicationMailer
  before_action { @order = params[:order] }

  def confirmation
    mail subject: "Order received (game ##{@order.game_id}, turn #{@order.turn_number})"
  end
end
