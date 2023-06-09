module Commands
  class ReceiveOrder < Command
    attr_reader :player
    # validates_presence_of :player
    # validate :player_is_a_participant
    
    def initialize(game:, player:, message:)
      # @game, @player = game, player
      @player = player
      
      @order = Order.from_text(message) do |o|
        o.player = player
        o.turn   = game.current_turn
      end
    end
    
    def do_execute
      @order.save
    end
    
    def errors
      @order.errors.group_by_attribute.transform_values { |es| es.map &:type }
    end
    
    # private
    
    # # SMELL: we're basically validating _the _Order_ here.
    # def player_is_a_participant
    #   errors.add(:player, :must_be_a_participant) unless @player.in? @game.players
    # end
  end
end
