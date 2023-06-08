class ApplicationMailbox < ActionMailbox::Base
  routing ArbiterMailbox::MATCHER => :arbiter
end
