return {
  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
      notification = {
        override_vim_notify = true,
        view = {
            reflow = true
        },
        window = {
          max_width = 0.5,
        },
      },
    },
  },
}
