require "test_helper"

class Api::V1::ChartsControllerTest < ActionDispatch::IntegrationTest
  test "requests without a token are unauthorized" do
    get api_v1_charts_path
    assert_response :unauthorized
  end

  test "requests with a bad token are unauthorized" do
    get api_v1_charts_path, headers: { "Authorization" => "Bearer wrong" }
    assert_response :unauthorized
  end

  test "index lists only the token owner's charts" do
    get api_v1_charts_path, headers: authorized_headers
    assert_response :success
    titles = response.parsed_body.map { |chart| chart["title"] }
    assert_includes titles, charts(:one).title
    assert_not_includes titles, charts(:two).title
  end

  test "show returns chart metadata with the root grid id" do
    get api_v1_chart_path(charts(:one)), headers: authorized_headers
    assert_response :success
    assert_equal charts(:one).title, response.parsed_body["title"]
    assert_equal grids(:one).id, response.parsed_body["root_grid_id"]
  end

  test "show cannot reach another user's chart" do
    get api_v1_chart_path(charts(:two)), headers: authorized_headers
    assert_response :not_found
  end

  test "create seeds a root grid with 9 tiles and returns it" do
    assert_difference [ "Chart.count", "Grid.count" ], 1 do
      post api_v1_charts_path,
           params: { chart: { title: "Agent Chart", mode: "planning" } },
           headers: authorized_headers, as: :json
    end
    assert_response :created
    chart = Chart.find(response.parsed_body["id"])
    assert_equal response.parsed_body["root_grid_id"], chart.root_grid.id
    assert_equal 9, chart.root_grid.tiles.count
  end

  test "create with invalid params returns errors" do
    post api_v1_charts_path,
         params: { chart: { title: "", mode: "planning" } },
         headers: authorized_headers, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].any?
  end
end
