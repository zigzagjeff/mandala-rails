class ClosureMailer < ApplicationMailer
  def self.scheduled_later(user)
    Closures::ScheduledJob.perform_later(user)
  end

  def scheduled(user)
    @user = user
    mail subject: "Your Mandala account is scheduled for deletion", to: user.email_address
  end
end
