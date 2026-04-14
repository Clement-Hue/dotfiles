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

    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("gl", vim.diagnostic.open_float, "Line diagnostics")
    map("[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
    map("]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")

    -- Toggle inlay hints
    map("<leader>ih", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
    end, "Toggle inlay hints")
  end,
})

-- LSP progress notifications (via snacks.notifier)
vim.api.nvim_create_autocmd("LspProgress", {
  ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
  callback = function(ev)
    local value = ev.data.params.value
    if type(value) ~= "table" then
      return
    end
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local name = client and client.name or "LSP"
    if value.kind == "end" then
      vim.notify(name .. ": " .. "Initialization complete", vim.log.levels.INFO, { id = "lsp_progress" })
    else
      local msg = value.title or ""
      if value.message then msg = msg .. " " .. value.message end
      vim.notify(msg, vim.log.levels.INFO, { id = "lsp_progress", title = name })
    end
  end,
})

-- LSP request notifications (show "Searching..." while waiting for a response)
local lsp_method_labels = {
  ["textDocument/references"] = "References",
  ["textDocument/definition"] = "Definition",
  ["textDocument/implementation"] = "Implementation",
  ["textDocument/typeDefinition"] = "Type definition",
  ["callHierarchy/incomingCalls"] = "Incoming calls",
  ["callHierarchy/outgoingCalls"] = "Outgoing calls",
}

vim.api.nvim_create_autocmd("LspRequest", {
  callback = function(args)
    local request = args.data.request
    local label = lsp_method_labels[request.method]
    if not label then
      return
    end

    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local name = client and client.name or "LSP"

    if request.type == "pending" then
      vim.notify(label .. ": Searching...", vim.log.levels.INFO, { id = "lsp_request", title = name })
    elseif request.type == "complete" then
      vim.notify(label .. ": Done", vim.log.levels.INFO, { id = "lsp_request", title = name })
    end
  end,
})
