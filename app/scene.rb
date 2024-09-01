class Scene
  attr_reader :entrances

  def initialize(id)
    @tiles = Array.new(TILES_X) { Array.new(TILES_Y) }

    content = $gtk.read_file("data/scene/#{id}.txt")
    content.each_line.with_index do |line, j|
      if j == 0
        @entrances = line.split("|").map { |s| s.split(",").map(&:to_i) }
        next
      end
      if j == 1
        next
      end

      row = j - 2
      line.chomp.each_char.with_index do |char, col|
        next if char == '_'

        @tiles[col][row] = char == '/' ? -1 : 0
      end
    end

    (0...TILES_X).each do |i|
      (0...TILES_Y).each do |j|
        next unless wall?(i, j)

        up = j == 0 || wall?(i, j - 1) ? 1 : 0
        rt = i == TILES_X - 1 || wall?(i + 1, j) ? 2 : 0
        dn = j == TILES_Y - 1 || wall?(i, j + 1) ? 4 : 0
        lf = i == 0 || wall?(i - 1, j) ? 8 : 0
        @tiles[i][j] = up + rt + dn + lf
      end
    end
    @tileset = Tileset.new(:walls, 4, 4)
  end

  def obstacles_for(obj)
    col = ((obj.x + obj.w * 0.5) / TILE_SIZE).floor
    row = ((obj.y + obj.h * 0.5) / TILE_SIZE).floor
    min_col = [col - 2, 0].max
    max_col = [col + 2, TILES_X - 1].min
    min_row = [row - 2, 0].max
    max_row = [row + 2, TILES_Y - 1].min

    obstacles = []
    (min_col..max_col).each do |i|
      (min_row..max_row).each do |j|
        next unless wall?(i, j)
        obstacles << Block.new(i * TILE_SIZE, j * TILE_SIZE, TILE_SIZE, TILE_SIZE)
      end
    end
    obstacles
  end

  def add_light(obj, radius)
    col = ((obj.x + obj.w * 0.5) / TILE_SIZE).floor
    row = ((obj.y + obj.h * 0.5) / TILE_SIZE).floor
    min_col = [col - radius, 0].max
    max_col = [col + radius, TILES_X - 1].min
    min_row = [row - radius, 0].max
    max_row = [row + radius, TILES_Y - 1].min
    (min_col..max_col).each do |i|
      (min_row..max_row).each do |j|
        distance = Math.sqrt((i - col)**2 + (j - row)**2)
        @light[i][j] -= (255 * (1 - 0.5 * (distance - 1) / (radius - 1))).round
      end
    end
  end

  def update
    @light = Array.new(TILES_X) { Array.new(TILES_Y) { 255 } }
  end

  def draw
    (0..TILES_X).each do |i|
      (0..TILES_Y).each do |j|
        tl = i == 0 || j == 0 || @tiles[i - 1][j - 1]
        tr = i == TILES_X || j == 0 || @tiles[i][j - 1]
        bl = i == 0 || j == TILES_Y || @tiles[i - 1][j]
        br = i == TILES_X || j == TILES_Y || @tiles[i][j]
        if tl && tr && bl && br
          Window.draw_rect((i - 0.5) * TILE_SIZE, (j - 0.5) * TILE_SIZE, TILE_SIZE, TILE_SIZE, 0xff000000, 1)
        end
        next if i == TILES_X || j == TILES_Y

        Window.draw_rect(i * TILE_SIZE, j * TILE_SIZE, TILE_SIZE, TILE_SIZE, @light[i][j] << 24, 2) if @light[i][j] > 0
        next unless wall?(i, j)

        @tileset[@tiles[i][j]].draw(i * TILE_SIZE, j * TILE_SIZE)
      end
    end
  end

  private

  def wall?(i, j)
    @tiles[i][j] && @tiles[i][j] >= 0
  end
end
