class ParticipationsMailerPreview < ActionMailer::Preview
  def participation_confirmed
    ParticipationsMailer.with(participation: Participation.first).participation_confirmed
  end
end
