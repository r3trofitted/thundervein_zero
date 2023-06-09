module Commands
  class JoinGame < Command
    def initialize(game:, email_address:, name:)
      @game   = game
      @player = Player.find_or_initialize_by(email_address:).tap { |p| p.name ||= name }
    end
    
    def do_execute
      @game.players << @player
    end
  end
end
