require "test_helper"

class VerificationMailerTest < ActionMailer::TestCase
  test "verify" do
    mail = VerificationMailer.verify(users(:unverified))

    assert_equal "Verify your email address", mail.subject
    assert_equal [ "unverified@example.com" ], mail.to
    assert_equal [ "noreply@jlintelligence.net" ], mail.from
    assert_match %r{/email_verifications/}, mail.body.encoded
  end
end
