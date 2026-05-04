return {
  "danymat/neogen",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>dg", function() require("neogen").generate() end, desc = "Generate annotation" },
  },
  config = function(_, opts)
    -- Patch Ruby config to also extract keyword_parameter nodes (baz:, qux: default)
    local ruby = require("neogen.configurations.ruby")
    local i = require("neogen.types.template").item
    local method = ruby.data.func["method|singleton_method"]["0"]
    local original_extract = method.extract

    method.extract = function(node)
      local res = original_extract(node)

      local nodes_utils = require("neogen.utilities.nodes")
      local extractors = require("neogen.utilities.extractors")
      local kw_nodes = nodes_utils:matching_nodes_from(node, {
        {
          retrieve = "first",
          node_type = "method_parameters",
          subtree = {
            {
              retrieve = "all",
              node_type = "keyword_parameter",
              subtree = { { retrieve = "first", node_type = "identifier", as = i.Parameter, extract = true } },
            },
          },
        },
      })
      local kw_res = extractors:extract_from_matched(kw_nodes)

      res[i.Parameter] = vim.list_extend(res[i.Parameter] or {}, kw_res[i.Parameter] or {})
      return res
    end

    require("neogen").setup(opts)
  end,
}
