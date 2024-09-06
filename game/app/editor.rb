require_relative 'scene'

class EditorScene < Scene
  RENDER_TARGET_ID = :editor_scene
  DISPLAY_WIDTH = 640
  DISPLAY_HEIGHT = 360

  def initialize(id)
    super(id)
  end

  def update; end

  def draw
    $args.outputs[RENDER_TARGET_ID].transient!
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
        if tl && tr && bl && br
          Window.draw_rect((i - 0.5) * TILE_SIZE, (j - 0.5) * TILE_SIZE, TILE_SIZE, TILE_SIZE, 0xff000000, render_target_id: RENDER_TARGET_ID)
        end
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
end

class Editor
  class << self
    def init
      @scene = EditorScene.new(1)
    end

    def update

    end

    def draw
      $args.outputs.solids << { x: 0, y: 0, w: EDITOR_SCREEN_WIDTH, h: EDITOR_SCREEN_HEIGHT, r: 0, g: 0, b: 0, a: 255 }
      @scene.draw
    end
  end
end
