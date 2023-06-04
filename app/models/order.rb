class Order < ApplicationRecord
  belongs_to :turn
  belongs_to :player
  
  delegate :board, to: :turn
  
  class OccupiedByPlayerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :not_occupied_by_player) unless value.occupant == record.player
    end
  end
  
  class EmptyOrOccupiedByPlayerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if occupant = value.occupant
        record.errors.add(attribute, :occupied) unless occupant == record.player
      end
    end
  end
  
  class OccupiedByAnotherPlayerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if occupant = value.occupant
        record.errors.add(attribute, :occupied_by_player) if occupant == record.player
      else
        record.errors.add(attribute, :empty)
      end
    end
  end
  
  validates :origin, presence: true, occupied_by_player: true

  def origin
    board.public_send super
  end
  
  def target
    board.public_send super
  end
end
