return {
  "harrisoncramer/gitlab.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "dlyongemallo/diffview.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  build = function()
    require("gitlab.server").build(true)
  end,
  keys = {
    {
      "<leader>glc",
      function()
        local async = require("gitlab.async")
        local state = require("gitlab.state")
        async.sequence(
          { state.dependencies.merge_requests },
          function()
            local git = require("gitlab.git")
            local u = require("gitlab.utils")
            local reviewer = require("gitlab.reviewer")
            local remote = state.settings.connection_settings.remote

            vim.ui.select(state.MERGE_REQUESTS, {
              prompt = "Choose Merge Request:",
              format_item = function(mr)
                return string.format("!%d - %s (%s → %s)", mr.iid, mr.title, mr.source_branch, mr.target_branch)
              end,
            }, function(mr)
              if not mr then return end

              local branch = mr.source_branch

              if reviewer.is_open then
                reviewer.close()
              end

              if branch ~= git.get_current_branch() then
                local has_clean_tree, err = git.has_clean_tree()
                if err then return end
                if not has_clean_tree then
                  u.notify("Cannot switch branch with uncommitted changes, please stash or commit", vim.log.levels.ERROR)
                  return
                end
              end

              -- Fetch fork branch via merge-request ref if not available locally
              vim.fn.system("git rev-parse --verify " .. branch .. " 2>/dev/null")
              if vim.v.shell_error ~= 0 then
                vim.notify("Fetching MR !" .. mr.iid .. " branch...", vim.log.levels.INFO)
                vim.fn.system(string.format("git fetch %s refs/merge-requests/%d/head:%s", remote, mr.iid, branch))
                if vim.v.shell_error ~= 0 then
                  u.notify("Failed to fetch branch for MR !" .. mr.iid, vim.log.levels.ERROR)
                  return
                end
              end

              vim.schedule(function()
                local _, switch_err = git.switch_branch(branch)
                if switch_err then return end

                vim.schedule(function()
                  state.chosen_mr_iid = mr.iid
                  require("gitlab.server").restart(function()
                    require("gitlab").review()
                  end)
                end)
              end)
            end)
          end
        )()
      end,
      desc = "Choose Merge Request (fork-aware)",
    },
    { "<leader>glr", function() require("gitlab").review() end, desc = "Review current MR" },
  },
  config = function()
    require("gitlab").setup({
      connection_settings = {
        remote = "upstream",
      },
    })
  end,
}
