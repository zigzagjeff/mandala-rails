class Api::V1::BaseController < ApplicationController
  allow_unauthenticated_access
  skip_forgery_protection

  before_action :authenticate_agent

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Not found" }, status: :not_found
  end

  private

  def authenticate_agent
    Current.user = User.find_by(api_token: bearer_token)
    render json: { error: "Unauthorized" }, status: :unauthorized unless Current.user
  end

  def bearer_token
    request.headers["Authorization"]&.delete_prefix("Bearer ")
  end
end
