# Seeds are idempotent — safe to re-run.
Tile.destroy_all
Grid.destroy_all
Mandala.destroy_all
User.destroy_all

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
Mandala.create!(title: "My First Mandala", user: user)

brainstorm = Mandala.create!(title: "Brainstorm", user: user)
{ 0 => "BFP Community", 1 => "June event calendar", 2 => "App development" }.each do |position, title|
  brainstorm.root_grid.tiles.find_by(position: position).update!(title: title)
end

puts "Seeded: 1 user, 2 mandalas, 2 grids, 18 tiles"
puts "Login: jeff@example.com / password1234"
