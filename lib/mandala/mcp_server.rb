require "json"
require_relative "api"
require_relative "xml"

# A stdio MCP server: JSON-RPC 2.0, tools only. A consumption layer
# over API v1 — every tool is one HTTP call rendered as XML. The
# protocol surface is hand-rolled on purpose: five tools do not earn
# a gem dependency, and the framing below is the whole of it.
module MandalaClient
  class McpServer
    PROTOCOL_VERSION = "2024-11-05"

    TOOLS = [
      { name: "list_mandalas",
        description: "List the user's mandalas.",
        inputSchema: { type: "object", properties: {}, required: [] } },
      { name: "get_mandala",
        description: "Mandala metadata plus its root_grid_id — the entry point for traversal.",
        inputSchema: { type: "object", properties: { mandala_id: { type: "integer" } }, required: [ "mandala_id" ] } },
      { name: "get_grid",
        description: "A grid with its nine tiles: titles, agentic summaries, heading levels, child grid ids. No bodies — read those per tile.",
        inputSchema: { type: "object", properties: { grid_id: { type: "integer" } }, required: [ "grid_id" ] } },
      { name: "get_tile",
        description: "One full tile, including its body as plain text.",
        inputSchema: { type: "object", properties: { tile_id: { type: "integer" } }, required: [ "tile_id" ] } },
      { name: "write_agentic_summary",
        description: "Write the machine-only agentic_summary slug for a tile. Compose it from the tile plus its grid neighbors and parent, per AGENTS.md.",
        inputSchema: { type: "object", properties: { tile_id: { type: "integer" }, summary: { type: "string" } }, required: [ "tile_id", "summary" ] } }
    ].freeze

    def initialize(api: nil)
      @api = api
    end

    def run
      $stdin.each_line do |line|
        response = handle(JSON.parse(line))
        next unless response
        $stdout.puts(JSON.generate(response))
        $stdout.flush
      end
    end

    def handle(message)
      case message["method"]
      when "initialize"
        result message, protocolVersion: PROTOCOL_VERSION, capabilities: { tools: {} },
                        serverInfo: { name: "mandala", version: "1.0.0" }
      when "tools/list"
        result message, tools: TOOLS
      when "tools/call"
        result message, **call_tool(message.dig("params", "name"), message.dig("params", "arguments") || {})
      when "ping"
        result message
      when /\Anotifications\//
        nil
      else
        error message, code: -32601, text: "method not found: #{message["method"]}"
      end
    end

    private

    def call_tool(name, args)
      text =
        case name
        when "list_mandalas" then Xml.mandalas(api.get("/api/v1/mandalas"))
        when "get_mandala" then Xml.mandala(api.get("/api/v1/mandalas/#{args.fetch("mandala_id")}"))
        when "get_grid" then Xml.grid(api.get("/api/v1/grids/#{args.fetch("grid_id")}"))
        when "get_tile" then Xml.tile(api.get("/api/v1/tiles/#{args.fetch("tile_id")}"))
        when "write_agentic_summary"
          Xml.tile(api.patch("/api/v1/tiles/#{args.fetch("tile_id")}", tile: { agentic_summary: args.fetch("summary") }))
        else
          return tool_error("unknown tool: #{name}")
        end
      { content: [ { type: "text", text: text } ] }
    rescue Api::Error, KeyError => e
      tool_error(e.message)
    end

    def tool_error(text)
      { content: [ { type: "text", text: text } ], isError: true }
    end

    def api
      @api ||= Api.new
    end

    def result(message, **payload)
      { jsonrpc: "2.0", id: message["id"], result: payload }
    end

    def error(message, code:, text:)
      return nil unless message["id"]
      { jsonrpc: "2.0", id: message["id"], error: { code: code, message: text } }
    end
  end
end
