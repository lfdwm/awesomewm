local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

local main_menu = require("main_menu")
local config = require("config")

-- Returns a list of keybinds that refer to tag #i
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local function tagkeys(i)
  return gears.table.join(
    -- View tag only.
    awful.key(
      { config.modkey }, "#" .. i + 9,
      function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      {description = "view tag #"..i, group = "tag"}
    ),

    -- Toggle tag display.
    awful.key(
      { config.modkey, "Control" }, "#" .. i + 9,
      function ()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      {description = "toggle tag #" .. i, group = "tag"}
    ),

    -- Move client to tag.
    awful.key(
      { config.modkey, "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      {description = "move focused client to tag #" .. i, group = "tag"}
    ),

    -- Toggle tag on focused client.
    awful.key(
      { config.modkey, "Control", "Shift" }, "#" .. i + 9,
      function ()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      {description = "toggle focused client on tag #" .. i, group = "tag"}
    )
  )
end

local globalkeys = gears.table.join(
  -- Mod + Ctrl + k → KeePassXC
  awful.key(
    { "Mod1", "Control" }, "k",
    function ()
      local found = false
      for c in
        awful.client.iterate(function (c)
          return awful.rules.match(c, {class = "KeePassXC"})
        end)
      do
        c:jump_to()
        found = true
      end
      if not found then
        awful.spawn("flatpak run org.keepassxc.KeePassXC")
      end
    end,
    { description="open KeePassXC", group="awesome" }
  ),

  -- Mod + Shift + l → lock screen
  awful.key(
    { config.modkey, "Shift" }, "l",
    function ()
      os.execute("XSECURELOCK_COMPOSITE_OBSCURER=0 XSECURELOCK_NO_COMPOSITE=1 XSECURELOCK_SAVER=saver_xscreensaver xsecurelock")
    end,
    { description="lock screen", group="awesome" }
  ),

  -- Mod + g → toggle useless_gap
  (function ()
    local def_gap = beautiful.useless_gap
    return awful.key(
      { config.modkey,           }, "g",
      function ()
        if beautiful.useless_gap == 0 then
          beautiful.useless_gap = def_gap
        else
          beautiful.useless_gap = 0
        end
      end,
      { description = "toggle gaps", group = "awesome" }
    )
  end)(),

  -- Toggle conky
  awful.key(
    { config.modkey,           }, "c",
    function ()
      p = io.popen("bash -c 'toggleConky'")
      naughty.notify({ text = p:read("*all"), timeout = 3 })
      p:close()
    end,
    { description = "toggle conky", group = "awesome" }
  ),

  -- Mod + shift + t → translate
  awful.key({ config.modkey, "Shift"   }, "t", function () awful.spawn(last_translate_cmd) end),

  -- Mod + ^ → gucharmap
  awful.key({ config.modkey,           }, "dead_diaeresis", function () awful.spawn("gucharmap") end, {description="show gucharmap", group="awesome"}),

  -- Mod + s → toggle hotkey popup
  awful.key({ config.modkey,           }, "s", hotkeys_popup.show_help, { description="show help", group="awesome" }),

  -- Navigate between tags with Mod + arrow keys
  awful.key({ config.modkey,           }, "Left",  awful.tag.viewprev, { description = "view previous", group = "tag" }),
  awful.key({ config.modkey,           }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),

  -- Hop back and forth between tag history
  awful.key({ config.modkey,           }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

  -- Keyboard layout switching
  awful.key({ config.modkey, "Shift"   }, "Left",  function () os.execute("setxkbmap ru") end, { description = "russian", group = "keyboard layout" }),
  awful.key({ config.modkey, "Shift"   }, "Right", function () os.execute("setxkbmap se") end, { description = "swedish", group = "keyboard layout" }),

  -- Switch client using Mod + j/k
  awful.key({ config.modkey,           }, "j", function () awful.client.focus.byidx( 1) end, { description = "focus next by index", group = "client" }),
  awful.key({ config.modkey,           }, "k", function () awful.client.focus.byidx(-1) end, { description = "focus previous by index", group = "client" }),

  -- Show main menu
  awful.key({ config.modkey,           }, "w", function () main_menu:show() end, { description = "show main menu", group = "awesome" }),

  -- Swap client left/right
  awful.key({ config.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1) end, { description = "swap with next client by index", group = "client" }),
  awful.key({ config.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1) end, { description = "swap with previous client by index", group = "client" }),

  -- Switch between screens
  awful.key({ config.modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end, { description = "focus the next screen", group = "screen" }),
  awful.key({ config.modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end, { description = "focus the previous screen", group = "screen" }),

  -- Switch to urgent client
  awful.key({ config.modkey,           }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),

  -- Switch to previous focused client
  awful.key(
    { config.modkey,           }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    { description = "go back", group = "client" }
  ),

  -- Open application switcher
  awful.key(
    { config.modkey, "Shift"   }, "Tab",
    function ()
      awful.menu.menu_keys.down = { "Down", "Alt_L" } -- Navigate thru list with arrow keys or left alt
      awful.menu.clients(
        { theme = { width = 250 } },
        {
          keygrabber=true,
          coords={x=525, y=330} -- TODO: fix positioning
        }
      )
    end,
    { description = "open application switcher", group = "client" }
  ),

  -- Standard programs
  awful.key({ config.modkey,           }, "Return", function () awful.spawn(config.terminal) end, {description = "open a terminal", group = "launcher"}),
  awful.key({ config.modkey, "Control" }, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
  awful.key({ config.modkey, "Shift"   }, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),

  -- Layout modification (client sizes)
  awful.key({ config.modkey,           }, "l", function () awful.tag.incmwfact( 0.05) end, {description = "increase master width factor", group = "layout"}),
  awful.key({ config.modkey,           }, "h", function () awful.tag.incmwfact(-0.05) end, {description = "decrease master width factor", group = "layout"}),

  awful.key({ config.modkey, "Shift"   }, "h", function () awful.tag.incnmaster( 1, nil, true) end, {description = "increase the number of master clients", group = "layout"}),
  awful.key({ config.modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1, nil, true) end, {description = "decrease the number of master clients", group = "layout"}),

  awful.key({ config.modkey, "Control" }, "h", function () awful.tag.incncol( 1, nil, true) end, {description = "increase the number of columns", group = "layout"}),
  awful.key({ config.modkey, "Control" }, "l", function () awful.tag.incncol(-1, nil, true) end, {description = "decrease the number of columns", group = "layout"}),

  -- Switch layout
  awful.key({ config.modkey,           }, "space", function () awful.layout.inc(1)  end, { description = "select next", group = "layout" }),
  awful.key({ config.modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end, { description = "select previous", group = "layout" }),

  -- Restore minimized client
  awful.key(
    { config.modkey, "Shift" }, "n",
    function ()
      local c = awful.client.restore()
      if c then
        c:emit_signal("request::activate", "key.unminimize", {raise = true})
      end
    end,
    { description = "restore minimized", group = "client" }
  ),

  -- Prompt
  awful.key({ config.modkey , "Shift"  }, "r", function () awful.screen.focused().prompt_box:run() end, { description = "run prompt", group = "launcher" }),

  -- Menubar
  awful.key({ config.modkey },            "r", function () menubar.show() end, { description = "show the menubar", group = "launcher" }),

  -- Run lua
  awful.key(
    { config.modkey }, "x",
    function ()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = awful.screen.focused().prompt_box.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end,
    { description = "lua execute prompt", group = "awesome" }
  ),

  -- Tag keybinds
  tagkeys(1),
  tagkeys(2),
  tagkeys(3),
  tagkeys(4),
  tagkeys(5),
  tagkeys(6),
  tagkeys(7),
  tagkeys(8),
  tagkeys(9)
)

return globalkeys
