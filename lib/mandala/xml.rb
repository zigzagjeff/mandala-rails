require "cgi"

# Renders API v1 payloads as the nested XML that agents consume.
# All text is escaped, agentic_summary included: a summary is a leaf
# text node here, even though its content is itself XML-shaped.
module MandalaClient
  module Xml
    module_function

    def mandalas(list)
      [ "<mandalas>", *list.map { |m| indent(mandala(m)) }, "</mandalas>" ].join("\n")
    end

    def mandala(mandala)
      "<mandala #{attributes(id: mandala["id"], title: mandala["title"], root_grid_id: mandala["root_grid_id"])}/>"
    end

    def grid(grid)
      opening = "<grid #{attributes(id: grid["id"], mandala_id: grid["mandala_id"], depth: grid["depth"], parent_tile_id: grid["parent_tile_id"])}>"
      [ opening, *grid["tiles"].map { |t| indent(tile(t)) }, "</grid>" ].join("\n")
    end

    def tile(tile)
      opening = "<tile #{attributes(id: tile["id"], position: tile["position"], heading_level: tile["heading_level"], child_grid_id: tile["child_grid_id"])}>"
      fields = %w[title subtitle agentic_summary body].filter_map do |field|
        "  <#{field}>#{escape(tile[field])}</#{field}>" unless tile[field].to_s.empty?
      end
      [ opening, *fields, "</tile>" ].join("\n")
    end

    def attributes(pairs)
      pairs.reject { |_, value| value.nil? }.map { |name, value| %(#{name}="#{escape(value)}") }.join(" ")
    end

    def escape(value)
      CGI.escapeHTML(value.to_s)
    end

    def indent(xml)
      xml.gsub(/^/, "  ")
    end
  end
end
