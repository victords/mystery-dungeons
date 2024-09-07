require_relative 'scene'

class EditorScene < Scene
  RENDER_TARGET_ID = :editor_scene
  DISPLAY_WIDTH = 960
  DISPLAY_HEIGHT = 540
  SCALE = DISPLAY_WIDTH / SCREEN_WIDTH

  def initialize(id)
    super(id)
    @font = Font.new(:font, 16)
  end

  def draw
    $args.outputs[RENDER_TARGET_ID].transient!
    $args.outputs[RENDER_TARGET_ID].background_color = [0, 0, 0, 255]
    $args.outputs[RENDER_TARGET_ID].w = SCREEN_WIDTH
    $args.outputs[RENDER_TARGET_ID].h = SCREEN_HEIGHT

    (0...TILES_X).each do |i|
      (0...TILES_Y).each do |j|
        next unless wall?(i, j)
        @tileset[@tiles[i][j]].draw(i * TILE_SIZE, j * TILE_SIZE, render_target_id: RENDER_TARGET_ID)
      end
    end
    (0..TILES_X).each do |i|
      (0..TILES_Y).each do |j|
        tl = i == 0 || j == 0 || @tiles[i - 1][j - 1]
        tr = i == TILES_X || j == 0 || @tiles[i][j - 1]
        bl = i == 0 || j == TILES_Y || @tiles[i - 1][j]
        br = i == TILES_X || j == TILES_Y || @tiles[i][j]
        next unless tl && tr && bl && br
        Window.draw_rect((i - 0.5) * TILE_SIZE, (j - 0.5) * TILE_SIZE, TILE_SIZE, TILE_SIZE, 0xff000000, render_target_id: RENDER_TARGET_ID)
      end
    end
    (0...TILES_X).each do |i|
      (0...TILES_Y).each do |j|
        Window.draw_rect(i * TILE_SIZE, j * TILE_SIZE, TILE_SIZE, TILE_SIZE, 0x50ffff00, render_target_id: RENDER_TARGET_ID) if wall?(i, j)
        Window.draw_rect(i * TILE_SIZE, j * TILE_SIZE, TILE_SIZE, TILE_SIZE, 0x5000ff00, render_target_id: RENDER_TARGET_ID) if @tiles[i][j] == -1
      end
    end

    @entrances.each_with_index do |(col, row), index|
      x = col * TILE_SIZE
      y = row * TILE_SIZE
      Window.draw_rect(x, y, TILE_SIZE, TILE_SIZE, 0xff0000ff, render_target_id: RENDER_TARGET_ID)
      @font.draw_text(index.to_s, SCALE * x, SCALE * y, 0xffffffff)
    end
    @exits.each do |e|
      x = e.col * TILE_SIZE
      y = e.row * TILE_SIZE
      Window.draw_rect(x, y, TILE_SIZE, TILE_SIZE, 0xffff0000, render_target_id: RENDER_TARGET_ID)
      @font.draw_text("#{e.dest_scene},#{e.dest_entrance}", SCALE * x, SCALE * y, 0xffffffff)
    end

    @objects.each { |o| o.draw(render_target_id: RENDER_TARGET_ID) }

    $args.outputs.primitives << {
      path: RENDER_TARGET_ID,
      x: 0,
      y: Window.height - DISPLAY_HEIGHT,
      w: DISPLAY_WIDTH,
      h: DISPLAY_HEIGHT,
      source_w: SCREEN_WIDTH,
      source_h: SCREEN_HEIGHT
    }
  end

  def add_wall(col, row)
    return if existing_object?(col, row)

    @tiles[col][row] = 0
    check_wall_tiles(col, row)
  end

  def add_wall_edge(col, row)
    return if existing_object?(col, row)

    @tiles[col][row] = -1
    check_wall_tiles(col, row)
  end

  def add_entrance(col, row)
    return if @tiles[col][row]
    return if existing_object?(col, row)

    @entrances << [col, row]
  end

  def add_exit(col, row, dest_scene, dest_entr)
    return if @tiles[col][row]
    return if existing_object?(col, row)

    @exits << Exit.new(col, row, dest_scene, dest_entr)
  end

  def add_object(col, row, class_name, args)
    return if @tiles[col][row]
    return if existing_object?(col, row)

    @objects << Object.const_get(class_name).new(col, row, args.split(","))
  end

  def delete_at(col, row)
    if @tiles[col][row]
      @tiles[col][row] = nil
      check_wall_tiles(col, row)
      return
    end

    @entrances.reject! { |(i, j)| i == col && j == row }
    @exits.reject! { |x| x.col == col && x.row == row }
    @objects.reject! { |x| x.col == col && x.row == row }
  end

  def serialize
    lines = [
      @entrances.map { |e| e.join(',') }.join('|'),
      @exits.map { |e| "#{e.col},#{e.row},#{e.dest_scene},#{e.dest_entrance}" }.join('|'),
      @objects.map { |o| "#{o.class},#{o.col},#{o.row}#{o.args ? ",#{o.args.join(',')}" : ''}" }.join('|'),
    ]
    lines += @tiles.transpose.map { |row| row.map { |tile| tile_char_from_number(tile) }.join }
    lines.join("\n")
  end

  private

  def check_wall_tiles(col, row)
    set_wall_tile(col, row)
    set_wall_tile(col, row - 1) if row > 0
    set_wall_tile(col + 1, row) if col < TILES_X - 1
    set_wall_tile(col, row + 1) if row < TILES_Y - 1
    set_wall_tile(col - 1, row) if col > 0
  end

  def existing_object?(col, row)
    return true if @entrances.find { |(i, j)| i == col && j == row }
    return true if @exits.find { |x| x.col == col && x.row == row }
    @objects.find { |x| x.col == col && x.row == row }
  end

  def tile_char_from_number(tile)
    return '_' if tile.nil?
    return '#' if tile >= 0
    '/'
  end
end

class Editor
  OBJECT_FILES_TO_EXCLUDE = %w[base_object index trigger].freeze

  class << self
    def init
      @scene = EditorScene.new(1)
      @exit_dest_scene = 1
      @exit_dest_entr = 0

      @object_names = ($gtk.list_files("app/object").map { |s| s.chomp(".rb") } - OBJECT_FILES_TO_EXCLUDE).map(&:capitalize)
      @object_index = 0

      @level_id = 1

      font = Font.new(:font, 32)
      @controls = [
        (@lbl_tool = Label.new(EditorScene::DISPLAY_WIDTH + 10, 10, font, "[none]", color: 0xffffff)),
        Button.new(10, 10, w: 40, h: 40, anchor: :top_right, font: font, text: '#') { set_tool(:wall) },
        Button.new(10, 60, w: 40, h: 40, anchor: :top_right, font: font, text: '/') { set_tool(:wall_edge) },
        Button.new(10, 110, w: 40, h: 40, anchor: :top_right, font: font, text: 'e') { set_tool(:entrance) },
        Button.new(10, 160, w: 40, h: 40, anchor: :top_right, font: font, text: 'x') { set_tool(:exit) },
        (lbl_dest_scene = Label.new(50, 210, font, '1', anchor: :top_right, color: 0xffffff)),
        Button.new(10, 210, w: 32, h: 32, anchor: :top_right, font: font, text: '>') { @exit_dest_scene += 1; lbl_dest_scene.text = @exit_dest_scene.to_s },
        Button.new(90, 210, w: 32, h: 32, anchor: :top_right, font: font, text: '<') { if @exit_dest_scene > 1; @exit_dest_scene -= 1; lbl_dest_scene.text = @exit_dest_scene.to_s; end },
        (lbl_dest_entr = Label.new(50, 252, font, '0', anchor: :top_right, color: 0xffffff)),
        Button.new(10, 252, w: 32, h: 32, anchor: :top_right, font: font, text: '>') { @exit_dest_entr += 1; lbl_dest_entr.text = @exit_dest_entr.to_s },
        Button.new(90, 252, w: 32, h: 32, anchor: :top_right, font: font, text: '<') { if @exit_dest_entr > 0; @exit_dest_entr -= 1; lbl_dest_entr.text = @exit_dest_entr.to_s; end },
        Button.new(10, 294, w: 40, h: 40, anchor: :top_right, font: font, text: 'o') { set_tool(:object) },
        (lbl_obj_name = Label.new(50, 344, font, @object_names[0], anchor: :top_right, color: 0xffffff)),
        Button.new(10, 344, w: 32, h: 32, anchor: :top_right, font: font, text: '>') do
          @object_index = (@object_index + 1) % @object_names.size
          lbl_obj_name.text = @object_names[@object_index]
          @txt_obj_args.text = ""
        end,
        Button.new(180, 344, w: 32, h: 32, anchor: :top_right, font: font, text: '<') do
          @object_index = (@object_index - 1) % @object_names.size
          lbl_obj_name.text = @object_names[@object_index]
          @txt_obj_args.text = ""
        end,
        (@txt_obj_args = TextField.new(10, 386, anchor: :top_right, font: font, h: 32)),
        (lbl_level = Label.new(50, 428, font, '1', anchor: :top_right, color: 0xffffff)),
        Button.new(10, 428, w: 32, h: 32, anchor: :top_right, font: font, text: '>') { @level_id += 1; lbl_level.text = @level_id.to_s },
        Button.new(90, 428, w: 32, h: 32, anchor: :top_right, font: font, text: '<') { if @level_id > 1; @level_id -= 1; lbl_level.text = @level_id.to_s; end },
        Button.new(10, 470, h: 40, anchor: :top_right, font: font, text: 'Save') { $gtk.write_file("data/scene/#{@level_id}.txt", @scene.serialize) },
        Button.new(10, 520, h: 40, anchor: :top_right, font: font, text: 'Load') { @scene = EditorScene.new(@level_id) },
      ]
    end

    def update
      @controls.each(&:update)
      return unless Mouse.over?(0, 0, EditorScene::DISPLAY_WIDTH, EditorScene::DISPLAY_HEIGHT)

      col = (Mouse.x / (TILE_SIZE * EditorScene::SCALE)).floor
      row = (Mouse.y / (TILE_SIZE * EditorScene::SCALE)).floor
      if Mouse.button_down?(:left)
        case @active_tool
        when :wall
          @scene.add_wall(col, row)
        when :wall_edge
          @scene.add_wall_edge(col, row)
        when :entrance
          @scene.add_entrance(col, row)
        when :exit
          @scene.add_exit(col, row, @exit_dest_scene, @exit_dest_entr)
        when :object
          @scene.add_object(col, row, @object_names[@object_index], @txt_obj_args.text)
        end
      elsif Mouse.button_down?(:right)
        @scene.delete_at(col, row)
      end
    end

    def draw
      $args.outputs.solids << { x: 0, y: 0, w: EDITOR_SCREEN_WIDTH, h: EDITOR_SCREEN_HEIGHT, r: 0, g: 0, b: 0, a: 255 }
      @scene.draw
      @controls.each(&:draw)

      (1..TILES_X).each { |i| Window.draw_rect(i * TILE_SIZE * EditorScene::SCALE, 0, 1, EditorScene::DISPLAY_HEIGHT, 0x80ffffff) }
      (1..TILES_Y).each { |i| Window.draw_rect(0, i * TILE_SIZE * EditorScene::SCALE, EditorScene::DISPLAY_WIDTH, 1, 0x80ffffff) }
    end

    private

    def set_tool(tool)
      @active_tool = tool
      @lbl_tool.text = "[#{tool}]"
    end
  end
end
