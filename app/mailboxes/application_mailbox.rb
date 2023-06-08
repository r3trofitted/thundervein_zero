class ApplicationMailbox < ActionMailbox::Base
  routing OrdersMailbox::MATCHER => :orders
  routing CommandsMailbox::MATCHER => :commands
end
