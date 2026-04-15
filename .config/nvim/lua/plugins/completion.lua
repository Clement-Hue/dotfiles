return {
  {
    "saghen/blink.cmp",
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = "1.*",
    opts = {
      keymap = {
        preset = "enter",
        ["<C-e>"] = { "hide", "show" },
      },
      completion = {
        list = {
          selection = {
            auto_insert = false,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
          },
        },
        menu = {
          border = "rounded",
          draw = {
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } },
          },
        },
      },
      signature = {
        enabled = true,
        trigger = {
          show_on_insert = true,
        },
        window = {
          border = "rounded",
        },
      },
      sources = {
        default = { "lsp", "lazydev", "ruby_require", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          ruby_require = {
            name = "Ruby Require",
            module = "ruby-require",
            score_offset = 50,
          },
        },
      },
    },
  },
}
