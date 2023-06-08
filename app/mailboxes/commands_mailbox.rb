class CommandsMailbox < ApplicationMailbox
  MATCHER = /^arbiter@(\d+)?/i # e.g. arbiter@123456.thundervein-0.game for game 123456
  
  def process
    # SLIME
    game.add_participant name: mail.from_address.display_name, email_address: mail.from_address.address
  end
  
  # SMELL: the same methods exists in OrdersMailbox
  def game
    @game ||= begin
      if game_id = mail.to.grep(MATCHER) { $1 } # finds the first matching address and returns the captured group
        Game.find_by(id: game_id)
      end
    end
  end
end
