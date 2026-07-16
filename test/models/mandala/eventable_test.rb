require "test_helper"

class Mandala::EventableTest < ActiveSupport::TestCase
  setup do
    Current.user = users(:one)
  end

  test "creating a mandala records mandala_created" do
    mandala = Current.user.mandalas.create!(title: "Fresh Start")

    event = mandala.events.last
    assert_equal "mandala_created", event.action
    assert_equal mandala, event.eventable
    assert_equal Current.user, event.creator
  end

  test "retitling a mandala records the old and new titles" do
    mandala = mandalas(:one)
    mandala.update!(title: "Sharper Focus")

    event = mandala.events.chronologically.last
    assert_equal "mandala_title_changed", event.action
    assert_equal "My Planning Mandala", event.particulars["old_title"]
    assert_equal "Sharper Focus", event.particulars["new_title"]
  end

  test "saving without changes records nothing" do
    assert_no_difference "Event.count" do
      mandalas(:one).update!(title: mandalas(:one).title)
    end
  end

  test "nothing is recorded without a Current user" do
    Current.user = nil

    assert_no_difference "Event.count" do
      users(:one).mandalas.create!(title: "Console Mandala")
    end
  end
end
