require "test_helper"

class TurnTest < ActiveSupport::TestCase
  # TODO
  test "#orders.colliding" do
    skip "Test still to be written"
  end
  
  # TODO
  test "#orders.to_carry_out" do
    skip "Test still to be written"
  end
  
  
  test "resolving a turn creates a new turn with a duplicated board and yields it" do
    turn = @ongoing_game_turn_3
    
    turn.resolve! do |new_turn|
      assert_kind_of Turn, new_turn
      assert_equal 4, new_turn.number
      
      # TODO: add a comparison/equality method to Board?
      assert_equal new_turn.board.north, turn.board.north
      assert_equal new_turn.board.south, turn.board.south
      assert_equal new_turn.board.east, turn.board.east
      assert_equal new_turn.board.west, turn.board.west
    end
  end
  
  test "resolving a turn with move orders" do
    turn = @ongoing_game_turn_3
    
    # At the beginning of turn 3, Karima has 3 in South and 5 units in East
    south, east = turn.board.south, turn.board.east
    assert_equal @karima, south.occupant
    assert_equal 3, south.units
    assert_equal @karima, east.occupant
    assert_equal 5, east.units
    
    move = Move.create(turn: turn, player: @karima, origin: :south, target: :east, units: 2)
    
    turn.resolve! do |new_turn|
      south, east = new_turn.board.south, new_turn.board.east
      assert_equal @karima, south.occupant
      assert_equal 1, south.units
      assert_equal @karima, east.occupant
      assert_equal 7, east.units
    end

    assert move.reload.carried_out?
  end
  
  test "upon resolution, colliding moves cancel each other" do
    turn = @new_two_players_game_turn_1
    
    agushi_move = Move.create(turn: turn, player: @agushi, origin: :north, target: :west, units: 1)
    karima_move = Move.create(turn: turn, player: @karima, origin: :south, target: :west, units: 1)
    
    turn.resolve! do |new_turn|
      assert_nil new_turn.board.occupant_of(:west) # no change of occupant because the moves were canceled
      assert_equal 2, new_turn.board.units_in(:north) # no unit moved
      assert_equal 2, new_turn.board.units_in(:south) # no unit moved
    end
    
    assert agushi_move.reload.canceled?
    assert karima_move.reload.canceled?
  end
  
  test "upon resolution, colliding attacks cancel each other" do
    turn = @new_three_players_game_turn_1
        
    agushi_attack = Attack.create!(turn: turn, player: @agushi, origin: :north, target: :west, units: 2, engagement: 1)
    karima_attack = Attack.create!(turn: turn, player: @karima, origin: :south, target: :west, units: 2, engagement: 2)
    
    turn.resolve! do |new_turn|
      assert_equal @odoma, new_turn.board.occupant_of(:west) # no change of occupant because the attacks were canceled
      assert_equal 3, new_turn.board.units_in(:north) # no unit moved
      assert_equal 3, new_turn.board.units_in(:south) # no unit moved
    end
    
    assert agushi_attack.reload.canceled?
    assert karima_attack.reload.canceled?
  end
  
  test "resolving switcheroo attacks" do
    skip "TODO – see design notes in docs/notes.md"
  end
end
