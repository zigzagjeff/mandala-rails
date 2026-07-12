require "test_helper"

# System tests talk to a real browser over HTTP (selenium ↔ chromedriver);
# WebMock, enabled suite-wide for the API/webhook client tests, blocks that.
WebMock.disable!

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # CI is slower than a workstation; give Turbo frame swaps and cable
  # round-trips room before Capybara gives up on a selector.
  Capybara.default_max_wait_time = 5

  private
    def sign_in_as(user)
      visit new_session_path
      fill_in "email_address", with: user.email_address
      fill_in "password", with: "password"
      click_on "Sign in"
      assert_current_path root_path
    end

    def wait_for_cable_connection
      assert_selector "turbo-cable-stream-source[connected]", visible: false
    end
end
