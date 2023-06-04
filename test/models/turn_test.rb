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
end
