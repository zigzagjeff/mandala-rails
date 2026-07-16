require_relative "api"
require_relative "xml"

# The Unix-pipe face of API v1: one HTTP call per subcommand, nested XML
# to stdout, errors to stderr with a non-zero exit.
module MandalaClient
  class Cli
    USAGE = <<~TEXT
      Usage: bin/mandala <command> [args]
        list                        list mandalas
        show <id>                   mandala metadata + root grid id
        grid <id>                   grid with its nine tiles (no bodies)
        tile <id>                   full tile including body
        drill <tile-id>             create or return the tile's child grid
        summarize <tile-id> <slug>  write the tile's agentic_summary
      Env: MANDALA_URL (default http://localhost:3000), MANDALA_API_TOKEN
    TEXT

    def initialize(argv, api: nil)
      @command, *@args = argv
      @api = api
    end

    def run
      output = perform
      return usage unless output
      $stdout.puts output
      0
    rescue Api::Error => e
      $stderr.puts e.message
      1
    end

    private

    def perform
      case @command
      when "list" then Xml.mandalas(api.get("/api/v1/mandalas"))
      when "show" then Xml.mandala(api.get("/api/v1/mandalas/#{id}"))
      when "grid" then Xml.grid(api.get("/api/v1/grids/#{id}"))
      when "tile" then Xml.tile(api.get("/api/v1/tiles/#{id}"))
      when "drill" then Xml.grid(api.post("/api/v1/tiles/#{id}/drill"))
      when "summarize" then Xml.tile(api.patch("/api/v1/tiles/#{id}", tile: { agentic_summary: slug }))
      end
    end

    def id
      @args.first
    end

    def slug
      @args[1]
    end

    def usage
      $stderr.puts USAGE
      1
    end

    def api
      @api ||= Api.new
    end
  end
end
