class ParticipationsMailer < ApplicationMailer
  before_action { @participation = params[:participation] }

  default from: -> { @participation.game.arbiter_email_address },
          to:   -> { @participation.player.email_address }

  def participation_confirmed
    mail subject: "You have joined game ##{@participation.game_id}"
  end
end
