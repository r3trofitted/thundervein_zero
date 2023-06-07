class ApplicationMailbox < ActionMailbox::Base
  routing /^orders@\d+/i => :orders
end
