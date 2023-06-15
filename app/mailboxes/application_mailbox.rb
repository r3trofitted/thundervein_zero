class ApplicationMailbox < ActionMailbox::Base
  routing CommandsMailbox::MATCHER => :commands
end
