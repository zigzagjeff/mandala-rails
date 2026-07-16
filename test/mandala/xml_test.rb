require "test_helper"
require_relative "../../lib/mandala/xml"

class MandalaClient::XmlTest < ActiveSupport::TestCase
  test "mandala renders attributes and omits absent ones" do
    xml = MandalaClient::Xml.mandala({ "id" => 2, "title" => "Sunday" })
    assert_equal %(<mandala id="2" title="Sunday"/>), xml
  end

  test "mandala includes root_grid_id when present" do
    xml = MandalaClient::Xml.mandala({ "id" => 2, "title" => "Sunday", "root_grid_id" => 15 })
    assert_includes xml, %(root_grid_id="15")
  end

  test "mandalas wraps and indents the list" do
    xml = MandalaClient::Xml.mandalas([ { "id" => 1, "title" => "OMM" } ])
    assert_equal %(<mandalas>\n  <mandala id="1" title="OMM"/>\n</mandalas>), xml
  end

  test "tile nests non-blank fields as elements and skips blank ones" do
    xml = MandalaClient::Xml.tile({ "id" => 128, "position" => 1, "heading_level" => 2,
                                 "title" => "Hello", "subtitle" => nil, "body" => "" })
    assert_includes xml, "<title>Hello</title>"
    assert_not_includes xml, "<subtitle>"
    assert_not_includes xml, "<body>"
  end

  test "tile escapes markup in text and attributes" do
    xml = MandalaClient::Xml.tile({ "id" => 1, "position" => 0,
                                 "title" => %(Q3 "Focus" <draft>),
                                 "agentic_summary" => "<q3_focus>Ship it & rest</q3_focus>" })
    assert_includes xml, "<title>Q3 &quot;Focus&quot; &lt;draft&gt;</title>"
    assert_includes xml, "<agentic_summary>&lt;q3_focus&gt;Ship it &amp; rest&lt;/q3_focus&gt;</agentic_summary>"
  end

  test "grid nests its tiles" do
    xml = MandalaClient::Xml.grid({ "id" => 15, "mandala_id" => 2, "depth" => 0,
                                 "tiles" => [ { "id" => 128, "position" => 1, "title" => "Hello" } ] })
    assert xml.start_with?(%(<grid id="15" mandala_id="2" depth="0">))
    assert_includes xml, %(  <tile id="128" position="1">)
    assert xml.end_with?("</grid>")
  end
end
