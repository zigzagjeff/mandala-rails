require "test_helper"
require_relative "../../lib/mandala/mcp_server"

# Real Api against stubbed sockets — the Campfire webhook_test pattern.
class MandalaClient::ToolRoutesTest < ActiveSupport::TestCase
  BASE = "http://mandala.test"
  AUTH = { "Authorization" => "Bearer secret-token" }

  setup do
    @server = MandalaClient::McpServer.new(api: MandalaClient::Api.new(base_url: BASE, token: "secret-token"))
  end

  test "list_mandalas GETs the mandalas index and renders the list" do
    stub_request(:get, "#{BASE}/api/v1/mandalas").with(headers: AUTH)
      .to_return(body: [ { id: 1, title: "OMM" } ].to_json)

    text = call_tool("list_mandalas")

    assert_includes text, %(<mandala id="1" title="OMM"/>)
  end

  test "get_mandala GETs the mandala and renders root_grid_id" do
    stub_request(:get, "#{BASE}/api/v1/mandalas/2").with(headers: AUTH)
      .to_return(body: { id: 2, title: "Sunday", root_grid_id: 15 }.to_json)

    text = call_tool("get_mandala", "mandala_id" => 2)

    assert_includes text, %(root_grid_id="15")
  end

  test "get_grid GETs the grid and nests its tiles" do
    stub_request(:get, "#{BASE}/api/v1/grids/15").with(headers: AUTH)
      .to_return(body: { id: 15, mandala_id: 2, depth: 0,
                         tiles: [ { id: 128, position: 1, title: "Hello" } ] }.to_json)

    text = call_tool("get_grid", "grid_id" => 15)

    assert_includes text, %(<grid id="15" mandala_id="2" depth="0">)
    assert_includes text, "<title>Hello</title>"
  end

  test "get_tile GETs the full tile with body" do
    stub_request(:get, "#{BASE}/api/v1/tiles/128").with(headers: AUTH)
      .to_return(body: { id: 128, position: 1, title: "Hello", body: "Deep thoughts" }.to_json)

    text = call_tool("get_tile", "tile_id" => 128)

    assert_includes text, "<body>Deep thoughts</body>"
  end

  test "write_agentic_summary PATCHes the tile payload and renders the result" do
    stub_request(:patch, "#{BASE}/api/v1/tiles/128")
      .with(headers: AUTH, body: { tile: { agentic_summary: "<hello_slug>hi</hello_slug>" } })
      .to_return(body: { id: 128, position: 1, title: "Hello",
                         agentic_summary: "<hello_slug>hi</hello_slug>" }.to_json)

    text = call_tool("write_agentic_summary", "tile_id" => 128, "summary" => "<hello_slug>hi</hello_slug>")

    assert_includes text, "<agentic_summary>&lt;hello_slug&gt;hi&lt;/hello_slug&gt;</agentic_summary>"
  end

  test "an API refusal surfaces as a tool error with the status and body" do
    stub_request(:get, "#{BASE}/api/v1/tiles/9999").with(headers: AUTH)
      .to_return(status: 404, body: { error: "Not found" }.to_json)

    response = @server.handle(tools_call("get_tile", "tile_id" => 9999))

    assert response[:result][:isError]
    assert_includes response[:result][:content].first[:text], "404"
  end

  private

  def call_tool(name, args = {})
    response = @server.handle(tools_call(name, args))
    assert_nil response[:result][:isError]
    response[:result][:content].first[:text]
  end

  def tools_call(name, args)
    { "jsonrpc" => "2.0", "id" => 1, "method" => "tools/call",
      "params" => { "name" => name, "arguments" => args } }
  end
end
