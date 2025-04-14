require("lib.index")
require("src.game")
--require("src.editor")

--editor = true

function love.load()
  controller = editor and Editor or Game
  controller.init()
end

function love.update(dt)
  controller.update()
  --print(love.timer.getFPS())
end

function love.draw()
  controller.draw()
end
