local awful = require("awful")

local conf =  {}

conf.modkey = "Mod4"  -- Usually, Mod4 is the key with a logo between Control and Alt.

conf.beautiful_theme_path = "/home/linus/.config/awesome/theme.lua"

conf.terminal = "alacritty"  -- Default terminal
conf.editor = "nvim"     -- Default editor
conf.editor_cmd = conf.terminal .. " -e " .. conf.editor

conf.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier,
  awful.layout.suit.corner.nw,
  awful.layout.suit.floating,
  -- awful.layout.suit.corner.ne,
  -- awful.layout.suit.corner.sw,
  -- awful.layout.suit.corner.se,
}

return conf
