require "test_helper"

class ParticipationsMailerTest < ActionMailer::TestCase
  test "participation_confirmed" do
    email = ParticipationsMailer.with(participation: @noemie_in_new_game).participation_confirmed
    
    assert_emails(1) { email.deliver_now }
    
    assert_equal %W(arbiter@#{@new_game.id}.thundervein-0.game), email.from
    assert_equal %w(noemie@example.com), email.to
    assert_equal "You have joined game ##{@new_game.id}", email.subject
  end
end
