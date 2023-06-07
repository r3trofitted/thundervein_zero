require "test_helper"

class BoardTest < ActiveSupport::TestCase
  test "a board's tile has a occupant and a units count" do
    board = @ongoing_game_turn_3.board
    
    tile = board.north
    assert_equal @noemie, tile.occupant
    assert_equal 2, tile.units
  end
  
  test "moving units to an empty zone" do
    board = Board.new(north: Board::Tile.new(occupant: @noemie, units: 4))
    
    update = board.move(3, from: :north, to: :east)
    tiles  = update.tiles
    
    assert_equal @noemie, tiles[:north].occupant
    assert_equal 1, tiles[:north].units
    assert_equal @noemie, tiles[:east].occupant
    assert_equal 3, tiles[:east].units
    assert update.origin_in?(:north)
  end
  
  test "moving units to a tile occupied by the same player" do
    board = Board.new(
      north: Board::Tile.new(occupant: @noemie, units: 4),
      east: Board::Tile.new(occupant: @noemie, units: 2)
    )
    
    update = board.move(3, from: :north, to: :east)
    tiles  = update.tiles
    
    assert_equal @noemie, tiles[:north].occupant
    assert_equal 1, tiles[:north].units
    assert_equal @noemie, tiles[:east].occupant
    assert_equal 5, tiles[:east].units # the previous units have been added
    assert update.origin_in?(:north)
  end
  
  test "moving units to a tile occupied by another player" do
    board = Board.new(
      north: Board::Tile.new(occupant: @noemie, units: 4),
      south: Board::Tile.new(occupant: @steve, units: 2)
    )
    
    update = board.move(3, from: :north, to: :south)
    tiles  = update.tiles
    
    assert_equal @noemie, tiles[:north].occupant
    assert_equal 1, tiles[:north].units
    assert_equal @noemie, tiles[:south].occupant # the occupant has been replaced
    assert_equal 3, tiles[:south].units          # the previous units have been removed
    assert update.origin_in?(:north)
  end
  
  test "removing units from a tile" do
    board = Board.new(north: Board::Tile.new(occupant: @noemie, units: 4))
    update = board.remove(1, from: :north)
    assert_equal 3, update.tiles[:north].units
    assert update.origin_in?(:north)
    
    # it should be possible to remove more units than present (just in case)
    board = Board.new(north: Board::Tile.new(occupant: @noemie, units: 4))
    update = board.remove(10, from: :north)
    assert_equal 0, update.tiles[:north].units
  end
  
  test "removing all units from a tile removes its occupant" do
    board = Board.new(north: Board::Tile.new(occupant: @noemie, units: 4))
    update = board.remove(4, from: :north)
    assert_equal 0, update.tiles[:north].units
    assert_nil update.tiles[:north].occupant
    
    # using the :all special value
    board = Board.new(north: Board::Tile.new(occupant: @noemie, units: 4))
    update = board.remove(:all, from: :north)
    assert_equal 0, update.tiles[:north].units
    assert_nil update.tiles[:north].occupant
  end
  
  test "revising a board returns a copy with updates applied" do
    board = Board.new(
      north: Board::Tile.new(occupant: @noemie, units: 4),
      south: Board::Tile.new(occupant: @steve, units: 2)
    )
    
    updates = [
      Board::Update.new(south: [Board::Tile.new(occupant: @steve, units: 1), :origin]),
      Board::Update.new(east: [Board::Tile.new(occupant: @steve, units: 1), :target])
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
