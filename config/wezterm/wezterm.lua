local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.color_scheme = 'Solarized Dark Higher Contrast (Gogh)'

-- config.font = wezterm.font 'JetBrains Mono'
-- config.font = wezterm.font('JetBrainsMono Nerd Font')
-- config.font = wezterm.font('FiraCode Nerd Font Mono')
config.font = wezterm.font('Fira Code')
config.font_size = 15
config.hide_tab_bar_if_only_one_tab = true

return config
