class Passwords::ResetJob < ApplicationJob
  def perform(email_address)
    if user = User.find_by(email_address: email_address)
      PasswordsMailer.reset(user).deliver_now
    end
  end
end
