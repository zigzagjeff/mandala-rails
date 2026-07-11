require "test_helper"

class User::CloseableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup { @user = users(:one) }

  test "close schedules incineration and flips the account to closed" do
    assert_not @user.closed?

    assert_enqueued_with job: Users::IncinerationJob do
      @user.close
    end

    assert @user.closed?
    assert_not_nil @user.closed_at
  end

  test "close is idempotent" do
    @user.close
    first_closed_at = @user.closed_at

    travel 1.minute do
      assert_no_enqueued_jobs only: Users::IncinerationJob do
        @user.close
      end
    end

    assert_equal first_closed_at, @user.closed_at
  end

  test "reopen clears the schedule" do
    @user.close
    assert @user.closed?

    @user.reopen

    assert_not @user.closed?
    assert_nil @user.closed_at
  end

  test "deletes_on is a grace period past the close" do
    freeze_time do
      @user.close
      assert_equal @user.closed_at + User::Closeable::INCINERATED_AFTER, @user.deletes_on
    end
  end

  test "deletes_on is nil while the account is open" do
    assert_nil @user.deletes_on
  end
end
