require "test_helper"

class Mandala::StartHereTemplateTest < ActiveSupport::TestCase
  setup { @user = users(:one) }

  test "seed_for creates a mandala titled Start Here" do
    mandala = Mandala::StartHereTemplate.seed_for(@user)
    assert_equal "Start Here", mandala.title
    assert_equal @user, mandala.user
  end

  test "titles the center tile Start Here" do
    mandala = Mandala::StartHereTemplate.seed_for(@user)
    assert_equal "Start Here", mandala.center_tile.title
  end

  test "fills the four surrounding tiles with titled help copy" do
    mandala = Mandala::StartHereTemplate.seed_for(@user)
    tiles = mandala.root_grid.tiles.positioned

    assert_equal "What is a Mandala?", tiles[0].title
    assert_includes tiles[0].body.to_s, "Harada Method"
    assert_equal "How to Use It", tiles[1].title
    assert_equal "How you can help", tiles[2].title
    assert_equal "What's next?", tiles[3].title
    assert tiles[3].body.body.present?
  end

  test "the help copy tells the user their mandalas are private" do
    mandala = Mandala::StartHereTemplate.seed_for(@user)
    help = mandala.root_grid.tiles.positioned[2]

    assert_includes help.body.to_s, "private to your account"
    assert_not_includes help.body.to_s, "There is no privacy"
  end

  test "leaves the outer tiles blank for the user to grow into" do
    mandala = Mandala::StartHereTemplate.seed_for(@user)
    tiles = mandala.root_grid.tiles.positioned

    (5..8).each do |position|
      assert tiles[position].title.blank?, "Expected position #{position} to stay blank"
      assert tiles[position].body.body.blank?
    end
  end

  test "records no events while seeding, even with a Current user" do
    Current.user = @user
    mandala = Mandala::StartHereTemplate.seed_for(@user)

    assert_empty mandala.events
  end
end
