require 'lib/minigl'
require 'app/game'

def tick(args)
  if args.tick_count.zero?
    G.initialize(window_width: 320, window_height: 180, fullscreen: false)
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
end
