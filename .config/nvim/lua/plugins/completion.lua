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
        documentation = { auto_show = true },
      },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
  },
}
