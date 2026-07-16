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

  # @user already owns the Start Here mandala seeded on create, so these fill
  # relative to the current count rather than assuming an empty slate.

  test "allows creating up to 9 mandalas" do
    fill_mandalas_to Mandala::LIMIT - 1
    assert_equal Mandala::LIMIT - 1, @user.mandalas.count
    assert @user.mandalas.build(title: "Ninth mandala").valid?, "Expected 9th mandala to be valid"
  end

  test "rejects a 10th mandala" do
    fill_mandalas_to Mandala::LIMIT
    assert_equal Mandala::LIMIT, @user.mandalas.count
    mandala = @user.mandalas.build(title: "Over the limit")
    assert_not mandala.valid?
    assert_includes mandala.errors[:base].first, "9-mandala limit"
  end

  test "LIMIT constant is 9" do
    assert_equal 9, Mandala::LIMIT
  end

  private
    def fill_mandalas_to(count)
      (count - @user.mandalas.count).times { |i| @user.mandalas.create!(title: "Mandala #{i}") }
    end
end
