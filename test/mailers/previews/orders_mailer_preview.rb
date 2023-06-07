# Preview all emails at http://localhost:3000/rails/mailers/orders_mailer
class OrdersMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/orders_mailer/error_no_participation
  def error_no_participation
    OrdersMailer.error_no_participation
  end

end
