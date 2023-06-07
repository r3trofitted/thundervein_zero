class GamesMailerPreview < ActionMailer::Preview
  def error_no_participation
    game   = Game.includes(:players).last # TODO: Game.running.alst or something…
    player = Player.where.not(id: game.players.map(&:id)).first
    
    GamesMailer.with(game:, player:).error_no_participation
  end
end