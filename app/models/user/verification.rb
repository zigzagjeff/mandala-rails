module User::Verification
  extend ActiveSupport::Concern

  EMAIL_VERIFICATION_PERIOD = 2.days

  included do
    generates_token_for :email_verification, expires_in: EMAIL_VERIFICATION_PERIOD do
      email_address
    end
  end

  class_methods do
    def find_by_email_verification_token!(token)
      find_by_token_for!(:email_verification, token)
    end
  end

  def email_verification_token
    generate_token_for(:email_verification)
  end

  def email_verification_token_expires_in
    EMAIL_VERIFICATION_PERIOD
  end

  def verify
    update!(verified_at: Time.current) unless verified?
  end

  def verified?
    verified_at.present?
  end

  def unverified?
    !verified?
  end
end
