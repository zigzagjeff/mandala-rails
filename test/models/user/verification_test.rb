require "test_helper"

class User::VerificationTest < ActiveSupport::TestCase
  setup { @user = users(:unverified) }

  test "verify records the time and flips the account to verified" do
    assert @user.unverified?

    @user.verify

    assert @user.verified?
    assert_not_nil @user.verified_at
  end

  test "verify is idempotent" do
    @user.verify
    first_verified_at = @user.verified_at

    travel 1.minute do
      @user.verify
    end

    assert_equal first_verified_at, @user.verified_at
  end

  test "a fresh token round-trips back to its user" do
    token = @user.email_verification_token

    assert_equal @user, User.find_by_email_verification_token!(token)
  end

  test "changing the email address invalidates an outstanding token" do
    token = @user.email_verification_token
    @user.update!(email_address: "moved@example.com")

    assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
      User.find_by_email_verification_token!(token)
    end
  end

  test "a token expires after the verification period" do
    token = @user.email_verification_token

    travel User::Verification::EMAIL_VERIFICATION_PERIOD + 1.minute do
      assert_raises ActiveSupport::MessageVerifier::InvalidSignature do
        User.find_by_email_verification_token!(token)
      end
    end
  end
end
