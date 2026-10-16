local wezterm = require("wezterm")
local act = wezterm.action
local smart_splits = wezterm.plugin.require("https://github.com/smart-splits-nvim/backend-wezterm")

local config = {
  -- Font
  font = wezterm.font("JetBrains Mono"),
  font_size = 16,
  harfbuzz_features = { "calt=1", "liga=1" },

  -- Appearance
  color_scheme = "Abernathy",
  window_padding = { left = 4, right = 4, top = 4, bottom = 4 },
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,

  -- Leader key: Ctrl+Space (timeout 1s)
  leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 },

  keys = {
    -- Splits (vim-style: v = vertical like :vsplit, s = horizontal like :split)
    { key = "v",          mods = "LEADER",       action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "h",          mods = "LEADER",       action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Close pane (like :q)
    { key = "q",          mods = "LEADER",       action = act.CloseCurrentPane({ confirm = true }) },

    -- Zoom/toggle pane fullscreen (like tmux z)
    { key = "z",          mods = "LEADER",       action = act.TogglePaneZoomState },

    -- Tabs
    { key = "c",          mods = "LEADER",       action = act.SpawnTab("CurrentPaneDomain") },
    { key = "x",          mods = "LEADER",       action = act.CloseCurrentTab({ confirm = true }) },
    { key = "n",          mods = "LEADER",       action = act.ActivateTabRelative(1) },
    { key = "p",          mods = "LEADER",       action = act.ActivateTabRelative(-1) },

    -- fullscreen
    { key = "Enter",      mods = "ALT",          action = wezterm.action.ToggleFullScreen, },
    -- Jump to tab by number (AZERTY: numbers need Shift)
    { key = "mapped:1",   mods = "LEADER|SHIFT", action = act.ActivateTab(0) },
    { key = "mapped:2",   mods = "LEADER|SHIFT", action = act.ActivateTab(1) },
    { key = "mapped:3",   mods = "LEADER|SHIFT", action = act.ActivateTab(2) },
    { key = "mapped:4",   mods = "LEADER|SHIFT", action = act.ActivateTab(3) },
    { key = "mapped:5",   mods = "LEADER|SHIFT", action = act.ActivateTab(4) },
    { key = "mapped:6",   mods = "LEADER|SHIFT", action = act.ActivateTab(5) },
    { key = "mapped:7",   mods = "LEADER|SHIFT", action = act.ActivateTab(6) },
    { key = "mapped:8",   mods = "LEADER|SHIFT", action = act.ActivateTab(7) },
    { key = "mapped:9",   mods = "LEADER|SHIFT", action = act.ActivateTab(8) },

    -- Move tab left/right
    { key = "LeftArrow",  mods = "LEADER",       action = act.MoveTabRelative(-1) },
    { key = "RightArrow", mods = "LEADER",       action = act.MoveTabRelative(1) },

    -- Rename tab (like tmux ,)
    {
      key = ",",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "Tab name:",
        action = wezterm.action_callback(function(window, _, line)
          if line then window:active_tab():set_title(line) end
        end),
      })
    },

    -- Copy mode (vim-like visual selection, Leader+Space for visual)
    { key = "Space",    mods = "LEADER",       action = act.ActivateCopyMode },

    -- Quick scroll (behind leader to avoid Neovim Ctrl+u/d conflict)
    { key = "u",        mods = "LEADER",       action = act.ScrollByPage(-0.5) },
    { key = "d",        mods = "LEADER",       action = act.ScrollByPage(0.5) },

    -- Search (like / in vim, AZERTY: / needs Shift)
    { key = "mapped:/", mods = "LEADER|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },

    -- Font size
    { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },
  },
}

smart_splits.apply_to_config(config, {
  -- Keep Ctrl-h/j/k/l moving among WezTerm panes when Neovim reaches its edge.
  at_edge = "wrap",
})

return config
