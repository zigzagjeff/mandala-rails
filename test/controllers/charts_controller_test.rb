require "test_helper"

class ChartsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "create seeds root grid with exactly 9 tiles" do
    assert_difference "Chart.count", 1 do
      post charts_path, params: { chart: { title: "New Chart", mode: "planning" } }
    end
    assert_redirected_to charts_path
    chart = Chart.order(created_at: :desc).first
    root_grid = chart.root_grid
    assert_not_nil root_grid
    assert_equal 9, root_grid.tiles.count
  end

  test "create with invalid params re-renders new" do
    post charts_path, params: { chart: { title: "", mode: "planning" } }
    assert_response :unprocessable_entity
  end

  test "new redirects to charts_path when user has 9 charts" do
    # @user already has 1 chart from fixtures; create 8 more to hit the limit
    8.times { |i| @user.charts.create!(title: "Chart #{i}", mode: "planning") }
    get new_chart_path
    assert_redirected_to charts_path
  end

  test "show maps tile zones: title renames, body writes, arrow drills" do
    chart = charts(:one)
    tile = tiles(:one)
    get chart_path(chart)
    assert_response :success
    assert_select "a.tile-title-zone[href=?]", rename_chart_tile_path(chart, tile)
    assert_select "a.tile-body-zone[href=?]", edit_chart_tile_path(chart, tile)
    assert_select "a.tile-drill[href=?]", drill_chart_tile_path(chart, tile)
  end

  test "show offers no drill on the center tile" do
    chart = charts(:one)
    center = chart.root_grid.tiles.create!(position: 4, title: "Goal")
    get chart_path(chart)
    assert_select "a.tile-drill[href=?]", drill_chart_tile_path(chart, center), count: 0
  end
end
