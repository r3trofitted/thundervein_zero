class OrdersMailerPreview < ActionMailer::Preview
  def confirmation
    OrdersMailer.with(order: Order.last).confirmation
  end
end
