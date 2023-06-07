require "test_helper"

class OrdersMailboxTest < ActionMailbox::TestCase
  include ActionMailer::TestHelper
  
  test "receiving an order for an ongoing game" do
    # an order is created
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
    
    # the created order is correct
    move_order = @wyn.orders.last
    assert_kind_of Move, move_order
    assert_equal @new_game_turn_1, move_order.turn
    assert_equal "west", move_order.origin # this casting to a String is getting tedious
    assert_equal "east", move_order.target
    assert_equal 2, move_order.units
    assert move_order.received?
    
    # a confirmation email is sent
    assert_enqueued_email_with OrdersMailer, :confirmation, args: { order: move_order }
  end
  
  test "receiving an order by an unknown player" do
    inbound_email = receive_inbound_email_from_mail to: "orders@#{@new_game.id}.example.com", from: "unknown@example.com"
    assert inbound_email.bounced?
  end
  
  test "receiving an order for a wrong game" do
    inbound_email = receive_inbound_email_from_mail to: %"orders@#{@new_game.id}.example.com", from: @eisha.email_address
    
    assert inbound_email.bounced?
    assert_enqueued_email_with GamesMailer, :error_no_participation, args: [@new_game, @eisha]
  end
end
