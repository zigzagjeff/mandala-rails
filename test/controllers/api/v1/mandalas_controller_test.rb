require "test_helper"

class Api::V1::MandalasControllerTest < ActionDispatch::IntegrationTest
  test "requests without a token are unauthorized" do
    get api_v1_mandalas_path
    assert_response :unauthorized
  end

  test "requests with a bad token are unauthorized" do
    get api_v1_mandalas_path, headers: { "Authorization" => "Bearer wrong" }
    assert_response :unauthorized
  end

  test "index lists only the token owner's mandalas" do
    get api_v1_mandalas_path, headers: authorized_headers
    assert_response :success
    titles = response.parsed_body.map { |mandala| mandala["title"] }
    assert_includes titles, mandalas(:one).title
    assert_not_includes titles, mandalas(:two).title
  end

  test "show returns mandala metadata with the root grid id" do
    get api_v1_mandala_path(mandalas(:one)), headers: authorized_headers
    assert_response :success
    assert_equal mandalas(:one).title, response.parsed_body["title"]
    assert_equal grids(:one).id, response.parsed_body["root_grid_id"]
  end

  test "show cannot reach another user's mandala" do
    get api_v1_mandala_path(mandalas(:two)), headers: authorized_headers
    assert_response :not_found
  end

  test "create seeds a root grid with 9 tiles and returns it" do
    assert_difference [ "Mandala.count", "Grid.count" ], 1 do
      post api_v1_mandalas_path,
           params: { mandala: { title: "Agent Mandala" } },
           headers: authorized_headers, as: :json
    end
    assert_response :created
    mandala = Mandala.find(response.parsed_body["id"])
    assert_equal response.parsed_body["root_grid_id"], mandala.root_grid.id
    assert_equal 9, mandala.root_grid.tiles.count
  end

  test "create with invalid params returns errors" do
    post api_v1_mandalas_path,
         params: { mandala: { title: "" } },
         headers: authorized_headers, as: :json
    assert_response :unprocessable_entity
    assert response.parsed_body["errors"].any?
  end
end
