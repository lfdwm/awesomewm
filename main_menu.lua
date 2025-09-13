-- Defines the Mod+W menu and returns an awful.menu instance

local config = require("config")
local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")

local awesome_menu = {
  { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
  { "manual", config.terminal .. " -e man awesome" },
  { "edit config", config.editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", function() awesome.quit() end },
}

local xprop_menu = {
  { "gamemoded", config.terminal .. " -e fish -c \"gamemoded -r (sleep 0.25; xprop | grep PID | cut -d= -f2)\"" },
  { "kill", "bash -c \"kill $(xprop | grep PID | cut -d= -f2)\"" },
  { "kill -9", "bash -c \"kill -9 $(xprop | grep PID | cut -d= -f2)\"" },
}

last_translate_cmd = ""
function translator(ocr, trans)
  return function()
    local cmd = "translateOcr "..ocr.." "..trans
    awful.spawn(cmd)
    last_translate_cmd = cmd 
  end
end

local ocr_menu = {
  { "en",         translator("eng", "en")},
  { "jpn",        translator("jpn", "ja")},
  { "jpn_vert",   translator("jpn_vert", "ja")},
  { "chi_sim",    translator("chi_sim", "zh-TW")},
  { "chi_tra",    translator("chi_tra", "zh-TW")},
  { "kor",        translator("kor", "ko")},
  { "kor_vert",   translator("kor_vert", "ko")}
}

local main_menu = awful.menu({
  items = {
    { "   awesome", awesome_menu, beautiful.awesome_icon },
    { "   thunar", "thunar" },
    { "󰈍   gucharmap", "gucharmap" },
    { "   xprop", xprop_menu },
    --{ "ocr", ocr_menu },
    { "󰄘   scrcpy", "scrcpy" },
    { "   open terminal", config.terminal }
  }
})

return main_menu
