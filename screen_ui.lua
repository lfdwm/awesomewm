-- Module for setting up overall screen UI per screen
-- This includes the taglist, tasklist, wallpaper, systray, etc.

local config = require("config")
local beautiful = require("beautiful")
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local module = {}

-- Mouse bindings for taglist
local taglist_buttons = gears.table.join(
  -- Left click: view tag, hide all others
  awful.button({}, 1, function(t) t:view_only() end),

  -- Mod + left click: move focused client to tag
  awful.button({ config.modkey }, 1, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
    end
  end),

  -- Right click: view tag
  awful.button({}, 3, awful.tag.viewtoggle),

  -- Mod + right click: assign client to additional tag
  awful.button({ config.modkey }, 3, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end),

  -- Scroll: switch between tags
  awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Mouse bindings for tasklist
local tasklist_buttons = gears.table.join(
  -- Left click: minimize / activate + raise client
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      c:emit_signal(
        "request::activate",
        "tasklist",
        {raise = true}
      )
    end
  end),

  -- Right click: Show client list of all clients globally
  awful.button({ }, 3, function()
    awful.menu.client_list({ theme = { width = 250 } })
  end),
  
  -- Scroll: switch focus between clients
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
  end),
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
  end)
)

-- Wallpaper shenanigans
local set_wallpaper = function (s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    --gears.wallpaper.maximized(wallpaper, s, false, {x=0,y=-70})
    if s == screen.primary then
      gears.wallpaper.centered(wallpaper, s, "black", 1)
    else
      gears.wallpaper.centered(wallpaper, s, "black", 1)
    end
  end
end
module.set_wallpaper = set_wallpaper

-- Set up new screen
local keyboardlayout_widget = awful.widget.keyboardlayout()
local textclock_widget = wibox.widget.textclock()
module.setup_new_screen = function(s)
  set_wallpaper(s)

  -- [1] [2] [3] [4] [5] [6] [7] [8] [9] run: ...   | nvim        | firefox     |           🔊 Wed Apr 17, 19:13 ☰
  s.prompt_box = awful.widget.prompt() --↑

  s.layout_box = awful.widget.layoutbox(s) ----------------------------------------------------------------------↑
  s.layout_box:buttons(
    gears.table.join(
      awful.button({ }, 1, function () awful.layout.inc( 1) end),   -- left click goes to next
      awful.button({ }, 3, function () awful.layout.inc(-1) end),   -- right click goes to prev
      awful.button({ }, 4, function () awful.layout.inc( 1) end),   -- scroll up goes to next
      awful.button({ }, 5, function () awful.layout.inc(-1) end)    -- scroll down goes to prev
    )
  )

  -- Set up tags named 1-9 on the screen with default layout
  -- [1] [2] [3] [4] [5] [6] [7] [8] [9] run: ...   | nvim        | firefox     |           🔊 Wed Apr 17, 19:13 ☰
  -- ↑_________________________________↑
  --                |
  awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])
  s.tag_list = awful.widget.taglist {
    screen  = s,
    filter  = awful.widget.taglist.filter.all,
    buttons = taglist_buttons,
    widget_template = {
      {
        {
          {
            -- The text showing the tag index
            id = "index_role",
            widget = wibox.widget.textbox
          },
          left = beautiful.systray_taglist_padding,
          right = beautiful.systray_taglist_padding,
          widget = wibox.container.margin
        },
        shape = gears.shape.rectangle,
        shape_border_color = "#ffffff",
        shape_border_width = 1,
        widget = wibox.container.background
      },
      id = "background_role",
      widget = wibox.container.background,

      -- Insert tag index into index_role on creation / update:
      create_callback = function (self, c3, index, objects)
        self:get_children_by_id("index_role")[1].markup = "<span size=\"x-large\">"..index.."</span>"
      end,
      update_callback = function (self, c3, index, objects)
        self:get_children_by_id("index_role")[1].markup = "<span size=\"x-large\">"..index.."</span>"
      end
    }
  }

  -- [1] [2] [3] [4] [5] [6] [7] [8] [9] run: ...   | nvim        | firefox     |           🔊 Wed Apr 17, 19:13 ☰
  --                                                ↑___________________________↑
  s.task_list = awful.widget.tasklist { --------------------------'
    screen  = s,
    filter  = awful.widget.tasklist.filter.currenttags,
    buttons = tasklist_buttons,
    layout = {
      spacing = 10,
      spacing_widget = {
        {
          thickness = 1,
          span_ratio = 0.5,
          color = "#ffffff",
          widget = wibox.widget.separator
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
      },
      max_widget_size = 200,
      layout = wibox.layout.flex.horizontal
    },
    widget_template = {
      {
        {
          {
            {
              id     = 'clienticon',
              widget = awful.widget.clienticon,
            },
            margins = 7,
            widget  = wibox.container.margin,
          },
          {
            id     = 'text_role',
            ellipsize = "end",
            widget = wibox.widget.textbox,
          },
          layout = wibox.layout.fixed.horizontal,
        },
        right = 10,
        widget = wibox.container.margin
      },
      id     = 'background_role',
      widget = wibox.container.background,
      create_callback = function(self, c, index, objects)
        self:get_children_by_id("clienticon")[1].client = c
      end
    }
  }

  -- [1] [2] [3] [4] [5] [6] [7] [8] [9] run: ...   | nvim        | firefox     |           🔊 Wed Apr 17, 19:13 ☰
  s.systray = wibox.widget.systray() -------------------------------------------------------↑
  s.systray:set_base_size(24)

  -- Create the top bar
  s.top_bar = awful.wibar({ position = "top", screen = s, height=beautiful.systray_height})
  s.top_bar:setup {
    layout = wibox.layout.align.horizontal,
    {
      -- Left widgets
      layout = wibox.layout.fixed.horizontal,
      s.tag_list,
      s.prompt_box,
    },
    {
      -- Task list
      s.task_list,
      widget = wibox.container.margin,
      left = beautiful.systray_tasklist_margin ,
      right = beautiful.systray_tasklist_margin 
    },
    {
      -- Right widgets
      layout = wibox.layout.fixed.horizontal,
      {
        {
          s.systray,
          margins = 4,
          widget = wibox.container.margin
        },
        widget = wibox.container.background,
        bg = beautiful.bg_systray
      },
      {
        {
          keyboardlayout_widget,
          textclock_widget,
          {
            s.layout_box,
            margins = 4,
            widget = wibox.container.margin
          },
          layout = wibox.layout.align.horizontal
        },
        left = 4,
        widget = wibox.container.margin
      },
    },
  }
end

return module
