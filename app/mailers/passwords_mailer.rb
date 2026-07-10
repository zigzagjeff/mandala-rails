class PasswordsMailer < ApplicationMailer
  def self.reset_later(email_address)
    Passwords::ResetJob.perform_later(email_address)
  end

  def reset(user)
    @user = user
    mail subject: "Reset your password", to: user.email_address
  end
end
