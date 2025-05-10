--//////////////// Load AwesomeWM libs //////////////////--

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")          -- Utilities such as color parsing and objects
local awful = require("awful")          -- Everything related to window managment
local wibox = require("wibox")          -- Awesome own generic widget framework
local beautiful = require("beautiful")  -- Theme module
local naughty = require("naughty")      -- Notifications
local menubar = require("menubar")      -- XDG menu implementation

-- Slightly ugly import... Implements autofocus things: "allow handle focus when switching tags and other useful corner cases"
require("awful.autofocus")

-- Implements a pop-up widget with keybinds for Awesome, VIM, Tmux, etc.
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

--//////////////// Error handling //////////////////--

do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({
      preset = naughty.config.presets.critical,
      title = "F#!Ck",
      text = tostring(err)
    })
    in_error = false
  end)
end

--//////////////// Setup //////////////////--

local config = require("config")
beautiful.init(config.beautiful_theme_path)

awful.layout.layouts = config.layouts    -- The list of layouts to cycle between
menubar.utils.terminal = config.terminal -- Set the terminal for applications that require it

-- ensure that menubar find flatpak applications
table.insert(menubar.menu_gen.all_menu_dirs, "~/.local/share/flatpak/exports/share/applications")
table.insert(menubar.menu_gen.all_menu_dirs, "/var/lib/flatpak/exports/share/applications")

--//////////////// Pop-up Menu //////////////////--

local main_menu = require("main_menu")

--//////////////// Screen UI //////////////////--

local screen_utils = require("screen_ui")
awful.screen.connect_for_each_screen(screen_utils.setup_new_screen)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", screen_utils.set_wallpaper)

--//////////////// Mouse bindings //////////////////--

root.buttons(gears.table.join(
  awful.button({ }, 3, function () main_menu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))

local clientbuttons = gears.table.join(
  awful.button({ }, 1, function (c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
  end),
  awful.button({ config.modkey }, 1, function (c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.move(c)
  end),
  awful.button({ config.modkey }, 3, function (c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.resize(c)
  end)
)

--//////////////// Key bindings //////////////////--

root.keys(require("global_keybinds"))
local clientkeys = require("client_keybinds")

--//////////////// Client Rules //////////////////--

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = gears.table.join(
  require("rules"),
  {
    -- Default rules
    {
      rule = { },
      properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen
      }
    },
  }
)

--//////////////// Signals //////////////////--

client.connect_signal("manage", function (c)
  -- Set the windows as the slave,
  -- i.e. put it at the end of others instead of setting it master.
  if not awesome.startup then awful.client.setslave(c) end

  if awesome.startup
    and not c.size_hints.user_position
    and not c.size_hints.program_position
  then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

-- Add a titlebar handler to be run if titlebars are enabled in rules
client.connect_signal("request::titlebars", require("client_titlebar"))

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
  c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Apply border color on focused client
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
