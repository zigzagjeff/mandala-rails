class Api::V1::BaseController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection

  # The IP allowance sits above the token allowance so the token budget is the
  # one a legitimate single-address agent feels; the IP bucket exists to slow
  # token guessing, which never presents a valid token.
  rate_limit to: 60, within: 1.minute, name: "token", by: -> { bearer_token.to_s }, with: :reject_too_many_requests
  rate_limit to: 120, within: 1.minute, name: "ip", with: :reject_too_many_requests

  before_action :authenticate_agent

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  private

  def reject_too_many_requests
    render json: { error: "Too many requests" }, status: :too_many_requests
  end

  def authenticate_agent
    Current.user = User.find_by(api_token: bearer_token)
    render json: { error: "Unauthorized" }, status: :unauthorized unless Current.user
  end

  def bearer_token
    request.headers["Authorization"]&.delete_prefix("Bearer ")
  end
end
