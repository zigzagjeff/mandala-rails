require "test_helper"

class Users::IncinerationJobTest < ActiveJob::TestCase
  setup { @user = users(:one) }

  test "schedule enqueues incineration a grace period out" do
    freeze_time do
      assert_enqueued_with job: Users::IncinerationJob, args: [ @user ], at: User::Closeable::INCINERATED_AFTER.from_now do
        Users::IncinerationJob.schedule @user
      end
    end
  end

  test "perform incinerates a due, closed user" do
    @user.close

    travel User::Closeable::INCINERATED_AFTER + 1.day do
      Users::IncinerationJob.perform_now @user
    end

    assert_not User.exists?(@user.id)
  end
end
