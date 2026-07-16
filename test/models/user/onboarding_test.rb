require "test_helper"

class User::OnboardingTest < ActiveSupport::TestCase
  test "a new user starts with the Start Here mandala" do
    user = User.create!(email_address: "onboarded@example.com", password: "a-secure-passphrase")

    assert_equal 1, user.mandalas.count
    assert_equal "Start Here", user.mandalas.sole.title
  end

  test "the seeded mandala carries the onboarding help copy" do
    user = User.create!(email_address: "onboarded@example.com", password: "a-secure-passphrase")

    tiles = user.mandalas.sole.root_grid.tiles.positioned
    assert_equal "Start Here", tiles[Tile::CENTER_POSITION].title
    assert_equal "What is a Mandala?", tiles[0].title
  end
end
