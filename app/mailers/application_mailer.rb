class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
  
  def orders_address(game)
    "orders@#{game.id}.thundervein-0.game" # TODO: make the domain configurable?
  end
end
