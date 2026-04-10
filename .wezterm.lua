local wezterm = require 'wezterm';

return {
  font = wezterm.font("JetBrains Mono"), -- set JetBrains Mono as the font
  font_size = 16,                        -- adjust size to your liking
  -- optional: enable ligatures
  harfbuzz_features = { "calt=1", "liga=1" },
  color_scheme = "Abernathy",
  leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 },
    keys = {
    -- 🧭 Tab navigation
    { key = "n", mods = "LEADER", action = wezterm.action.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = wezterm.action.ActivateTabRelative(-1) },

    -- 🔢 Jump to tab (like tmux)
    { key = "1", mods = "LEADER", action = wezterm.action.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = wezterm.action.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = wezterm.action.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = wezterm.action.ActivateTab(3) },
    { key = "5", mods = "LEADER", action = wezterm.action.ActivateTab(4) },
    { key = "6", mods = "LEADER", action = wezterm.action.ActivateTab(5) },
    { key = "7", mods = "LEADER", action = wezterm.action.ActivateTab(6) },
    { key = "8", mods = "LEADER", action = wezterm.action.ActivateTab(7) },
    { key = "9", mods = "LEADER", action = wezterm.action.ActivateTab(8) },
    { key = "c", mods = "LEADER", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
    { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
      -- 🪟 Split panes (tmux-like)
    { key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "\\", mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

    -- 🔄 Navigate panes (vim-style)
    { key = "h", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = wezterm.action.ActivatePaneDirection("Right") },

    -- 🔁 Resize panes
    { key = "H", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
    { key = "J", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
    { key = "K", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
    { key = "L", mods = "LEADER|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
  },

  key_tables = {
    split_mode = {
      -- Ctrl+a s v → vertical split (left/right)
      { key = "v", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

      -- Ctrl+a s h → horizontal split (top/bottom)
      { key = "h", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    },
  },

}
