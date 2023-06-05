require "test_helper"

class BoardTest < ActiveSupport::TestCase
  test "a board's zone has a occupant and a units count" do
    board = @ongoing_game_turn_3.board
    
    zone = board.north
    assert_equal @noemie, zone.occupant
    assert_equal 2, zone.units
  end
  
  test "moving units to an empty zone" do
    board = Board.new(north: Board::Zone.new(occupant: @noemie, units: 4))
    
    board.move(3, from: :north, to: :east)
    
    assert_equal @noemie, board.north.occupant
    assert_equal 1, board.north.units
    assert_equal @noemie, board.east.occupant
    assert_equal 3, board.east.units
  end
  
  test "moving units to a zone occupied by the same player" do
    board = Board.new(
      north: Board::Zone.new(occupant: @noemie, units: 4),
      east: Board::Zone.new(occupant: @noemie, units: 2)
    )
    
    board.move(3, from: :north, to: :east)
    
    assert_equal @noemie, board.north.occupant
    assert_equal 1, board.north.units
    assert_equal @noemie, board.east.occupant
    assert_equal 5, board.east.units           # the previous units have been added
  end
  
  test "moving units to a zone occupied by another player" do
    board = Board.new(
      north: Board::Zone.new(occupant: @noemie, units: 4),
      south: Board::Zone.new(occupant: @steve, units: 2)
    )
    
    board.move(3, from: :north, to: :south)
    
    assert_equal @noemie, board.north.occupant
    assert_equal 1, board.north.units
    assert_equal @noemie, board.south.occupant # the occupant has been replaced
    assert_equal 3, board.south.units          # the previous units have been removed
  end
end
