##
# Represents the board game.
#
# This is a very basic, temporary implementation. The actual board will have more than
# 4 zones, and its serialization/deserialization will probably be handed off to a 
# specific class (maybe using +ActiveRecord::Attributes+).
#
# Eventually, the Board class should also cover the _adjacency_ of zones.
#
# In the meantime, this is enough to start working on more exploratory stuff, 
# such as giving orders by e-mail and resolving conflits.
class Board
  include ActiveModel::AttributeAssignment
  
  attr_accessor :north, :east, :south, :west
  
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
  
  def move(units, from:, to:)
    origin, target = self[from], self[to]
    
    public_send "#{from}=", origin.with(units: origin.units - units)
    public_send "#{to}=", target.with(units: target.units + units, occupant: origin.occupant)
  end
  
  ##
  # Represents a zone on the board. A zone can be occupied (by a Player) and have units.
  #
  # (Note: I'm using Data here simply to try this new feature out; at the moment, 
  # I'm not convinced that the immutability it offers over Struct is worth 
  # anything here, but we'll see…)
  Zone = Data.define :occupant, :units
end
