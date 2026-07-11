class EmailVerificationsController < ApplicationController
  allow_unauthenticated_access only: %i[ show update ]
  before_action :set_user_by_token, only: %i[ show update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to root_path, alert: "Try again later." }

  def show
  end

  def update
    @user.verify
    redirect_to root_path, notice: "Your email address has been verified."
  end

  def create
    VerificationMailer.verify_later Current.user
    redirect_to root_path, notice: "Verification email sent."
  end

  private
    def set_user_by_token
      @user = User.find_by_email_verification_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to root_path, alert: "Email verification link is invalid or has expired."
    end
end
