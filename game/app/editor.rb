require_relative 'scene'

class EditorScene < Scene
  RENDER_TARGET_ID = :editor_scene
  DISPLAY_WIDTH = 640
  DISPLAY_HEIGHT = 360

  def initialize(id)
    super(id)
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
        Window.draw_rect(i * TILE_SIZE, j * TILE_SIZE, TILE_SIZE, TILE_SIZE, 0x50ff0000, render_target_id: RENDER_TARGET_ID) if @tiles[i][j] == -1
      end
    end

    @objects.each { |o| o.draw(render_target_id: RENDER_TARGET_ID) }

    $args.outputs.sprites << {
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
    @tiles[col][row] = 0
    check_wall_tiles(col, row)
  end

  def add_wall_edge(col, row)
    @tiles[col][row] = -1
    check_wall_tiles(col, row)
  end

  def check_wall_tiles(col, row)
    set_wall_tile(col, row)
    set_wall_tile(col, row - 1) if row > 0
    set_wall_tile(col + 1, row) if col < TILES_X - 1
    set_wall_tile(col, row + 1) if row < TILES_Y - 1
    set_wall_tile(col - 1, row) if col > 0
  end
end

class Editor
  SCENE_SCALE = EditorScene::DISPLAY_WIDTH / SCREEN_WIDTH

  class << self
    def init
      @scene = EditorScene.new(1)
      font = Font.new(:font, 32)
      @buttons = [
        Button.new(10, 10, w: 40, h: 40, anchor: :top_right, font: font, text: '#') { @active_tool = :wall },
        Button.new(10, 60, w: 40, h: 40, anchor: :top_right, font: font, text: '/') { @active_tool = :wall_edge },
        Button.new(10, 160, w: 40, h: 40, anchor: :top_right, font: font, text: 'e') { @active_tool = :entrance },
        Button.new(10, 160, w: 40, h: 40, anchor: :top_right, font: font, text: 'x') { @active_tool = :exit },
      ]
    end

    def update
      @buttons.each(&:update)

      return if @active_tool.nil?
      return unless Mouse.over?(0, 0, EditorScene::DISPLAY_WIDTH, EditorScene::DISPLAY_HEIGHT)

      if Mouse.button_down?(:left)
        col = (Mouse.x / (TILE_SIZE * SCENE_SCALE)).floor
        row = (Mouse.y / (TILE_SIZE * SCENE_SCALE)).floor
        case @active_tool
        when :wall
          @scene.add_wall(col, row)
        when :wall_edge
          @scene.add_wall_edge(col, row)
        end
      end
    end

    def draw
      $args.outputs.solids << { x: 0, y: 0, w: EDITOR_SCREEN_WIDTH, h: EDITOR_SCREEN_HEIGHT, r: 0, g: 0, b: 0, a: 255 }
      @scene.draw
      @buttons.each(&:draw)
    end
  end
end
