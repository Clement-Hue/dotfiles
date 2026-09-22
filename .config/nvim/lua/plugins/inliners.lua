return {
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {
      mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>" },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPre", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = {
        -- Keep indentation guides visible, but make them as subtle as line numbers.
        highlight = "LineNr",
      },
      scope = {
        enabled = true,
        highlight = "Comment",
        include = {
          node_type = {
            ruby = {
              "method",
              "singleton_method",
              "if",
              "elsif",
              "unless",
              "while",
              "until",
              "for",
              "case",
              "begin",
              "module",
              "do_block",
              "block",
            },
          },
        },
      },
    },
  },
  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
    event = "VeryLazy",
  }
}
