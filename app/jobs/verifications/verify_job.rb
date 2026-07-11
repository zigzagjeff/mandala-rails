class Verifications::VerifyJob < ApplicationJob
  # Takes the user directly, unlike Passwords::ResetJob which takes an email
  # address: signup already holds the record, so there is no enumeration-safe
  # lookup to defer off the request — only the mail send.
  def perform(user)
    VerificationMailer.verify(user).deliver_now
  end
end
