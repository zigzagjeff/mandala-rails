require "test_helper"
require_relative "../../lib/mandala/cli"

# Real Api against stubbed sockets — the Campfire webhook_test pattern.
class MandalaClient::CliTest < ActiveSupport::TestCase
  BASE = "http://mandala.test"
  AUTH = { "Authorization" => "Bearer secret-token" }

  test "list prints the mandala list and exits 0" do
    stub_request(:get, "#{BASE}/api/v1/mandalas").with(headers: AUTH)
      .to_return(body: [ { id: 1, title: "OMM" } ].to_json)

    status = nil
    out, _err = capture_io { status = cli("list").run }

    assert_equal 0, status
    assert_includes out, %(<mandala id="1" title="OMM"/>)
  end

  test "drill POSTs and prints the child grid" do
    stub_request(:post, "#{BASE}/api/v1/tiles/128/drill").with(headers: AUTH)
      .to_return(body: { id: 18, mandala_id: 2, depth: 1, parent_tile_id: 128,
                         tiles: [ { id: 154, position: 4, title: "Hello" } ] }.to_json)

    status = nil
    out, _err = capture_io { status = cli("drill", "128").run }

    assert_equal 0, status
    assert_includes out, %(parent_tile_id="128")
    assert_includes out, "<title>Hello</title>"
  end

  test "summarize PATCHes the slug payload" do
    stub_request(:patch, "#{BASE}/api/v1/tiles/128")
      .with(headers: AUTH, body: { tile: { agentic_summary: "<hello>hi</hello>" } })
      .to_return(body: { id: 128, position: 1, agentic_summary: "<hello>hi</hello>" }.to_json)

    status = nil
    capture_io { status = cli("summarize", "128", "<hello>hi</hello>").run }

    assert_equal 0, status
  end

  test "an API refusal goes to stderr with exit 1" do
    stub_request(:get, "#{BASE}/api/v1/tiles/9999").with(headers: AUTH)
      .to_return(status: 404, body: { error: "Not found" }.to_json)

    status = nil
    _out, err = capture_io { status = cli("tile", "9999").run }

    assert_equal 1, status
    assert_includes err, "404"
  end

  test "no command prints usage to stderr with exit 1" do
    status = nil
    _out, err = capture_io { status = cli.run }

    assert_equal 1, status
    assert_includes err, "Usage: bin/mandala"
  end

  private

  def cli(*argv)
    MandalaClient::Cli.new(argv, api: MandalaClient::Api.new(base_url: BASE, token: "secret-token"))
  end
end
