require "test_helper"

class Api::V1::BaseControllerTest < ActionDispatch::IntegrationTest
  test "a token exhausting its budget is refused even across addresses" do
    60.times do |i|
      get api_v1_mandalas_path, headers: authorized_headers.merge("REMOTE_ADDR" => "10.0.0.#{i}")
      assert_response :success
    end

    get api_v1_mandalas_path, headers: authorized_headers.merge("REMOTE_ADDR" => "10.0.1.1")

    assert_response :too_many_requests
    assert_equal "Too many requests", response.parsed_body["error"]
  end

  test "an address guessing tokens is refused even with a fresh token each try" do
    120.times do |i|
      get api_v1_mandalas_path, headers: { "Authorization" => "Bearer guess-#{i}" }
      assert_response :unauthorized
    end

    get api_v1_mandalas_path, headers: { "Authorization" => "Bearer guess-final" }

    assert_response :too_many_requests
    assert_equal "Too many requests", response.parsed_body["error"]
  end
end
