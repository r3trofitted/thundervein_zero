class OrdersMailer < ApplicationMailer
  before_action { @order = params[:order] }

  def confirmation
    mail(
      to: @order.player_email_address,
      from: "orders@#{@order.game_id}.thundervein-0.game",
      subject: default_i18n_subject(game_id: @order.game_id, turn_number: @order.turn_number)
    )
  end
end
