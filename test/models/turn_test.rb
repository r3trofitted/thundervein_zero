require "test_helper"

class TurnTest < ActiveSupport::TestCase
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
    
    turn.orders << Move.new(player: @karima, origin: :south, target: :east, units: 2)
    turn.resolve! do |new_turn|
      south, east = new_turn.board.south, new_turn.board.east
      assert_equal @karima, south.occupant
      assert_equal 1, south.units
      assert_equal @karima, east.occupant
      assert_equal 7, east.units
    end
  end
end
