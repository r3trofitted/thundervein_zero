require "test_helper"

class ArbiterTest < ActiveSupport::TestCase
  test "parsing a command" do
    assert Arbiter.parse_command("move").order?
    assert Arbiter.parse_command("attack").order?
    assert Arbiter.parse_command("order").order?
    assert Arbiter.parse_command("join").join?
    
    assert Arbiter.parse_command("Move").order?
    assert Arbiter.parse_command("ATTACK").order?
    assert Arbiter.parse_command("oRdeR").order?
    assert Arbiter.parse_command("JOin").join?
  end
end
