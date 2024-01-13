local GUI = require("GUI")
local system = require("System")
local component = require("component")
local localization = system.getCurrentScriptLocalization()
if not component.isAvailable("geolyzer") then
  GUI.alert(localization.geo)
  return
end
if not component.isAvailable("hologram") then
  GUI.alert(localization.holo)
  return
end

local sx, sz = 48, 48
local ox, oz = -24, -24
local starty, stopy = -5

local function validateY(value, min, max, default)
  value = tonumber(value) or default
  if value < min or value > max then
    GUI.alert("invalid y coordinate, must be in [" .. min .. ", " .. max .. "]\n")
    return
  end
  return value
end
 
do
  local args = {...}
  starty = validateY(args[1], -32, 31, starty)
  stopy = validateY(args[2], starty, starty + 32, math.min(starty + 32, 31))
end

-- Add a new window to MineOS workspace
local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 60, 20, 0xE1E1E1))

-- Get localization table dependent of current system language


-- Add single cell layout to window
local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))

local scanButton = layout:addChild(GUI.button(2, 2, 30, 3, 0xFFFFFF, 0x555555, 0x3C3C3C, 0xFFFFFF, localization.scan))
scanButton.onTouch = function()
  component.hologram.clear()
  for x=ox,sx+ox do
    for z=oz,sz+oz do
      local hx, hz = 1 + x - ox, 1 + z - oz
      local column = component.geolyzer.scan(x, z, false)
      for y=1,1+stopy-starty do
        local color = 0
        if column then
          local hardness = column[y + starty + 32]
          if hardness == 0 or not hardness then
            color = 0
          elseif hardness < 3 then
            color = 2
          elseif hardness < 100 then
            color = 1
          else
            color = 3
          end
        end
        if component.hologram.maxDepth() > 1 then
          component.hologram.set(hx, y, hz, color)
        else
          component.hologram.set(hx, y, hz, math.min(color, 1))
        end
      end
      --os.sleep(0)
    end
  end
end

-- Create callback function with resizing rules when window changes its' size
window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  layout.width, layout.height = newWidth, newHeight
end

---------------------------------------------------------------------------------

-- Draw changes on screen after customizing your window
workspace:draw()
