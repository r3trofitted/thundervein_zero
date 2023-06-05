require "test_helper"

class AttackTest < ActiveSupport::TestCase
  test "a player cannot attack from a zone they don't occupy" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @steve, origin: :north, target: :east, units: 4, engagement: 4)
    refute attack.valid?
    assert attack.errors.of_kind? :origin, :not_occupied_by_player 
  end
  
  test "a player cannot attack an empty zone" do
    attack = Attack.new(turn: @new_game_turn_1, player: @steve, origin: :south, target: :east, units: 1, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :target, :empty
  end

  test "a player cannot attack a zone they themselves occupy" do
    attack = Attack.new(turn: @ongoing_game_turn_3, player: @noemie, origin: :north, target: :west, units: 2, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :target, :occupied_by_player
  end
    
  test "a player cannot attack a zone that is not adjacent to the origin zone" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @noemie, origin: :north, target: :east, units: 2, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :target, :must_be_adjacent
  end
  
  test "a player cannot attack with more units than they have" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @steve, origin: :south, target: :east, units: 5, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :units, :less_than_or_equal_to
  end
  
  test "a player must move attack with at least 1 unit" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @steve, origin: :south, target: :east, units: 0, engagement: 1)
    refute attack.valid?
    assert attack.errors.of_kind? :units, :greater_than_or_equal_to
  end
  
  test "a player cannot engage more units than they have in an attack" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @steve, origin: :south, target: :east, units: 3, engagement: 6)
    refute attack.valid?
    assert attack.errors.of_kind? :engagement, :less_than_or_equal_to
  end
  
  test "a player must engage at least 1 unit in an attack" do
    attack = Attack.new(turn: @ongoing_game_turn_1, player: @steve, origin: :south, target: :east, units: 3, engagement: -1)
    refute attack.valid?
    assert attack.errors.of_kind? :engagement, :greater_than_or_equal_to
  end
  
  test "an attack is pending if the defender hasn't given a guess yet" do
    assert Attack.new(guess: nil).pending?
    refute Attack.new(guess: 3).pending?
  end
  
  test "an attack is successful if the guess is not equal to the engagement, failed otherwise (unless it's pending)" do
    assert Attack.new(engagement: 2, guess: 1).successful?
    refute Attack.new(engagement: 2, guess: 2).successful?
    refute Attack.new(engagement: 2, guess: nil).successful?
    
    assert Attack.new(engagement: 2, guess: 2).failed?
    refute Attack.new(engagement: 2, guess: 1).failed?
    refute Attack.new(engagement: 2, guess: nil).failed?
  end
  
  test "an attack is all-in if all the units from the origin are used" do
    assert Attack.new(turn: @ongoing_game_turn_1, origin: :south, units: 4).all_in?
    refute Attack.new(turn: @ongoing_game_turn_1, origin: :south, units: 3).all_in?
  end
  
  test "resolving a successful attack" do
    attack = Attack.new(turn: @new_game_turn_1, player: @noemie, origin: :north, target: :west, units: 2, engagement: 2, guess: 1)
    
    board_updates = attack.resolve
    
    assert_equal 2, board_updates.size
    assert_equal [Board::Zone.new(occupant: @noemie, units: 1), :origin], board_updates[:north]
    assert_equal [Board::Zone.new(occupant: @noemie, units: 2), :target], board_updates[:west]
  end
  
  test "resolving a successful all-in attack" do
    attack = Attack.new(turn: @new_game_turn_1, player: @noemie, origin: :north, target: :west, units: 3, engagement: 2, guess: 1)
    
    board_updates = attack.resolve
    
    assert_equal 1, board_updates.size
    assert_equal [Board::Zone.new(occupant: nil, units: 0), :origin], board_updates[:west]
  end
    
  test "resolving an unsuccessful attack" do
    attack = Attack.new(turn: @new_game_turn_1, player: @noemie, origin: :north, target: :west, units: 2, engagement: 2, guess: 2)
    
    board_updates = attack.resolve
    
    assert_equal 1, board_updates.size
    assert_equal [Board::Zone.new(occupant: @noemie, units: 1), :origin], board_updates[:north]
  end
    
  test "resolving an unsuccessful all-in attack" do
    attack = Attack.new(turn: @new_game_turn_1, player: @noemie, origin: :north, target: :west, units: 3, engagement: 3, guess: 3)
    
    board_updates = attack.resolve
    
    assert_equal 1, board_updates.size
    assert_equal [Board::Zone.new(occupant: nil, units: 0), :origin], board_updates[:north]
  end
end
