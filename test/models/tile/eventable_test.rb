require "test_helper"

class Tile::EventableTest < ActiveSupport::TestCase
  setup do
    Current.user = users(:one)
    @tile = tiles(:one)
  end

  test "retitling records the old and new titles" do
    @tile.update!(title: "Community Garden")

    event = @tile.events.last
    assert_equal "tile_title_changed", event.action
    assert_equal "BFP Community", event.particulars["old_title"]
    assert_equal "Community Garden", event.particulars["new_title"]
    assert_equal @tile.chart, event.chart
  end

  test "changing the subtitle records the old and new subtitles" do
    @tile.update!(subtitle: "Weekly meetups")

    event = @tile.events.last
    assert_equal "tile_subtitle_changed", event.action
    assert_nil event.particulars["old_subtitle"]
    assert_equal "Weekly meetups", event.particulars["new_subtitle"]
  end

  test "a body-only edit records tile_body_changed" do
    assert_difference "Event.count", 1 do
      @tile.update!(body: "<p>Plant the seeds</p>")
    end

    assert_equal "tile_body_changed", @tile.events.last.action
  end

  test "editing title and body together records both events" do
    @tile.update!(title: "Community Garden", body: "<p>Plant the seeds</p>")

    assert_equal [ "tile_title_changed", "tile_body_changed" ],
      @tile.events.chronologically.pluck(:action)
  end

  test "writing an agentic summary records tile_summarized" do
    @tile.update!(agentic_summary: "<community>growing</community>")

    assert_equal "tile_summarized", @tile.events.last.action
  end

  test "saving without changes records nothing" do
    assert_no_difference "Event.count" do
      @tile.update!(title: @tile.title)
    end
  end

  test "drilling records tile_drilled and nothing for the mechanical title copy" do
    assert_difference "Event.count", 1 do
      @tile.drill
    end

    event = @tile.events.last
    assert_equal "tile_drilled", event.action
    assert_equal @tile, event.eventable
  end

  test "drilling an already-drilled tile records nothing" do
    @tile.drill

    assert_no_difference "Event.count" do
      @tile.drill
    end
  end

  test "creating a tile records nothing" do
    assert_no_difference "Event.count" do
      grids(:one).tiles.create!(position: 0)
    end
  end

  test "nothing is recorded without a Current user" do
    Current.user = nil

    assert_no_difference "Event.count" do
      @tile.update!(title: "Quiet edit")
    end
  end

  test "destroying a tile destroys its events" do
    @tile.update!(title: "Community Garden")

    assert_difference "Event.count", -1 do
      @tile.destroy
    end
  end
end
