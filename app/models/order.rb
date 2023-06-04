class Order < ApplicationRecord
  belongs_to :turn
  belongs_to :player
  
  scope :colliding, -> { where(target: Order.select(:target).group(:turn_id, :target).having("COUNT(target) > 1")) }
  scope :not_colliding, -> { where(target: Order.select(:target).group(:turn_id, :target).having("COUNT(target) = 1")) }
  
  enum :status, %i(received carried_out canceled), default: :received
  
  delegate :board, to: :turn
  
  class OccupiedByPlayerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :not_occupied_by_player) unless record.board.occupant_of(value) == record.player
    end
  end
  
  class EmptyOrOccupiedByPlayerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if occupant = record.board.occupant_of(value)
        record.errors.add(attribute, :occupied) unless occupant == record.player
      end
    end
  end
  
  class OccupiedByAnotherPlayerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if occupant = record.board.occupant_of(value)
        record.errors.add(attribute, :occupied_by_player) if occupant == record.player
      else
        record.errors.add(attribute, :empty)
      end
    end
  end
  
  validates :origin, presence: true, occupied_by_player: true
end
