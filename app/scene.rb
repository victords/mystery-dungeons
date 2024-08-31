class Scene
  attr_reader :entrances

  def initialize(id)
    @obstacles = Array.new(TILES_X) { Array.new(TILES_Y) }

    content = $gtk.read_file("data/scene/#{id}.txt")
    content.each_line.with_index do |line, j|
      if j == 0
        @entrances = line.split("|").map { |s| s.split(",").map(&:to_i) }
        next
      end
      if j == 1
        next
      end

      line.chomp.each_char.with_index do |char, i|
        next if char == ' '
        @obstacles[i][j - 2] = Block.new(i * TILE_SIZE, (j - 2) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
      end
    end
    @flat_obstacles = @obstacles.flatten.compact
  end

  def obstacles_for(obj)
    col = ((obj.x + obj.w * 0.5) / TILE_SIZE).floor
    row = ((obj.y + obj.h * 0.5) / TILE_SIZE).floor
    min_col = [col - 2, 0].max
    max_col = [col + 2, TILES_X - 1].min
    min_row = [row - 2, 0].max
    max_row = [row + 2, TILES_Y - 1].min
    @obstacles[min_col..max_col].flat_map { |col| col[min_row..max_row] }.compact
  end

  def draw
    @flat_obstacles.each do |obst|
      Window.draw_rect(obst.x, obst.y, obst.w, obst.h, 0xffffffff)
    end
  end
end
