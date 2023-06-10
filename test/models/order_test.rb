require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "building an Order from a text" do
    order = Order.from_text "Move 2 units from North to South"
    
    assert_instance_of Move, order
    assert_equal 2, order.units
    assert_equal "north", order.origin
    assert_equal "south", order.target
    
    # Capitalization is not an issue
    order = Order.from_text "attack with 3 Units from west to South"
    
    assert_instance_of Attack, order
    assert_equal 3, order.units
    assert_equal "west", order.origin
    assert_equal "south", order.target
  end
  
  test "invalid if the player is not a participant in the related game" do
    order = Order.new turn: @new_game.current_turn, player: @eisha
    
    refute order.valid?
    assert order.errors.of_kind? :base, :player_not_participating
  end
  
  test "invalid if the turn's resolution is in progress" do
    turn  = @ongoing_game_turn_3
    turn.resolution_in_progress!
    
    order = Order.new turn: turn, player: @noemie
    
    refute order.valid?
    assert order.errors.of_kind? :base, :turn_resolution_in_progress
  end
  
  test "invalid if an other order has already been given this turn" do
    turn = @ongoing_game.turns.find_by(number: 2)
    
    order = Order.new turn: turn, player: @noemie
    
    refute order.valid?
    assert order.errors.of_kind? :base, :order_already_given
  end
end
