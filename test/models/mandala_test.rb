require "test_helper"

class MandalaTest < ActiveSupport::TestCase
  # --- validations ---

  test "requires title" do
    mandala = users(:one).mandalas.build
    assert_not mandala.valid?
    assert mandala.errors[:title].any?
  end

  # --- root_grid ---

  test "root_grid returns the grid with no parent_tile_id" do
    assert_equal grids(:one), mandalas(:one).root_grid
  end

  # --- center_tile ---

  test "center_tile returns the root grid's center tile" do
    center = grids(:one).tiles.create!(position: 4, title: "Run a marathon")
    assert_equal center, mandalas(:one).center_tile
  end

  test "center_tile is nil when the center tile does not exist" do
    assert_nil mandalas(:one).center_tile
  end

  # --- root center seeding ---

  test "seeds the root center tile from the title on create" do
    mandala = @user.mandalas.create!(title: "Run a marathon")
    assert_equal "Run a marathon", mandala.center_tile.title
  end

  # --- 9-mandala limit ---

  setup do
    @user = User.create!(email_address: "test_mandala_#{SecureRandom.hex(4)}@example.com", password: "a-secure-passphrase")
  end

  test "allows creating up to 9 mandalas" do
    8.times { |i| @user.mandalas.create!(title: "Mandala #{i}") }
    mandala = @user.mandalas.build(title: "Mandala 9")
    assert mandala.valid?, "Expected 9th mandala to be valid"
  end

  test "rejects a 10th mandala" do
    9.times { |i| @user.mandalas.create!(title: "Mandala #{i}") }
    mandala = @user.mandalas.build(title: "Over the limit")
    assert_not mandala.valid?
    assert_includes mandala.errors[:base].first, "9-mandala limit"
  end

  test "LIMIT constant is 9" do
    assert_equal 9, Mandala::LIMIT
  end
end
