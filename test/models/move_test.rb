require "test_helper"

class MoveTest < ActiveSupport::TestCase
  test "a player cannot declare a move from a zone they don't occupy" do
    move = Move.new(turn: @new_two_players_game_turn_1, player: @agushi, origin: :south, target: :east, units: 1) # the South zone is occupied by Karima, not Agushi
    refute move.valid?
    assert move.errors.of_kind? :origin, :not_occupied_by_player 
  end
  
  test "a player can move to an empty zone" do
    move = Move.new(turn: @new_two_players_game_turn_1, player: @agushi, origin: :north, target: :east, units: 1)
    assert move.valid?
  end
  
  test "a player can move to a zone they already occupy" do
    move = Move.new(turn: @ongoing_game_turn_3, player: @karima, origin: :east, target: :south, units: 4)
    assert move.valid?
  end
  
  test "a player cannot move to a zone already occupied by another player" do
    move = Move.new(turn: @ongoing_game_turn_3, player: @karima, origin: :east, target: :north, units: 4) # North is occupied by Agushi
    refute move.valid?
    assert move.errors.of_kind? :target, :occupied
  end
    
  test "a player can not move to a zone that is not adjacent to the target zone" do
    skip "Zones adjacency is not implemented yet"
    
    move = Move.new(turn: @new_two_players_game_turn_1, player: @agushi, origin: :north, target: :west, units: 1)
    refute move.valid?
    assert move.errors.of_kind? :target, :must_be_adjacent
  end

  test "a player cannot move more units than they have minus 1" do
    move = Move.new(turn: @new_two_players_game_turn_1, player: @agushi, origin: :north, target: :east, units: 2)
    refute move.valid?
    assert move.errors.of_kind? :units, :less_than
  end
  
  test "a player must move at least 1 unit" do
    move = Move.new(turn: @new_two_players_game_turn_1, player: @agushi, origin: :north, target: :east, units: 0)
    refute move.valid?
    assert move.errors.of_kind? :units, :greater_than_or_equal_to

    # special case for negative values (some players are sneaky)
    move = Move.new(turn: @new_two_players_game_turn_1, player: @agushi, origin: :north, target: :east, units: -2)
    refute move.valid?
    assert move.errors.of_kind? :units, :greater_than_or_equal_to
  end
end
