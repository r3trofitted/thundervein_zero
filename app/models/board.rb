##
# Represents the board game.
#
# This is a very basic, temporary implementation. The actual board will have more than
# 4 zones, and its serialization/deserialization will probably be handed off to a 
# specific class (maybe using +ActiveRecord::Attributes+).
#
# By the same token, the adjacency of zones is hardcoded (and simplistic), which
#  could also prove inadequate once the board gets more complicated.
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
      Board.new data.transform_values { |zone| Zone.new(occupant: Player.find_by(id: zone[:occupant_id]), units: zone[:units]) }
    else
      Board.new
    end
  end
  
  def initialize(attributes = {})
    assign_attributes(attributes) if attributes
    
    @north ||= Zone.new(occupant: nil, units: 0)
    @east  ||= Zone.new(occupant: nil, units: 0)
    @south ||= Zone.new(occupant: nil, units: 0)
    @west  ||= Zone.new(occupant: nil, units: 0)
  end
  
  def [](zone_name)
    raise ArgumentError unless respond_to? zone_name
    
    zone = public_send(zone_name)
    if zone.is_a? Zone
      zone
    else
      raise ArgumentError
    end
  end
  
  def occupant_of(zone_name)
    self[zone_name].occupant
  end
  
  def units_in(zone_name)
    self[zone_name].units
  end
  
  def adjacent?(a, b)
    b.to_sym.in? ADJACENCIES.fetch(a.to_sym)
  end
  
  def revise(update_or_updates)
    new_zones = Array(update_or_updates).map(&:zones).reduce(:merge).to_h # forcing the conversion to Hash in case there are no updates
    dup.tap { |b| b. assign_attributes(new_zones) }
  end

  def update_for_move(units, from:, to:)
    origin, target = self[from], self[to]
    kept_units_on_target = target.occupied_by?(origin.occupant) ? target.units : 0
    
    Update.new(
      "#{from}": [origin.with(units: origin.units - units), :origin],
      "#{to}":   [target.with(units: kept_units_on_target + units, occupant: origin.occupant), :target]
    )
  end
  
  def update_for_remove(units, from:)
    zone = self[from]
    new_units = (units == :all) ? 0 : [0, (zone.units - units)].max
    
    Update.new("#{from}": [zone.with(units: new_units, occupant: (zone.occupant unless new_units.zero?)), :origin])
  end
  
  def move(units, from:, to:)
    origin, target = self[from], self[to]
    kept_units_on_target = target.occupied_by?(origin.occupant) ? target.units : 0
    
    public_send "#{from}=", origin.with(units: origin.units - units)
    public_send "#{to}=", target.with(units: kept_units_on_target + units, occupant: origin.occupant)
  end
  
  def remove(units, from:)
    zone = self[from]
    new_units = (units == :all) ? 0 : [0, (zone.units - units)].max
    public_send "#{from}=", zone.with(units: new_units, occupant: (zone.occupant unless new_units.zero?))
  end
end
