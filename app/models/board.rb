##
# Represents the board game.
#
# This is a very basic, temporary implementation. The actual board will have more than
# 4 zones, and its serialization/deserialization will probably be handed off to a 
# specific class (maybe using +ActiveRecord::Attributes+).
#
# By the same token, the adjacency of zones is hardcoded (and simplistic), which
# could also prove inadequate once the board gets more complicated.
#
# In the meantime, this is enough to start working on more exploratory stuff, 
# such as giving orders by e-mail and resolving conflits.
class Board
  include ActiveModel::AttributeAssignment
  
  attr_accessor :north, :east, :south, :west
  
  ADJACENCIES = {
    north: %i[west south],
    west: %i[north south],
    south: %i[north west east],
    east: %i[west south]
  }
  
  def self.dump(value)
    YAML.dump({
      north: { occupant_id: value.north.occupant&.id, units: value.north.units },
      east:  { occupant_id: value.east.occupant&.id, units: value.east.units },
      south: { occupant_id: value.south.occupant&.id, units: value.south.units },
      west:  { occupant_id: value.west.occupant&.id, units: value.west.units }
    })
  end
  
  def self.load(string)
    if string.present?
      data = YAML.load(string)
      Board.new data.transform_values { |hex| Hex.new(occupant: Player.find_by(id: hex[:occupant_id]), units: hex[:units]) }
    else
      Board.new
    end
  end
  
  def initialize(attributes = {})
    assign_attributes(attributes) if attributes
    
    @north ||= Hex.new(occupant: nil, units: 0)
    @east  ||= Hex.new(occupant: nil, units: 0)
    @south ||= Hex.new(occupant: nil, units: 0)
    @west  ||= Hex.new(occupant: nil, units: 0)
  end
  
  def [](zone)
    raise ArgumentError unless respond_to? zone
    
    hex = public_send(zone)
    if hex.is_a? Hex
      hex
    else
      raise ArgumentError
    end
  end
  
  def occupant_of(zone)
    self[zone].occupant
  end
  
  def units_in(zone)
    self[zone].units
  end
  
  def adjacent?(zone_a, zone_b)
    zone_b.to_sym.in? ADJACENCIES.fetch(zone_a.to_sym)
  end
  
  # Applies update(s) to the board.
  #
  # Returns a new +Board+ object, with all the updates applied.
  # (Note: the updates are _not_ checked for inconsistencies.)
  def revise(update_or_updates)
    new_hexes = Array(update_or_updates).map(&:hexes).reduce(:merge).to_h # forcing the conversion to Hash in case there are no updates
    dup.tap { |b| b. assign_attributes(new_hexes) }
  end

  # Returns the update to apply to the board following the move of units.
  # 
  # If the destination and the origin have the same occupant, the units on the 
  # destination will be kept; otherwise they will be replaced.
  def move(units, from:, to:)
    origin, target = self[from], self[to]
    kept_units_on_target = target.occupied_by?(origin.occupant) ? target.units : 0
    
    Update.new(
      "#{from}": [origin.with(units: origin.units - units), :origin],
      "#{to}":   [target.with(units: kept_units_on_target + units, occupant: origin.occupant), :target]
    )
  end
  
  # Return the update to apply to the board following the removal of units.
  #
  # (Note: instead of a number of units, the special value +:all+ can be passed 
  # to remove all the units.)
  def remove(units, from:)
    hex = self[from]
    new_units = (units == :all) ? 0 : [0, (hex.units - units)].max
    
    Update.new("#{from}": [hex.with(units: new_units, occupant: (hex.occupant unless new_units.zero?)), :origin])
  end
end
