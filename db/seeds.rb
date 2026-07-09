# Seeds are idempotent — safe to re-run.
Tile.destroy_all
Grid.destroy_all
Chart.destroy_all
User.destroy_all

user = User.create!(
  email_address: "jeff@example.com",
  password: "password",
  password_confirmation: "password"
)

# Chart#after_create seeds the root grid, and Grid#after_create seeds its nine
# tiles (positions 0–8). Seeding titles those existing tiles rather than
# creating new ones, which would collide on position.
chart = Chart.create!(title: "My First Mandala", mode: "planning", user: user)
chart.goal_tile.update!(title: "My Goal")

brainstorm = Chart.create!(title: "Brainstorm", mode: "brainstorm", user: user)
{ 0 => "BFP Community", 1 => "June event calendar", 2 => "App development" }.each do |position, title|
  brainstorm.root_grid.tiles.find_by(position: position).update!(title: title)
end

puts "Seeded: 1 user, 2 charts, 2 grids, 18 tiles"
puts "Login: jeff@example.com / password"
