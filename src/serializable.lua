Serializable = {}

local function parse_value(value)
  if value == "true" then return true
  elseif value == "false" then return false
  elseif value:find("^-?%d+$") then return tonumber(value)
  else return value
  end
end

function Serializable:serialize()
  if self.serializable_attrs == nil then
    return "_"
  end

  local result = ""
  for _, attr in ipairs(self.serializable_attrs) do
    result = result .. tostring(self[attr]) .. ","
  end
  return result:sub(1, -2)
end

function Serializable:deserialize(data)
  if self.serializable_attrs == nil or data == nil or data == "_" then
    return
  end

  local values = Utils.split(data, ",")
  for i, value in ipairs(values) do
    local attr = self.serializable_attrs[i]
    self[attr] = parse_value(value)
  end
end
