-- Format on save (only if an LSP client supports formatting)
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    if #vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/formatting" }) > 0 then
      vim.lsp.buf.format({ bufnr = args.buf })
    end
  end,
})

-- Better diagnostics display
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 4,
    source = "if_many",
  },
  float = {
    source = "if_many",
    header = "",
    prefix = "",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = "󰌵 ",
    },
  },
  severity_sort = true,
  underline = true,
  update_in_insert = false,
})

-- LSP keymaps on attach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
    end

    -- Enable inlay hints if the server supports them
    if client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("gt", vim.lsp.buf.type_definition, "Go to type definition")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
    map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
    map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")

    -- Toggle inlay hints
    map("<leader>ih", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
    end, "Toggle inlay hints")
  end,
})
