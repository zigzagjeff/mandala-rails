class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  rate_limit to: 10, within: 3.minutes, name: "ip", only: :create, with: :redirect_to_throttled
  rate_limit to: 5, within: 15.minutes, name: "account", by: -> { params[:email_address].to_s.strip.downcase }, only: :create, with: :redirect_to_throttled

  def new
  end

  # Enqueue unconditionally and let the job look the user up: finding the user
  # here would leak which emails exist, both by timing and by the row the queue
  # insert writes only on a hit.
  def create
    PasswordsMailer.reset_later(params[:email_address])
    redirect_to new_session_path, notice: "Password reset instructions sent (if user with that email address exists)."
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Password has been reset."
    else
      redirect_to edit_password_path(params[:token]), alert: @user.errors.full_messages.to_sentence
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end

    def redirect_to_throttled
      redirect_to new_password_path, alert: "Try again later."
    end
end
