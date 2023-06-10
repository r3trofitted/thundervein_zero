class Command < ApplicationRecord
  belongs_to :game
  belongs_to :player, optional: true
  
  delegated_type :commandable, types: %w(Participation Order)
end

