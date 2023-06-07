require "test_helper"

class OrdersMailerTest < ActionMailer::TestCase
  test "error_no_participation" do
    mail = OrdersMailer.error_no_participation
    assert_equal "Error no participation", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
