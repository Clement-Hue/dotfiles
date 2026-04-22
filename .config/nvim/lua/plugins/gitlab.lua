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
        local remote = "upstream"

        -- Read auth from env vars, falling back to .gitlab.nvim file
        local gitlab_token = os.getenv("GITLAB_TOKEN")
        local gitlab_url = os.getenv("GITLAB_URL")
        local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+$", "")
        local config_file = git_root .. "/.gitlab.nvim"
        if vim.fn.filereadable(config_file) == 1 then
          for line in io.lines(config_file) do
            local key, val = line:match("^(%S+)=(%S+)$")
            if key == "auth_token" and not gitlab_token then gitlab_token = val end
            if key == "gitlab_url" and not gitlab_url then gitlab_url = val end
          end
        end
        gitlab_url = gitlab_url or "https://gitlab.com"

        local remote_url = vim.fn.system("git remote get-url " .. remote):gsub("%s+$", "")
        local project_path = remote_url:match("[:/]([^/]+/[^/]+)%.git$")
          or remote_url:match("[:/]([^/]+/[^/]+)$")

        if not project_path or not gitlab_token then
          vim.notify("gitlab.nvim: Could not determine project path or token", vim.log.levels.ERROR)
          return
        end

        local encoded_path = project_path:gsub("/", "%%2F")
        local cmd = string.format(
          'curl -sf --header "PRIVATE-TOKEN: %s" "%s/api/v4/projects/%s/merge_requests?state=opened&per_page=100"',
          gitlab_token, gitlab_url, encoded_path
        )
        local result = vim.fn.system(cmd)
        local ok, mrs = pcall(vim.json.decode, result)
        if not ok or type(mrs) ~= "table" or #mrs == 0 then
          vim.notify("gitlab.nvim: No open MRs found", vim.log.levels.WARN)
          return
        end

        vim.ui.select(mrs, {
          prompt = "Choose Merge Request:",
          format_item = function(mr)
            return string.format("!%d - %s (%s)", mr.iid, mr.title, mr.source_branch)
          end,
        }, function(mr)
          if not mr then return end

          local branch = mr.source_branch

          -- Check if branch exists locally
          vim.fn.system("git rev-parse --verify " .. branch .. " 2>/dev/null")
          if vim.v.shell_error ~= 0 then
            vim.notify("Fetching MR !" .. mr.iid .. " branch...", vim.log.levels.INFO)
            vim.fn.system(string.format(
              "git fetch %s refs/merge-requests/%d/head:%s",
              remote, mr.iid, branch
            ))
            if vim.v.shell_error ~= 0 then
              vim.notify("gitlab.nvim: Failed to fetch branch for MR !" .. mr.iid, vim.log.levels.ERROR)
              return
            end
          end

          vim.fn.system("git checkout " .. branch)
          if vim.v.shell_error ~= 0 then
            vim.notify("gitlab.nvim: Failed to checkout " .. branch, vim.log.levels.ERROR)
            return
          end

          require("gitlab").review()
        end)
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
