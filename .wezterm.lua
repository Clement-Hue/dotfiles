local wezterm = require("wezterm")
local act = wezterm.action

-- smart-splits.nvim integration: detect if pane is running Neovim
-- This uses the IS_NVIM user var set by the smart-splits plugin
local function is_vim(pane)
  return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
  h = "Left",
  j = "Down",
  k = "Up",
  l = "Right",
}

-- If the pane is running Neovim, forward the key so smart-splits handles it.
-- Otherwise, do wezterm's native pane navigation/resize.
local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == "resize" and "META" or "CTRL",
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
        }, pane)
      else
        if resize_or_move == "resize" then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

return {
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
    { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "h", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Pane resize: Leader+r, then hjkl repeatedly, Escape/q to exit
    { key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },

    -- Close pane (like :q)
    { key = "q", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

    -- Zoom/toggle pane fullscreen (like tmux z)
    { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

    -- Tabs
    { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "x", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },
    { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

    -- Jump to tab by number (AZERTY: numbers need Shift)
    { key = "mapped:1", mods = "LEADER|SHIFT", action = act.ActivateTab(0) },
    { key = "mapped:2", mods = "LEADER|SHIFT", action = act.ActivateTab(1) },
    { key = "mapped:3", mods = "LEADER|SHIFT", action = act.ActivateTab(2) },
    { key = "mapped:4", mods = "LEADER|SHIFT", action = act.ActivateTab(3) },
    { key = "mapped:5", mods = "LEADER|SHIFT", action = act.ActivateTab(4) },
    { key = "mapped:6", mods = "LEADER|SHIFT", action = act.ActivateTab(5) },
    { key = "mapped:7", mods = "LEADER|SHIFT", action = act.ActivateTab(6) },
    { key = "mapped:8", mods = "LEADER|SHIFT", action = act.ActivateTab(7) },
    { key = "mapped:9", mods = "LEADER|SHIFT", action = act.ActivateTab(8) },

    -- Move tab left/right
    { key = "LeftArrow", mods = "LEADER", action = act.MoveTabRelative(-1) },
    { key = "RightArrow", mods = "LEADER", action = act.MoveTabRelative(1) },

    -- Rename tab (like tmux ,)
    { key = ",", mods = "LEADER", action = act.PromptInputLine({
      description = "Tab name:",
      action = wezterm.action_callback(function(window, _, line)
        if line then window:active_tab():set_title(line) end
      end),
    })},

    -- Copy mode (vim-like visual selection, Leader+V for visual)
    { key = "Space", mods = "LEADER", action = act.ActivateCopyMode },

    -- Quick scroll (behind leader to avoid Neovim Ctrl+u/d conflict)
    { key = "u", mods = "LEADER", action = act.ScrollByPage(-0.5) },
    { key = "d", mods = "LEADER", action = act.ScrollByPage(0.5) },

    -- Search (like / in vim, AZERTY: / needs Shift)
    { key = "mapped:/", mods = "LEADER|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },

    -- Pane navigation (Ctrl+hjkl) — smart-splits aware
    -- When in Neovim, forwards the key so smart-splits handles cross-boundary navigation.
    -- When in a regular pane, does wezterm's native pane switching.
    split_nav("move", "h"),
    split_nav("move", "j"),
    split_nav("move", "k"),
    split_nav("move", "l"),

    -- Pane resize (Alt+hjkl) — smart-splits aware
    split_nav("resize", "h"),
    split_nav("resize", "j"),
    split_nav("resize", "k"),
    split_nav("resize", "l"),

    -- Font size
    { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = act.ResetFontSize },
  },

  key_tables = {
    -- Resize mode: Leader+r, then use hjkl repeatedly, Escape to exit
    resize_pane = {
      { key = "h", action = act.AdjustPaneSize({ "Left", 2 }) },
      { key = "j", action = act.AdjustPaneSize({ "Down", 2 }) },
      { key = "k", action = act.AdjustPaneSize({ "Up", 2 }) },
      { key = "l", action = act.AdjustPaneSize({ "Right", 2 }) },
      { key = "Escape", action = "PopKeyTable" },
      { key = "q", action = "PopKeyTable" },
    },
  },
}
