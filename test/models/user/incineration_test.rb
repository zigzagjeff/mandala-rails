require "test_helper"

class User::IncinerationTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  test "run destroys a due, closed user and cascades to their whole tree" do
    chart_ids = @user.charts.pluck(:id)
    grid_ids = Grid.where(chart_id: chart_ids).pluck(:id)
    tile_ids = Tile.where(grid_id: grid_ids).pluck(:id)
    charts(:one).events.create!(action: "chart_created", creator: @user, eventable: charts(:one))

    @user.close
    travel User::Closeable::INCINERATED_AFTER + 1.day do
      User::Incineration.new(@user).run
    end

    assert_not User.exists?(@user.id)
    assert_empty Chart.where(id: chart_ids)
    assert_empty Grid.where(id: grid_ids)
    assert_empty Tile.where(id: tile_ids)
    assert_empty Event.where(chart_id: chart_ids)
  end

  test "possible? is false before the grace period elapses" do
    @user.close

    assert_not User::Incineration.new(@user).possible?
  end

  test "possible? is true once the grace period has elapsed" do
    @user.close

    travel User::Closeable::INCINERATED_AFTER + 1.day do
      assert User::Incineration.new(@user).possible?
    end
  end

  test "possible? is false for a reopened account even after the original window" do
    @user.close
    @user.reopen

    travel User::Closeable::INCINERATED_AFTER + 1.day do
      assert_not User::Incineration.new(@user).possible?
    end
  end

  test "a stale job from a reopened-then-reclosed account does not incinerate early" do
    @user.close
    @user.reopen

    travel 5.days do
      @user.close
    end

    # The first close's job comes due here; its wait is stale because the
    # second close restarted the grace period, so it must leave the account.
    travel User::Closeable::INCINERATED_AFTER + 1.day do
      User::Incineration.new(@user).run
      assert User.exists?(@user.id), "stale incineration destroyed a re-closed account mid-grace"
    end
  end
end
