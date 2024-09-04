require 'lib/minigl'
require_relative 'constants'
require_relative 'game'

def tick(args)
  start = Time.now
  if args.tick_count.zero?
    G.initialize(screen_width: SCREEN_WIDTH, screen_height: SCREEN_HEIGHT, fullscreen: false)
    Game.init
  end

  KB.update
  if KB.key_pressed?(:escape)
    args.gtk.request_quit
    return
  end

  Game.update

  Window.begin_draw(0xff000000)
  Game.draw
  Window.end_draw
  diff = Time.now - start
  puts diff if diff > 0.01
end
