require "test_helper"

class MandalasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "create seeds root grid with exactly 9 tiles" do
    assert_difference "Mandala.count", 1 do
      post mandalas_path, params: { mandala: { title: "New Mandala" } }
    end
    assert_redirected_to mandalas_path
    mandala = Mandala.order(created_at: :desc).first
    root_grid = mandala.root_grid
    assert_not_nil root_grid
    assert_equal 9, root_grid.tiles.count
  end

  test "show subscribes to the mandala's event stream" do
    get mandala_path(mandalas(:one))

    assert_response :success
    assert_select "turbo-cable-stream-source[signed-stream-name=?]",
      Turbo::StreamsChannel.signed_stream_name(mandalas(:one))
  end

  test "create with invalid params re-renders new" do
    post mandalas_path, params: { mandala: { title: "" } }
    assert_response :unprocessable_entity
  end

  test "show maps tile zones: title renames, body writes, arrow drills" do
    mandala = mandalas(:one)
    tile = tiles(:one)
    get mandala_path(mandala)
    assert_response :success
    assert_select "a.tile-title-zone[href=?]", rename_mandala_tile_path(mandala, tile)
    assert_select "a.tile-body-zone[href=?]", edit_mandala_tile_path(mandala, tile)
    assert_select "form[action=?] button.tile-drill", mandala_tile_drill_path(mandala, tile)
  end

  test "show offers no drill on the center tile" do
    mandala = mandalas(:one)
    center = mandala.root_grid.tiles.create!(position: 4, title: "Center")
    get mandala_path(mandala)
    assert_select "form[action=?]", mandala_tile_drill_path(mandala, center), count: 0
  end

  test "blank tiles invite with placeholder copy" do
    mandala = mandalas(:one)
    mandala.root_grid.tiles.create!(position: 4)
    mandala.root_grid.tiles.create!(position: 0)
    get mandala_path(mandala)
    assert_select "span.tile-title--placeholder", text: "Name the center"
    assert_select "span.tile-title--placeholder", text: "Add a tile"
  end

  test "index previews each mandala's center under its title" do
    mandalas(:one).root_grid.tiles.create!(position: 4, title: "Run a marathon")
    get mandalas_path
    assert_select ".mandala-center-preview", text: "Run a marathon"
  end

  test "index shows no preview when the center tile is blank" do
    get mandalas_path
    assert_select ".mandala-center-preview", count: 0
  end

  test "index preloads center tiles rather than querying per mandala" do
    3.times { |i| @user.mandalas.create!(title: "Mandala #{i}") }

    assert_queries_match(/FROM ["`]grids["`].* IN \(/, count: 1) do
      assert_queries_match(/FROM ["`]tiles["`].* IN \(/, count: 1) do
        get mandalas_path
      end
    end

    assert_response :success
  end
end
