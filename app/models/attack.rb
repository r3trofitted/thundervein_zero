class Attack < Order
  concerning :Validators do
    class OccupiedByMovingPlayerValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add(attribute, :not_occupied_by_player) unless value.occupant == record.player
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
  end

  validates :origin, presence: true, occupied_by_moving_player: true
  validates :target, presence: true, occupied_by_another_player: true
  validates :units, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: ->(a) { a.origin.units } }
  validates :engagement, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: ->(a) { a.units } }
end
