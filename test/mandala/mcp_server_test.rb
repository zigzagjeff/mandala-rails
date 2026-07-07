require "test_helper"
require_relative "../../lib/mandala/mcp_server"

class Mandala::McpServerTest < ActiveSupport::TestCase
  setup do
    @server = Mandala::McpServer.new
  end

  test "initialize handshake declares the tools capability" do
    response = @server.handle({ "jsonrpc" => "2.0", "id" => 1, "method" => "initialize" })
    assert_equal 1, response[:id]
    assert_equal Mandala::McpServer::PROTOCOL_VERSION, response[:result][:protocolVersion]
    assert response[:result][:capabilities].key?(:tools)
    assert_equal "mandala", response[:result][:serverInfo][:name]
  end

  test "tools/list exposes the five tools from issue #10" do
    response = @server.handle({ "jsonrpc" => "2.0", "id" => 2, "method" => "tools/list" })
    names = response[:result][:tools].map { |tool| tool[:name] }
    assert_equal %w[list_charts get_chart get_grid get_tile write_agentic_summary], names
  end

  test "notifications get no response" do
    assert_nil @server.handle({ "jsonrpc" => "2.0", "method" => "notifications/initialized" })
  end

  test "unknown methods with an id get a JSON-RPC error" do
    response = @server.handle({ "jsonrpc" => "2.0", "id" => 3, "method" => "resources/list" })
    assert_equal(-32601, response[:error][:code])
  end

  test "calling an unknown tool reports a tool error, not a crash" do
    response = @server.handle({ "jsonrpc" => "2.0", "id" => 4, "method" => "tools/call",
                                "params" => { "name" => "delete_everything" } })
    assert response[:result][:isError]
    assert_includes response[:result][:content].first[:text], "unknown tool"
  end

  test "calling a tool without its required argument reports a tool error" do
    response = @server.handle({ "jsonrpc" => "2.0", "id" => 5, "method" => "tools/call",
                                "params" => { "name" => "get_tile", "arguments" => {} } })
    assert response[:result][:isError]
  end
end
