require "test_helper"

class GridsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chart = charts(:one)
    @tile = tiles(:one)
    sign_in_as(users(:one))
  end

  test "show subscribes to the chart's event stream" do
    child = @tile.drill

    get chart_grid_path(@chart, child)

    assert_response :success
    assert_select "turbo-cable-stream-source[signed-stream-name=?]",
      Turbo::StreamsChannel.signed_stream_name(@chart)
  end

  test "breadcrumb at depth 1 shows the parent tile once, as the current label" do
    child = @tile.drill

    get chart_grid_path(@chart, child)

    assert_response :success
    assert_select ".breadcrumb-current", text: @tile.title
    assert_select ".breadcrumb a", text: @tile.title, count: 0
  end

  test "breadcrumb at depth 2 links the intermediate tile to its child grid" do
    child = @tile.drill
    inner_tile = child.tiles.find_by(position: 2)
    inner_tile.update!(title: "Seattle")
    grandchild = inner_tile.drill

    get chart_grid_path(@chart, grandchild)

    assert_response :success
    assert_select ".breadcrumb-current", text: "Seattle"
    assert_select ".breadcrumb a[href=?]", chart_grid_path(@chart, child), text: @tile.title
    assert_select ".breadcrumb a", text: "Seattle", count: 0
  end

  test "sub-grid tiles offer no drill" do
    child = @tile.drill

    get chart_grid_path(@chart, child)

    assert_response :success
    assert_select "button.tile-drill", count: 0
  end

  test "show cannot reach another user's grid" do
    other_grid = grids(:two)

    get chart_grid_path(@chart, other_grid)

    assert_response :not_found
  end
end
