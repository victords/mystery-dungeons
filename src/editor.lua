require("src.constants")
require("src.scene")

SCENE_DISPLAY_WIDTH = 960
SCENE_DISPLAY_HEIGHT = 540
SCENE_SCALE = SCENE_DISPLAY_WIDTH / SCREEN_WIDTH

EditorScene = setmetatable({}, Scene)
EditorScene.__index = EditorScene

function EditorScene.new(id)
  local self = Scene.new(id, true)
  setmetatable(self, EditorScene)
  self.canvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)
  return self
end

function EditorScene:draw()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear(BG_COLOR)

  Scene.draw(self)

  for i = 1, TILES_X do
    for j = 1, TILES_Y do
      if self:is_wall(i, j) then Window.draw_rectangle((i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE, {1, 1, 0, 0.2}) end
      if self.tiles[i][j] == -1 then Window.draw_rectangle((i - 1) * TILE_SIZE, (j - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE, {0, 1, 0, 0.2}) end
    end
  end

  love.graphics.setCanvas()
  love.graphics.draw(self.canvas, 0, 0, nil, SCENE_SCALE, SCENE_SCALE)

  for index, e in ipairs(self.entrances) do
    local x = (e[1] - 1) * SCENE_SCALE * TILE_SIZE
    local y = (e[2] - 1) * SCENE_SCALE * TILE_SIZE
    Window.draw_rectangle(x, y, SCENE_SCALE * TILE_SIZE, SCENE_SCALE * TILE_SIZE, {0, 0, 1})
    Editor.font:draw_text(index, x + 2, y + 2)
  end
  for index, e in ipairs(self.exits) do
    local x = (e.col - 1) * SCENE_SCALE * TILE_SIZE
    local y = (e.row - 1) * SCENE_SCALE * TILE_SIZE
    Window.draw_rectangle(x, y, SCENE_SCALE * TILE_SIZE, SCENE_SCALE * TILE_SIZE, {1, 0, 0})
    Editor.font:draw_text(e.dest_scene .. "," .. e.dest_entrance, x + 2, y + 2)
  end
end

function EditorScene:add_wall(col, row)
  if self:existing_object(col, row) then return end

  self.tiles[col][row] = 0
  self:check_wall_tiles(col, row)
end

function EditorScene:add_wall_edge(col, row)
  self.tiles[col][row] = -1
  self:check_wall_tiles(col, row)
end

function EditorScene:add_entrance(col, row)
  if self.tiles[col][row] or self:existing_object(col, row) then return end

  table.insert(self.entrances, {col, row})
end

function EditorScene:add_exit(col, row, dest_scene, dest_entr)
  if self.tiles[col][row] or self:existing_object(col, row) then return end

  table.insert(self.exits, Exit.new(col, row, dest_scene, dest_entr))
end

function EditorScene:add_object(col, row, class_name, args)
  if self:is_wall(col, row) or self:existing_object(col, row) then return end

  local obj = _G[class_name].new(col, row, Utils.split(args, ","))
  obj.class_name = class_name
  table.insert(self.objects, obj)
end

function EditorScene:delete_at(col, row)
  if self.tiles[col][row] then
    self.tiles[col][row] = nil
    self:check_wall_tiles(col, row)
    return
  end

  for i, e in ipairs(self.entrances) do
    if e[1] == col and e[2] == row then
      table.remove(self.entrances, i)
      break
    end
  end
  for i, e in ipairs(self.exits) do
    if e.col == col and e.row == row then
      table.remove(self.exits, i)
      break
    end
  end
  for i, o in ipairs(self.objects) do
    if o.col == col and o.row == row then
      table.remove(self.objects, i)
      break
    end
  end
end

function EditorScene:serialize()
  local lines = {
    Utils.join(Utils.map(self.entrances, function(e) return e[1] .. "," .. e[2] end), "|"),
    Utils.join(Utils.map(self.exits, function(e) return e.col .. "," .. e.row .. "," .. e.dest_scene .. "," .. e.dest_entrance end), "|"),
    Utils.join(Utils.map(self.objects, function(o) return o.class_name .. "," .. o.col .. "," .. o.row .. "," .. (o.args and Utils.join(o.args, ",") or "") end), "|"),
  }
  for j = 1, TILES_Y do
    local line = ""
    for i = 1, TILES_X do
      line = line .. self:tile_char_from_number(i, j)
    end
    table.insert(lines, line)
  end
  return Utils.join(lines, "\n")
end

function EditorScene:check_wall_tiles(col, row)
  self:set_wall_tile(col, row)
  if row > 1 then self:set_wall_tile(col, row - 1) end
  if col < TILES_X then self:set_wall_tile(col + 1, row) end
  if row < TILES_Y then self:set_wall_tile(col, row + 1) end
  if col > 1 then self:set_wall_tile(col - 1, row) end
end

function EditorScene:existing_object(col, row)
  for i, e in ipairs(self.entrances) do
    if e[1] == col and e[2] == row then return true end
  end
  for i, e in ipairs(self.exits) do
    if e.col == col and e.row == row then return true end
  end
  for i, o in ipairs(self.objects) do
    if o.col == col and o.row == row then return true end
  end
end

function EditorScene:tile_char_from_number(i, j)
  local tile = self.tiles[i][j]
  if tile == nil then return "_" end
  if tile >= 0 then return "#" end
  return "/"
end

Editor = {
  init = function ()
    Window.set_size(false, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)
    if not love.filesystem.getInfo("editor") then
      love.filesystem.createDirectory("editor")
    end

    Editor.scene = EditorScene.new(1)
    Editor.exit_dest_scene = 1
    Editor.exit_dest_entr = 1

    Editor.object_names = Utils.map(love.filesystem.getDirectoryItems("src/object"), function(full_name)
      local name = string.gsub(table.remove(Utils.split(full_name, "/")), ".lua", "")
      return Utils.join(Utils.map(Utils.split(name, "_"), function(s) return s:sub(1, 1):upper() .. s:sub(2, -1) end))
    end)
    for i = 1, #Editor.object_names do
      if Editor.object_names[i] == "BaseObject" or Editor.object_names[i] == "Index" then
        table.remove(Editor.object_names, i)
        i = i - 1
      end
    end
    Editor.object_index = 1
    Editor.level_id = 1

    local font = Res.img_font("font", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzÁÉÍÓÚÀÃÕÂÊÔÑÇáéíóúàãõâêôñç0123456789.,:;!?¡¿/\\()[]+-%'\"←→∞$#<>", 1)
    Editor.lbl_tool = Label.new(SCENE_DISPLAY_WIDTH + 10, 10, {font = font, text = "[none]", scale = 2})
    Editor.lbl_dest_scene = Label.new(50, 214, {font = font, text = "1", anchor = "top_right", scale = 2})
    Editor.lbl_dest_entr = Label.new(50, 256, {font = font, text = "1", anchor = "top_right", scale = 2})
    Editor.lbl_obj_name = Label.new(50, 348, {font = font, text = Editor.object_names[1], anchor = "top_right", scale = 2})
    Editor.txt_obj_args = TextField.new(10, 386, {anchor = "top_right", font = font, h = 32, scale = 2})
    Editor.lbl_level = Label.new(50, 432, {font = font, text = "1", anchor = "top_right", scale = 2})

    Editor.controls = {
      Editor.lbl_tool,
      Button.new(10, 10, {w = 40, h = 40, anchor = "top_right", font = font, text = '#', scale = 2}, function () Editor.set_tool("wall") end),
      Button.new(10, 60, {w = 40, h = 40, anchor = "top_right", font = font, text = '/', scale = 2}, function () Editor.set_tool("wall_edge") end),
      Button.new(10, 110, {w = 40, h = 40, anchor = "top_right", font = font, text = 'e', scale = 2}, function () Editor.set_tool("entrance") end),
      Button.new(10, 160, {w = 40, h = 40, anchor = "top_right", font = font, text = 'x', scale = 2}, function () Editor.set_tool("exit") end),
      Editor.lbl_dest_scene,
      Button.new(10, 210, {w = 32, h = 32, anchor = "top_right", font = font, text = '>', scale = 2}, function ()
        Editor.exit_dest_scene = Editor.exit_dest_scene + 1
        Editor.lbl_dest_scene:set_text(tostring(Editor.exit_dest_scene))
      end),
      Button.new(90, 210, {w = 32, h = 32, anchor = "top_right", font = font, text = '<', scale = 2}, function ()
        if Editor.exit_dest_scene > 1 then
          Editor.exit_dest_scene = Editor.exit_dest_scene - 1
          Editor.lbl_dest_scene:set_text(tostring(Editor.exit_dest_scene))
        end
      end),
      Editor.lbl_dest_entr,
      Button.new(10, 252, {w = 32, h = 32, anchor = "top_right", font = font, text = '>', scale = 2}, function ()
        Editor.exit_dest_entr = Editor.exit_dest_entr + 1
        Editor.lbl_dest_entr:set_text(tostring(Editor.exit_dest_entr))
      end),
      Button.new(90, 252, {w = 32, h = 32, anchor = "top_right", font = font, text = '<', scale = 2}, function ()
        if Editor.exit_dest_entr > 1 then
          Editor.exit_dest_entr = Editor.exit_dest_entr - 1
          Editor.lbl_dest_entr:set_text(tostring(Editor.exit_dest_entr))
        end
      end),
      Button.new(10, 294, {w = 40, h = 40, anchor = "top_right", font = font, text = 'o', scale = 2}, function () Editor.set_tool("object") end),
      Editor.lbl_obj_name,
      Button.new(10, 344, {w = 32, h = 32, anchor = "top_right", font = font, text = '>', scale = 2}, function ()
        Editor.object_index = Editor.object_index % #Editor.object_names + 1
        Editor.lbl_obj_name:set_text(Editor.object_names[Editor.object_index])
        Editor.txt_obj_args:set_text("")
      end),
      Button.new(180, 344, {w = 32, h = 32, anchor = "top_right", font = font, text = '<', scale = 2}, function ()
        Editor.object_index = Editor.object_index == 1 and #Editor.object_names or Editor.object_index - 1
        Editor.lbl_obj_name:set_text(Editor.object_names[Editor.object_index])
        Editor.txt_obj_args:set_text("")
      end),
      Editor.txt_obj_args,
      Editor.lbl_level,
      Button.new(10, 428, {w = 32, h = 32, anchor = "top_right", font = font, text = '>', scale = 2}, function ()
        Editor.level_id = Editor.level_id + 1
        Editor.lbl_level:set_text(tostring(Editor.level_id))
      end),
      Button.new(90, 428, {w = 32, h = 32, anchor = "top_right", font = font, text = '<', scale = 2}, function ()
        if Editor.level_id > 1 then
          Editor.level_id = Editor.level_id - 1
          Editor.lbl_level:set_text(tostring(Editor.level_id))
        end
      end),
      Button.new(10, 470, {h = 40, anchor = "top_right", font = font, text = 'Save', scale = 2}, function ()
        love.filesystem.write("editor/" .. Editor.level_id .. ".txt", Editor.scene:serialize())
      end),
      Button.new(10, 520, {h = 40, anchor = "top_right", font = font, text = 'Load', scale = 2}, function ()
        Editor.scene = EditorScene.new(Editor.level_id)
      end),
    }
    Editor.font = font
  end,
  update = function ()
    KB.update()
    Mouse.update()
    for _, c in ipairs(Editor.controls) do c:update() end
    if not Mouse.over(0, 0, SCENE_DISPLAY_WIDTH, SCENE_DISPLAY_HEIGHT) then
      Editor.mouse_pos = nil
      return
    end

    local col = math.floor(Mouse.x / (TILE_SIZE * SCENE_SCALE)) + 1
    local row = math.floor(Mouse.y / (TILE_SIZE * SCENE_SCALE)) + 1
    if Mouse.down("left") then
      if Editor.active_tool == "wall" then
        Editor.scene:add_wall(col, row)
      elseif Editor.active_tool == "wall_edge" then
        Editor.scene:add_wall_edge(col, row)
      elseif Editor.active_tool == "entrance" then
        Editor.scene:add_entrance(col, row)
      elseif Editor.active_tool == "exit" then
        Editor.scene:add_exit(col, row, Editor.exit_dest_scene, Editor.exit_dest_entr)
      elseif Editor.active_tool == "object" then
        Editor.scene:add_object(col, row, Editor.object_names[Editor.object_index], Editor.txt_obj_args.text)
      end
    elseif Mouse.down("right") then
      Editor.scene:delete_at(col, row)
    end

    Editor.mouse_pos = {col, row}
  end,
  draw = function ()
    love.graphics.clear(0, 0, 0)
    Editor.scene:draw()
    for _, c in ipairs(Editor.controls) do c:draw() end

    for i = 1, TILES_X - 1 do
      Window.draw_rectangle(i * TILE_SIZE * SCENE_SCALE, 0, 1, SCENE_DISPLAY_HEIGHT, {0, 0, 0, 0.5})
    end
    for i = 1, TILES_Y - 1 do
      Window.draw_rectangle(0, i * TILE_SIZE * SCENE_SCALE, SCENE_DISPLAY_WIDTH, 1, {0, 0, 0, 0.5})
    end

    if Editor.mouse_pos then
      local text = Editor.mouse_pos[1] .. "," .. Editor.mouse_pos[2]
      Editor.font:draw_text(text, Mouse.x - Editor.font:text_width(text), Mouse.y - Editor.font.height)
    end
  end,
  set_tool = function(tool)
    Editor.active_tool = tool
    Editor.lbl_tool:set_text("[" .. tool .. "]")
  end
}
