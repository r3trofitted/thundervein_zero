class Command
  # include ActiveModel::Validations
  
  attr_reader :game
  
  def self.from_mail(mail, game:)
    case mail.subject
    when /^join$/i
      Commands::JoinGame.new game:, email_address: mail.from_address.address, name: mail.from_address.display_name
    when /^(move|attack|order)$/i
      player = Player.find_by email_address: mail.from
      
      Commands::ReceiveOrder.new game:, player:, message: mail.body.to_s
    end
  end
  
  def execute
    # begin
      # validate!
      do_execute
    # rescue ActiveModel::ValidationError
      # false
    # end
  end
  
  def errors
    
  end
end
