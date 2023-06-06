require "test_helper"

class TurnTest < ActiveSupport::TestCase
  test "#orders.colliding and #orders.to_carry_out" do
    t = @new_game_turn_1
    colliding_order_1 = Attack.create! turn: t, player: @noemie, origin: :north, target: :west, units: 1, engagement: 1
    colliding_order_2 = Attack.create! turn: t, player: @steve, origin: :south, target: :west, units: 1, engagement: 1
    valid_order       = Move.create! turn: t, player: @wyn, origin: :west, target: :east, units: 1
    
    colliding_orders = t.orders.colliding
    assert_includes colliding_orders, colliding_order_1
    assert_includes colliding_orders, colliding_order_2 
    refute_includes colliding_orders, valid_order
    
    orders_to_carry_out = t.orders.to_carry_out
    refute_includes orders_to_carry_out, colliding_order_1
    refute_includes orders_to_carry_out, colliding_order_2 
    assert_includes orders_to_carry_out, valid_order
  end
  
  test "resolving a finished turn raises an error" do
    assert_raises(Turn::FinishedTurn) { @ongoing_game_turn_1.resolve! }
  end
  
  test "resolving a turn creates a new turn and yields it" do
    turn = @ongoing_game_turn_3
    
    turn.resolve! do |new_turn|
      assert_kind_of Turn, new_turn
      assert_equal 4, new_turn.number
      refute new_turn.status?
    end
  end
  
  test "when resolving a turn, the new turn has a copy of the board" do
    turn = @ongoing_game_turn_3
    
    turn.resolve! do |new_turn|
      # TODO: add a comparison/equality method to Board?
      assert_equal new_turn.board.north, turn.board.north
      assert_equal new_turn.board.south, turn.board.south
      assert_equal new_turn.board.east, turn.board.east
      assert_equal new_turn.board.west, turn.board.west
    end
  end
  
  test "resolving a turn with move orders" do
    turn = @ongoing_game_turn_3
    
    # At the beginning of turn 3, Noemie has 2 in North and 2 units in West
    north, west = turn.board.north, turn.board.west
    assert_equal @noemie, north.occupant
    assert_equal 2, north.units
    assert_equal @noemie, west.occupant
    assert_equal 2, west.units
    
    move = Move.create(turn: turn, player: @noemie, origin: :west, target: :north, units: 1)
    
    turn.resolve! do |new_turn|
      north, west = new_turn.board.north, new_turn.board.west
      assert_equal @noemie, north.occupant
      assert_equal 3, north.units
      assert_equal @noemie, west.occupant
      assert_equal 1, west.units
    end

    assert move.reload.carried_out?
  end
  
  test "upon resolution, colliding moves cancel each other" do
    turn = @new_game_turn_1
    
    wyn_move  = Move.create(turn: turn, player: @wyn, origin: :west, target: :east, units: 1)
    steve_move = Move.create(turn: turn, player: @steve, origin: :south, target: :east, units: 1)
    
    turn.resolve! do |new_turn|
      assert_nil new_turn.board.occupant_of(:east) # no change of occupant because the moves were canceled
      assert_equal 3, new_turn.board.units_in(:west) # no unit moved
      assert_equal 3, new_turn.board.units_in(:south) # no unit moved
    end
    
    assert wyn_move.reload.canceled?
    assert steve_move.reload.canceled?
  end
  
  test "upon resolution, colliding attacks cancel each other" do
    turn = @new_game_turn_1
        
    noemie_attack = Attack.create!(turn: turn, player: @noemie, origin: :north, target: :west, units: 2, engagement: 1, guess: 1)
    steve_attack = Attack.create!(turn: turn, player: @steve, origin: :south, target: :west, units: 2, engagement: 2, guess: 2)
    
    turn.resolve! do |new_turn|
      assert_equal @wyn, new_turn.board.occupant_of(:west) # no change of occupant because the attacks were canceled
      assert_equal 3, new_turn.board.units_in(:north) # no unit moved
      assert_equal 3, new_turn.board.units_in(:south) # no unit moved
    end
    
    assert noemie_attack.reload.canceled?
    assert steve_attack.reload.canceled?
  end
  
  test "resolving a turn with a pending attack" do
    turn = @new_game_turn_1
    
    attack = Attack.create! turn: turn, player: @noemie, origin: :north, target: :west, units: 2, engagement: 1
    
    refute turn.resolve!
    assert turn.resolution_in_progress?
  end
  
  test "resolving a turn with a successful attack" do
    turn = @new_game_turn_1
    
    attack = Attack.create! turn: turn, player: @noemie, origin: :north, target: :west, units: 2, engagement: 1, guess: 2
    
    turn.resolve! do |new_turn|
      assert_equal @noemie, new_turn.board.occupant_of(:west)
      assert_equal 2, new_turn.board.units_in(:west)  # 2 units used for the attack
      assert_equal 1, new_turn.board.units_in(:north) # 1 unit left behind
    end
    assert attack.reload.carried_out?
    assert turn.finished?
  end
  
  test "resolving a turn with an unsuccessful attack" do
    turn = @new_game_turn_1
    
    attack = Attack.create! turn: turn, player: @noemie, origin: :north, target: :west, units: 2, engagement: 1, guess: 1
    
    turn.resolve! do |new_turn|
      assert_equal @wyn, new_turn.board.occupant_of(:west)
      assert_equal 3, new_turn.board.units_in(:west)  # no casualties for the defender
      assert_equal 2, new_turn.board.units_in(:north) # one attacking unit lost, the other fell back to North
    end
    assert attack.reload.carried_out?
    assert turn.finished?
  end
  
  # TODO
  test "resolving switcheroo attacks" do
    turn = @new_game_turn_1
    
    noemie_attack = Attack.create! turn: turn, player: @noemie, origin: :north, target: :west, units: 2, engagement: 2, guess: 1
    wyn_attack    = Attack.create! turn: turn, player: @wyn, origin: :west, target: :north, units: 2, engagement: 2, guess: 1
    
    turn.resolve! do |new_turn|
      assert_equal @wyn, new_turn.board.occupant_of(:north)
      assert_equal @noemie, new_turn.board.occupant_of(:west)
      assert_equal 2, new_turn.board.units_in(:north) # Wyn has moved to units to North
      assert_equal 2, new_turn.board.units_in(:west)  # Noémie has moved to units to West
    end
    
    assert noemie_attack.reload.carried_out?
    assert wyn_attack.reload.carried_out?
    assert turn.finished?
  end
  
  # TODO
  test "resolving chained attacks" do
    turn = @new_game_turn_1
    
    noemie_attack = Attack.create! turn: turn, player: @noemie, origin: :north, target: :west, units: 2, engagement: 2, guess: 1
    wyn_attack    = Attack.create! turn: turn, player: @wyn, origin: :west, target: :south, units: 2, engagement: 2, guess: 1
    steve_attack  = Attack.create! turn: turn, player: @steve, origin: :south, target: :north, units: 2, engagement: 2, guess: 1
    
    turn.resolve! do |new_turn|
      assert_equal @noemie, new_turn.board.occupant_of(:west)
      assert_equal @wyn, new_turn.board.occupant_of(:south)
      assert_equal @steve, new_turn.board.occupant_of(:north)
      assert_equal 2, new_turn.board.units_in(:west)
      assert_equal 2, new_turn.board.units_in(:south)
      assert_equal 2, new_turn.board.units_in(:north)
    end
    
    assert noemie_attack.reload.carried_out?
    assert wyn_attack.reload.carried_out?
    assert steve_attack.reload.carried_out?
    assert turn.finished?
  end
end
