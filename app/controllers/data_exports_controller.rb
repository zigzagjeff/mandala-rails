class DataExportsController < ApplicationController
  def show
    send_data User::Export.new(Current.user).export_json,
      filename: "mandala-export-#{Date.current.iso8601}.json",
      type: :json,
      disposition: "attachment"
  end
end
