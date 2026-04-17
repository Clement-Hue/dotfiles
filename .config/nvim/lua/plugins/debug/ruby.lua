return function(dap)
  -----------------------------------------------------------------------
  -- Adapter: Ruby rdbg (requires 'debug' gem in Gemfile)
  -----------------------------------------------------------------------
  dap.adapters.ruby = function(callback, config)
    local runtime_dir = vim.fn.getenv("XDG_RUNTIME_DIR")
    local sock_path = runtime_dir .. "/rdbg-" .. vim.fn.getpid()
    os.remove(sock_path)

    local env_parts = {}
    for k, v in pairs(config.env or {}) do
      table.insert(env_parts, k .. "=" .. vim.fn.shellescape(v))
    end
    local env_prefix = #env_parts > 0 and table.concat(env_parts, " ") .. " " or ""

    local cmd = env_prefix
        .. "rdbg --command --open --stop-at-load"
        .. " --sock-path=" .. sock_path
        .. " -- bundle exec ruby "
        .. config.script

    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    local handle
    handle = vim.loop.spawn("bash", {
      args = { "-l", "-c", cmd },
      cwd = config.cwd or vim.fn.getcwd(),
      detached = true,
      stdio = { nil, stdout, stderr },
    }, function(code)
      if handle then handle:close() end
      if stdout then stdout:close() end
      if stderr then stderr:close() end
      if code ~= 0 then
        vim.schedule(function()
          vim.notify("rdbg exited with code " .. code, vim.log.levels.WARN)
        end)
      end
    end)

    -- Forward stdout/stderr to DAP console
    local function forward(pipe, category)
      pipe:read_start(function(_, data)
        if data then
          vim.schedule(function()
            local session = dap.session()
            if session then
              session:event_output({ category = category, output = data })
            end
          end)
        end
      end)
    end
    forward(stdout, "stdout")
    forward(stderr, "stderr")

    vim.defer_fn(function()
      callback({ type = "pipe", pipe = sock_path })
    end, 2000)
  end

  -----------------------------------------------------------------------
  -- Configurations
  -----------------------------------------------------------------------
  dap.configurations.ruby = {
    {
      type = "ruby",
      name = "debug current file",
      request = "launch",
      localfs = true,
      command = "ruby",
      script = "${file}",
    },
    {
      type = "ruby",
      name = "Launch pacon server",
      request = "launch",
      script = "bin/server.rb",
      localfs = true,
      env = {
        PACON2_ENVIRONMENT = "development",
        PACON2_HTTP_ENABLED = "enabled",
        PACON2_AMQP_ENABLED = "disabled",
        PACON2_HIBERNATUS_ENABLED = "enabled",
        PACON2_HTTP_PORT = "8080",
      },
    },
  }
end
