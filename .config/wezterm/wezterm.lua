local wezterm = require 'wezterm'

local config = {}

config.font = wezterm.font 'JetBrains Mono'
config.font_size = 15.0

config.hide_tab_bar_if_only_one_tab = true

config.window_decorations = "RESIZE"

return config
