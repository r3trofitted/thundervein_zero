class ApplicationMailbox < ActionMailbox::Base
  routing OrdersMailbox::MATCHER => :orders
end
