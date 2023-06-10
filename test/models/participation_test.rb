require "test_helper"

class ParticipationTest < ActiveSupport::TestCase
  test "creating a participation and a player at the same time" do
    game = Game.new
    participation = Participation.new game: game, player_attributes: { email_address: "zoe@example,com", name: "Zoé" }
    
    assert_difference -> { Player.count } do
      participation.save!
    end
    
    zoe = Player.last
    assert_equal "zoe@example,com", zoe.email_address
    assert_equal "Zoé", zoe.name
  end
  
  test "invalid if the game is already started" do
    participation = Participation.new game: @ongoing_game, player: @eisha
    
    refute participation.valid?
    assert participation.errors.of_kind? :base, :game_already_started
  end
  
  test "invalid is the is game already full" do
    game = Game.create(players: [@noemie, @steve], max_players: 2)
    
    participation = Participation.new game: game, player: @wyn
    
    refute participation.valid?
    assert participation.errors.of_kind? :base, :game_already_full
  end
  
  test "invalid if the player is already a participant in the game" do
    game = Game.create(players: [@noemie, @steve])
  
    participation = Participation.new game: game, player: @noemie
    
    refute participation.valid?
    assert participation.errors.of_kind? :base, :player_already_participating
  end
end
