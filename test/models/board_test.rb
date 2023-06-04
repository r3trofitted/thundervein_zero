require "test_helper"

class BoardTest < ActiveSupport::TestCase
  test "a board's zone has a occupant and a units count" do
    board = @ongoing_game_turn_3.board
    
    zone = board.north
    assert_equal @agushi, zone.occupant
    assert_equal 4, zone.units
  end
  
  test "applying a move order" do
    board = Board.new(north: Board::Zone.new(occupant: @odoma, units: 4))
    move  = Move.new(player: @odoma, origin: :north, target: :east, units: 3, turn: Turn.new(board: board))
    assert move.valid?
    
    board.apply_move(move)
    
    assert_equal @odoma, board.north.occupant
    assert_equal 1, board.north.units
    assert_equal @odoma, board.east.occupant
    assert_equal 3, board.east.units
  end
end
