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
    title: i == 4 ? "My Goal" : nil
  )
end

brainstorm = Chart.create!(title: "Brainstorm", mode: "brainstorm", user: user)

brainstorm_grid = Grid.create!(chart: brainstorm, parent_tile_id: nil)

brainstorm_titles = ["BFP Community", "June event calendar", "App development", nil, nil, nil, nil, nil, nil]

brainstorm_titles.each_with_index do |t, i|
  Tile.create!(grid: brainstorm_grid, position: i, title: t)
end

puts "Seeded: 1 user, 2 charts, 2 grids, 18 tiles"
puts "Login: jeff@example.com / password"
