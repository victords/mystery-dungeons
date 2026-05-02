require("lib.index")
require("src.game")

function love.load()
  Image.set_retro(true)
  controller = Game
  controller.init()
end

function love.update(dt)
  controller.update()
  --print(love.timer.getFPS())
end

function love.draw()
  Window.draw(function()
    controller.draw()
  end)
end
