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
  
  # test "a player cannot give an Order for a game they're not playing in"
  # test "Orders can only be created for ongoing games"
  # test "Orders can only be created before a turn's resolution"
  # test "a given order can only be given once"
end
