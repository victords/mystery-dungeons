require 'lib/minigl'
require_relative 'constants'
require_relative 'game'
require_relative 'editor'

$editor = true

def tick(args)
  start = Time.now
  if args.tick_count.zero?
    G.initialize(
      screen_width: $editor ? EDITOR_SCREEN_WIDTH : SCREEN_WIDTH,
      screen_height: $editor ? EDITOR_SCREEN_HEIGHT : SCREEN_HEIGHT,
      fullscreen: false
    )
    $editor ? Editor.init : Game.init
  end

  KB.update
  if KB.key_pressed?(:escape)
    args.gtk.request_quit
    return
  end

  if $editor
    Mouse.update
    Editor.update
  else
    Game.update
  end

  Window.begin_draw
  $editor ? Editor.draw : Game.draw
  Window.end_draw

  diff = Time.now - start
  puts diff if diff > 0.01
end
