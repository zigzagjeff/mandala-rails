require "net/http"
require "json"

module MandalaClient
  class Api
    Error = Class.new(StandardError)

    def initialize(base_url: ENV.fetch("MANDALA_URL", "http://localhost:3000"),
                   token: ENV.fetch("MANDALA_API_TOKEN"))
      @base_url = base_url
      @token = token
    end

    def get(path)
      request Net::HTTP::Get.new(uri(path))
    end

    def post(path)
      request Net::HTTP::Post.new(uri(path))
    end

    def patch(path, payload)
      request Net::HTTP::Patch.new(uri(path)).tap { |it| it.body = JSON.generate(payload) }
    end

    private

    def uri(path)
      URI.join(@base_url, path)
    end

    def request(req)
      req["Authorization"] = "Bearer #{@token}"
      req["Content-Type"] = "application/json"
      response = Net::HTTP.start(req.uri.hostname, req.uri.port, use_ssl: req.uri.scheme == "https") do |http|
        http.request(req)
      end
      raise Error, "#{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    end
  end
end
