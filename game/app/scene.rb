require_relative 'object/index'

class Exit
  attr_reader :col, :row, :x, :y, :w, :h, :dest_scene, :dest_entrance

  def initialize(col, row, dest_scene, dest_entrance)
    @col = col
    @row = row
    @x = col * TILE_SIZE + 2
    @y = row * TILE_SIZE + 2
    @w = TILE_SIZE - 4
    @h = TILE_SIZE - 4
    @dest_scene = dest_scene
    @dest_entrance = dest_entrance
  end
end

class Scene
  attr_reader :entrances, :exits, :triggers

  def initialize(id)
    @tiles = Array.new(TILES_X) { Array.new(TILES_Y) }
    @objects = []
    @solids = []
    @triggers = []
    @triggered_by = {}

    content = $gtk.read_file("data/scene/#{id}.txt")
    content.each_line.with_index do |line, j|
      if j == 0
        @entrances = line.split("|").map { |s| s.split(",").map(&:to_i) }
        next
      end
      if j == 1
        @exits = line.split("|").map { |s| Exit.new(*s.split(",").map(&:to_i)) }
        next
      end
      if j == 2
        next if line.chomp.empty?

        obj_data = line.chomp.split("|").map { |s| s.split(",") }
        obj_data.each do |data|
          @objects << (obj = Object.const_get(data[0]).new(data[1].to_i, data[2].to_i, data[3..]))
          @triggers << obj if obj.trigger?
          @solids << obj if obj.solid?
          if obj.triggered_by_id
            @triggered_by[obj.triggered_by_id] ||= []
            @triggered_by[obj.triggered_by_id] << obj
          end
        end
        next
      end

      row = j - 3
      line.chomp.each_char.with_index do |char, col|
        next if char == '_'

        @tiles[col][row] = char == '/' ? -1 : 0
      end
    end

    (0...TILES_X).each do |i|
      (0...TILES_Y).each do |j|
        set_wall_tile(i, j)
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
    obstacles + @solids.select(&:solid?)
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

  def on_trigger(trigger)
    return if trigger.active?

    trigger.activate
    @triggered_by[trigger.id]&.each(&:on_trigger)
  end

  def update
    @light = Array.new(TILES_X) { Array.new(TILES_Y) { 255 } }
    @objects.each { |o| o.update(self) }
  end

  def draw
    (0..TILES_X).each do |i|
      (0..TILES_Y).each do |j|
        tl = i == 0 || j == 0 || @tiles[i - 1][j - 1]
        tr = i == TILES_X || j == 0 || @tiles[i][j - 1]
        bl = i == 0 || j == TILES_Y || @tiles[i - 1][j]
        br = i == TILES_X || j == TILES_Y || @tiles[i][j]
        if tl && tr && bl && br
          Window.draw_rect((i - 0.5) * TILE_SIZE, (j - 0.5) * TILE_SIZE, TILE_SIZE, TILE_SIZE, 0xff000000, -1)
        end
        next if i == TILES_X || j == TILES_Y

        Window.draw_rect(i * TILE_SIZE, j * TILE_SIZE, TILE_SIZE, TILE_SIZE, @light[i][j] << 24, 1) if @light[i][j] > 0
        next unless wall?(i, j)

        @tileset[@tiles[i][j]].draw(i * TILE_SIZE, j * TILE_SIZE, z_index: -2)
      end
    end

    @objects.each(&:draw)
  end

  private

  def wall?(i, j)
    @tiles[i][j] && @tiles[i][j] >= 0
  end

  def set_wall_tile(i, j)
    return unless wall?(i, j)

    up = j == 0 || wall?(i, j - 1) ? 1 : 0
    rt = i == TILES_X - 1 || wall?(i + 1, j) ? 2 : 0
    dn = j == TILES_Y - 1 || wall?(i, j + 1) ? 4 : 0
    lf = i == 0 || wall?(i - 1, j) ? 8 : 0
    @tiles[i][j] = up + rt + dn + lf
  end
end
