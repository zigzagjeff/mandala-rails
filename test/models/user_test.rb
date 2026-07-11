require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "valid with an email address and a long enough password" do
    user = User.new(email_address: "new@example.com", password: "a-secure-passphrase")
    assert user.valid?
  end

  test "requires an email address" do
    user = User.new(password: "a-secure-passphrase")
    assert_not user.valid?
    assert user.errors.of_kind?(:email_address, :blank)
  end

  test "requires a unique email address" do
    user = User.new(email_address: users(:one).email_address, password: "a-secure-passphrase")
    assert_not user.valid?
    assert user.errors.of_kind?(:email_address, :taken)
  end

  test "rejects a password shorter than the minimum" do
    user = User.new(email_address: "new@example.com", password: "short")
    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "accepts a password at the minimum length" do
    user = User.new(email_address: "new@example.com", password: "twelvechars1")
    assert user.valid?
  end

  test "does not demand a password on a save that leaves it untouched" do
    assert users(:one).update(email_address: "renamed@example.com")
  end

  test "rejects a signup that declines the terms of service" do
    user = User.new(email_address: "new@example.com", password: "a-secure-passphrase", terms_of_service: "0")
    assert_not user.valid?
    assert user.errors.of_kind?(:terms_of_service, :accepted)
  end

  test "accepts a signup that accepts the terms of service" do
    user = User.new(email_address: "new@example.com", password: "a-secure-passphrase", terms_of_service: "1")
    assert user.valid?
  end
end
