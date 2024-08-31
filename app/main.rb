require 'lib/minigl'

def tick(args)
  if args.tick_count.zero?
    G.initialize(window_width: 320, window_height: 180, fullscreen: false)
    args.state.man = GameObject.new(8, 8, 8, 8, :man)
    args.state.angle = 0
    args.state.obstacles = [
      Block.new(0, -1, Window.width, 1),
      Block.new(-1, 0, 1, Window.height),
      Block.new(Window.width, 0, 1, Window.height),
      Block.new(0, Window.height, Window.width, 1),
    ]
    args.state.ramps = []
  end

  KB.update

  forces = Vector.new
  if KB.key_down?(:left_arrow)
    forces.x -= 1
    args.state.angle = -90
  elsif KB.key_down?(:right_arrow)
    forces.x += 1
    args.state.angle = 90
  elsif KB.key_down?(:up_arrow)
    forces.y -= 1
    args.state.angle = 0
  elsif KB.key_down?(:down_arrow)
    forces.y += 1
    args.state.angle = 180
  end
  args.state.man.move(forces, args.state.obstacles, args.state.ramps, set_speed: true)

  Window.begin_draw(0xff000000)
  args.state.man.draw(angle: args.state.angle, round: true)
  Window.end_draw
end
