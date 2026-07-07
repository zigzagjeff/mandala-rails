require "test_helper"
require_relative "../../lib/mandala/xml"

class Mandala::XmlTest < ActiveSupport::TestCase
  test "chart renders attributes and omits absent ones" do
    xml = Mandala::Xml.chart({ "id" => 2, "title" => "Sunday", "mode" => "brainstorm" })
    assert_equal %(<chart id="2" title="Sunday" mode="brainstorm"/>), xml
  end

  test "chart includes root_grid_id when present" do
    xml = Mandala::Xml.chart({ "id" => 2, "title" => "Sunday", "mode" => "brainstorm", "root_grid_id" => 15 })
    assert_includes xml, %(root_grid_id="15")
  end

  test "charts wraps and indents the list" do
    xml = Mandala::Xml.charts([ { "id" => 1, "title" => "OMM", "mode" => "planning" } ])
    assert_equal %(<charts>\n  <chart id="1" title="OMM" mode="planning"/>\n</charts>), xml
  end

  test "tile nests non-blank fields as elements and skips blank ones" do
    xml = Mandala::Xml.tile({ "id" => 128, "position" => 1, "heading_level" => 2,
                                 "title" => "Hello", "subtitle" => nil, "body" => "" })
    assert_includes xml, "<title>Hello</title>"
    assert_not_includes xml, "<subtitle>"
    assert_not_includes xml, "<body>"
  end

  test "tile escapes markup in text and attributes" do
    xml = Mandala::Xml.tile({ "id" => 1, "position" => 0,
                                 "title" => %(Q3 "Focus" <draft>),
                                 "agentic_summary" => "<q3_focus>Ship it & rest</q3_focus>" })
    assert_includes xml, "<title>Q3 &quot;Focus&quot; &lt;draft&gt;</title>"
    assert_includes xml, "<agentic_summary>&lt;q3_focus&gt;Ship it &amp; rest&lt;/q3_focus&gt;</agentic_summary>"
  end

  test "grid nests its tiles" do
    xml = Mandala::Xml.grid({ "id" => 15, "chart_id" => 2, "depth" => 0,
                                 "tiles" => [ { "id" => 128, "position" => 1, "title" => "Hello" } ] })
    assert xml.start_with?(%(<grid id="15" chart_id="2" depth="0">))
    assert_includes xml, %(  <tile id="128" position="1">)
    assert xml.end_with?("</grid>")
  end
end
