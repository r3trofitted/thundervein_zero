class Order < ApplicationRecord
  belongs_to :turn
  belongs_to :player
  
  enum :status, %i(received carried_out canceled), default: :received
  
  delegate :board, to: :turn
  
  concerning :Scopes do
    included do
      # Returns all the orders for which there is a collision.
      #
      # (A _collision_ happens when, in the same turn, two orders have the same
      # target.)
      #
      # OPTIMIZE: using a subquery for _all_ the collisions could eventually 
      # cause performance issues, but we're not there yet. In the meantime, this 
      # is (hopefully) easy to understand and DB-independent.
      scope :colliding, -> { 
        joins(<<~SQL)
          INNER JOIN (#{Order.grouped_by_collisions.to_sql}) AS collisions
          ON orders.turn_id = collisions.turn_id AND orders.target = collisions.target
        SQL
      }
      
      # Returns all the orders for which there is *no* collision.
      #
      #
      # (A _collision_ happens when, in the same turn, two orders have the same
      # target.)
      #
      # OPTIMIZE: using a subquery for _all_ the collisions could eventually 
      # cause performance issues, but we're not there yet. In the meantime, this 
      # is (hopefully) easy to understand and DB-independent.
      scope :not_colliding, -> {
        joins(<<~SQL)
          LEFT JOIN (#{Order.grouped_by_collisions.to_sql}) AS collisions
          ON orders.turn_id = collisions.turn_id AND orders.target = collisions.target
        SQL
        .where("collisions.turn_id IS NULL")
      }
      
      # Two orders with the same target, in the same turn, cause a _collision_.
      #
      # Warning: this scope only retrieves the +:turn_id+ and +:target+ fields, 
      # and because the results are grouped, not _all_ colliding orders with 
      # be returned. Still useful to know which turns and/or zones are involved
      # in collisions.
      scope :grouped_by_collisions, -> {
        select(:turn_id, :target).group(:turn_id, :target).having("COUNT(target) > 1")
      }
    end
  end
  
  concerning :Validations do
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
    
    included do
      validates :origin, presence: true, occupied_by_player: true      
    end
  end
end
