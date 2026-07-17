# Rebuilding from scratch converges on the same end state however often it runs,
# which is what makes seeding safe to re-run — and why it must never run outside
# development and test. Guarded on local?, not Fizzy's development?, because
# config/ci.rb replants seeds in test (C0.3 bend; ruling R13).
unless Rails.env.local?
  puts "WARN: Seeding is just for development!"
else
  Tile.destroy_all
  Grid.destroy_all
  Mandala.destroy_all
  User.destroy_all

  # User#after_create seeds the Start Here onboarding mandala, so this user already
  # opens with a populated starter chart; the demo mandala below is the only one
  # worth authoring here.
  user = User.create!(
    email_address: "jeff@example.com",
    password: "password1234",
    password_confirmation: "password1234",
    verified_at: Time.current
  )

  # Mandala#after_create seeds the root grid, and Grid#after_create seeds its nine
  # tiles (positions 0–8); the root center tile is titled from the mandala. Seeding
  # titles those existing tiles rather than creating new ones, which would collide
  # on position.
  brainstorm = Mandala.create!(title: "Brainstorm", user: user)
  { 0 => "BFP Community", 1 => "June event calendar", 2 => "App development" }.each do |position, title|
    brainstorm.root_grid.tiles.find_by(position: position).update!(title: title)
  end

  puts "Seeded: #{User.count} user, #{Mandala.count} mandalas (Start Here + Brainstorm), #{Grid.count} grids, #{Tile.count} tiles"
  puts "Login: jeff@example.com / password1234"
end
