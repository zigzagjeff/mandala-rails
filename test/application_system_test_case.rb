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

    # The title link opens the rename form in the tile's frame; the form has no
    # submit button, so Return commits it. Fill at page level — scoping the fill
    # to the tile frame goes stale when Turbo replaces it on submit.
    def rename_tile(tile, to:)
      open_rename_form_for tile
      fill_in "tile_title", with: to
      find("#tile_title").send_keys(:return)
    end

    # A click that races Turbo's frame wiring silently no-ops, so the frame
    # never swaps to the rename form. Re-click while the title link is still
    # there until the form appears.
    def open_rename_form_for(tile)
      3.times do
        within("#tile_#{tile.id}") { click_on tile.title } if has_link?(tile.title, wait: 1)
        return if has_field?("tile_title", wait: 2)
      end
      assert_field "tile_title"
    end
end
