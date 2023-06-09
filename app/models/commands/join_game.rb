module Commands
  class JoinGame < Command
    def initialize(game:, email_address:, name:)
      player = Player.find_or_initialize_by(email_address:).tap { |p| p.name ||= name }
      
      @participation = game.participations.build(player: player)
    end
    
    def do_execute
      @participation.save
    end
    
    def errors
      @participation.errors.group_by_attribute.transform_values { |es| es.map &:type }
    end
  end
end
