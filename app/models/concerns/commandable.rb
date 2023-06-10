module Commandable
  extend ActiveSupport::Concern
  
  included do
    has_one :command, as: :commandable#, touch: true
  end
end
