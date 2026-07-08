class Api::V1::EventsController < Api::V1::BaseController
  rescue_from ArgumentError do
    render json: { errors: [ "since must be an ISO 8601 time" ] }, status: :bad_request
  end

  def index
    @chart = Current.user.charts.find(params[:chart_id])
    @events = @chart.events.since(since).chronologically
  end

  private

  def since
    Time.iso8601(params[:since]) if params[:since].present?
  end
end
