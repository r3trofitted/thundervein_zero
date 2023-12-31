require "test_helper"

class CommandsMailboxTest < ActionMailbox::TestCase
  include ActionMailer::TestHelper
  
  # These tests are like integration tests, since they cover side-effects (such 
  # as the sending of a confirmation email).
  # TODO: turn into actual integration tests, inheriting from +ActionDispatch::IntegrationTest+?
  test "integration: receiving an order for an ongoing game" do
    # an order is created
    assert_difference -> { @new_game_turn_1.orders.count } do
      receive_inbound_email_from_fixture "valid_order.eml"
    end
    
    # the created order is correct
    move_order = @wyn.orders.last
    assert_kind_of Move, move_order
    assert_equal @new_game_turn_1, move_order.turn
    assert_equal "west", move_order.origin # TODO: this casting to a String is getting tedious
    assert_equal "east", move_order.target
    assert_equal 2, move_order.units
    assert move_order.received?
    
    # a confirmation email is sent
    assert_enqueued_email_with OrdersMailer, :confirmation, params: { order: move_order }
  end
  
  test "integration: joining a game" do
    game = Game.create!
    
    assert_difference -> { game.players.count } do
      receive_inbound_email_from_mail(
        from: "Nigel Newcomer <nigel@example.com>",
        to: "arbiter@#{game.id}.example.com",
        subject: "Join"
      )
    end
    
    nigel = game.players.first
    assert_equal "Nigel Newcomer", nigel.name
    assert_equal "nigel@example.com", nigel.email_address
    
    assert_enqueued_email_with ParticipationsMailer, :participation_confirmed, params: { participation: nigel.participations.find_by(game: game) }
  end
  
  test "receiving a command with an non-existent game id" do
    assert receive_inbound_email_from_mail(to: "command@123.example.com").bounced?
  end

  test "receiving an order for a wrong game" do
    ActionMailer::Base.deliveries.clear
    
    inbound_email = receive_inbound_email_from_mail to: "arbiter@#{@new_game.id}.example.com", from: @eisha.email_address, subject: "order"
    
    assert inbound_email.bounced?
    assert_emails 1 # we cannot look more closely into the email sent, unfortunately
  end
end
