require "test_helper"

class AttackTest < ActiveSupport::TestCase
  self.use_instantiated_fixtures = true

  test "a player cannot attack from a zone they don't occupy" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @karima, origin: :north, target: :east, units: 4, engagement: 4)
    refute attack.valid?
    assert attack.errors.of_kind? :origin, :not_occupied_by_player 
  end
  
  test "a player cannot attack an empty zone" do
    attack = Attack.new(turn: @new_two_players_game_turn_1, player: @agushi, origin: :north, target: :east, units: 1, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :target, :empty
  end

  test "a player cannot attack a zone they themselves occupy" do
    attack = Attack.new(turn: @ongoing_game_turn_3, player: @karima, origin: :south, target: :east, units: 2, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :target, :occupied_by_player
  end
    
  test "a player cannot attack a zone that is not adjacent to the origin zone" do
    skip "Zones adjacency is not implemented yet"
    
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @karima, origin: :south, target: :north, units: 2, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :target, :must_be_adjacent
  end
  
  test "a player cannot attack with more units than they have" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @karima, origin: :south, target: :east, units: 5, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :units, :less_than_or_equal_to
  end
  
  test "a player must move attack with at least 1 unit" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @karima, origin: :south, target: :east, units: 0, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :units, :greater_than_or_equal_to
  end
  
  test "a player cannot engage more units than they have in an attack" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @karima, origin: :south, target: :east, units: 3, engagement: 6)
    refute attack.valid?
    assert attack.errors.of_kind? :engagement, :less_than_or_equal_to
  end
  
  test "a player must engage at least 1 unit in an attack" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @karima, origin: :south, target: :east, units: 3, engagement: -1)
    refute attack.valid?
    assert attack.errors.of_kind? :engagement, :greater_than_or_equal_to
  end
end
