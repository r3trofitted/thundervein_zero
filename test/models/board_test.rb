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
  
  test "removing units from a zone" do
    board = Board.new(north: Board::Zone.new(occupant: @noemie, units: 4))
    board.remove 1, from: :north
    assert_equal 3, board.north.units
    
    # it should be possible to remove more units than present (just in case)
    board = Board.new(north: Board::Zone.new(occupant: @noemie, units: 4))
    board.remove 10, from: :north
    assert_equal 0, board.north.units
  end
  
  test "removing all units from a zone removes its occupant" do
    board = Board.new(north: Board::Zone.new(occupant: @noemie, units: 4))
    board.remove 4, from: :north
    assert_equal 0, board.north.units
    assert_nil board.north.occupant
    
    board = Board.new(north: Board::Zone.new(occupant: @noemie, units: 4))
    board.remove :all, from: :north
    assert_equal 0, board.north.units
    assert_nil board.north.occupant
  end
  
  test "revising a board returns a copy with updates applied" do
    board = Board.new(
      north: Board::Zone.new(occupant: @noemie, units: 4),
      south: Board::Zone.new(occupant: @steve, units: 2)
    )
    
    updates = [
      Board::Update.new(south: [Board::Zone.new(occupant: @steve, units: 1), :origin]),
      Board::Update.new(east: [Board::Zone.new(occupant: @steve, units: 1), :target])
    ]
    revised = board.revise(updates)
    
    assert_equal @noemie, revised.north.occupant # no change
    assert_equal 4, revised.north.units          # no change
    assert_equal @steve, revised.south.occupant
    assert_equal 1, revised.south.units          # update applied
    assert_equal @steve, revised.east.occupant   # update applied
    assert_equal 1, revised.east.units           # update applied
  end
end
