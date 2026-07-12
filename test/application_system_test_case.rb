require "test_helper"

# System tests talk to a real browser over HTTP (selenium ↔ chromedriver);
# WebMock, enabled suite-wide for the API/webhook client tests, blocks that.
WebMock.disable!

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

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

    # The title link opens the rename form in the tile's frame; the form has no
    # submit button, so Return commits it. Fill at page level — scoping the fill
    # to the tile frame goes stale when Turbo replaces it on submit.
    def rename_tile(tile, to:)
      within "#tile_#{tile.id}" do
        click_on tile.title
      end
      fill_in "tile_title", with: to
      find("#tile_title").send_keys(:return)
    end
end
