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

  test "show subscribes to the chart's event stream" do
    get chart_path(charts(:one))

    assert_response :success
    assert_select "turbo-cable-stream-source[signed-stream-name=?]",
      Turbo::StreamsChannel.signed_stream_name(charts(:one))
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
    assert_select "form[action=?] button.tile-drill", chart_tile_drill_path(chart, tile)
  end

  test "show offers no drill on the center tile" do
    chart = charts(:one)
    center = chart.root_grid.tiles.create!(position: 4, title: "Goal")
    get chart_path(chart)
    assert_select "form[action=?]", chart_tile_drill_path(chart, center), count: 0
  end

  test "blank tiles invite with placeholder copy" do
    chart = charts(:one)
    chart.root_grid.tiles.create!(position: 4)
    chart.root_grid.tiles.create!(position: 0)
    get chart_path(chart)
    assert_select "a.tile-title--placeholder", text: "Set your goal"
    assert_select "a.tile-title--placeholder", text: "Add a theme"
  end

  test "index previews each chart's goal under its title" do
    charts(:one).root_grid.tiles.create!(position: 4, title: "Run a marathon")
    get charts_path
    assert_select ".chart-goal-preview", text: "Run a marathon"
  end

  test "index shows no preview when the goal tile is blank" do
    get charts_path
    assert_select ".chart-goal-preview", count: 0
  end
end
