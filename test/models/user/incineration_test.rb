require "test_helper"

class User::IncinerationTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  test "run destroys a due, closed user and cascades to their whole tree" do
    mandala_ids = @user.mandalas.pluck(:id)
    grid_ids = Grid.where(mandala_id: mandala_ids).pluck(:id)
    tile_ids = Tile.where(grid_id: grid_ids).pluck(:id)
    mandalas(:one).events.create!(action: "mandala_created", creator: @user, eventable: mandalas(:one))

    @user.close
    travel User::Closeable::INCINERATED_AFTER + 1.day do
      User::Incineration.new(@user).run
    end

    assert_not User.exists?(@user.id)
    assert_empty Mandala.where(id: mandala_ids)
    assert_empty Grid.where(id: grid_ids)
    assert_empty Tile.where(id: tile_ids)
    assert_empty Event.where(mandala_id: mandala_ids)
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
