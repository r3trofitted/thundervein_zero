require "test_helper"

class CommandsMailboxTest < ActionMailbox::TestCase
  include ActionMailer::TestHelper
  
  test "joining a game" do
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
    
    assert_enqueued_email_with GamesMailer, :participation, args: { game: game, player: nigel }
  end
end
