local wezterm = require 'wezterm';

return {
  font = wezterm.font("JetBrains Mono"), -- set JetBrains Mono as the font
  font_size = 16,                        -- adjust size to your liking
  -- optional: enable ligatures
  harfbuzz_features = { "calt=1", "liga=1" },
  color_scheme = "Abernathy"
}
