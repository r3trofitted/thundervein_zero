require "test_helper"

class OrdersMailboxTest < ActionMailbox::TestCase
  test "receiving an order for an ongoing game" do
    assert_difference -> { @new_game_turn_1.orders.count } do
      receive_inbound_email_from_mail(
        to: %Q|"Thundervein Zero (#{@new_game.id})" <orders@#{@new_game.id}.example.com>|,
        from: @wyn.email_address,
        subject: "New order",
        body: <<~BODY
          Move 2 units from West to East.
        BODY
      )
    end
    
    move_order = @wyn.orders.last
    assert_kind_of Move, move_order
    assert_equal @new_game_turn_1, move_order.turn
    assert_equal "west", move_order.origin # this casting to a String is getting tedious
    assert_equal "east", move_order.target
    assert_equal 2, move_order.units
    assert move_order.received?
  end
end
