class VerificationMailer < ApplicationMailer
  def self.verify_later(user)
    Verifications::VerifyJob.perform_later(user)
  end

  def verify(user)
    @user = user
    mail subject: "Verify your email address", to: user.email_address
  end
end
