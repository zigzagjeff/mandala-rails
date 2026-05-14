# Seeds are idempotent — safe to re-run
Tile.destroy_all
Grid.destroy_all
Chart.destroy_all
User.destroy_all

user = User.create!(
  email_address: "jeff@example.com",
  password: "password",
  password_confirmation: "password"
)

chart = Chart.create!(title: "My First Mandala", mode: "planning", user: user)

root_grid = Grid.create!(chart: chart, parent_tile_id: nil)

9.times do |i|
  Tile.create!(
    grid: root_grid,
    position: i,
    content: i == 4 ? "My Goal" : nil
  )
end

center_tile = root_grid.tiles.find_by(position: 4)
child_grid = Grid.create!(chart: chart, parent_tile: center_tile)

9.times do |i|
  Tile.create!(grid: child_grid, position: i, content: nil)
end

puts "Seeded: 1 user, 1 chart, 2 grids, 18 tiles"
puts "Login: jeff@example.com / password"
puts "Center tile type: #{center_tile.tile_type}"
