return function(dap)
  local function shellescape(value)
    return vim.fn.shellescape(tostring(value))
  end

  local function shell_command(command, args, env)
    local parts = {}

    for key, value in pairs(env or {}) do
      parts[#parts + 1] = key .. "=" .. shellescape(value)
    end

    parts[#parts + 1] = shellescape(command)

    for _, arg in ipairs(args or {}) do
      parts[#parts + 1] = shellescape(arg)
    end

    return table.concat(parts, " ")
  end

  local function runtime_dir()
    local dir = vim.fn.getenv("XDG_RUNTIME_DIR")
    if dir == vim.NIL or dir == "" then
      dir = vim.loop.os_tmpdir()
    end
    return dir
  end

  local function forward_output(pipe, category)
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

  -----------------------------------------------------------------------
  -- Adapter: Ruby rdbg (requires 'debug' gem in Gemfile)
  -----------------------------------------------------------------------
  dap.adapters.ruby_socket = function(callback, config)
    local target = config.script or config.program
    assert(target, "ruby DAP launch config requires `script` or `program`")

    local sock_path = runtime_dir() .. "/rdbg-" .. vim.fn.getpid()
    os.remove(sock_path)

    local ruby_args = {
      "--command",
      "--open",
      "--stop-at-load",
      "--sock-path=" .. sock_path,
      "--",
    }
    if config.bundle == true then
      ruby_args[#ruby_args + 1] = "bundle"
      ruby_args[#ruby_args + 1] = "exec"
    end
    ruby_args[#ruby_args + 1] = config.command or "ruby"
    ruby_args[#ruby_args + 1] = target
    for _, arg in ipairs(config.args or {}) do
      ruby_args[#ruby_args + 1] = arg
    end

    local cmd = shell_command("rdbg", ruby_args, config.env)
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

    forward_output(stdout, "stdout")
    forward_output(stderr, "stderr")

    vim.defer_fn(function()
      callback({ type = "pipe", pipe = sock_path })
    end, 2000)
  end

  -----------------------------------------------------------------------
  -- Adapter: Ruby rdbg for neotest-minitest
  -----------------------------------------------------------------------
  dap.adapters.ruby = function(callback, config)
    local default_command = config.command or "rdbg"
    local command = default_command
    local args = vim.tbl_filter(function(arg)
      return arg ~= "-e" and arg ~= "cont"
    end, config.args or {})

    if config.bundle then
      command = "bundle"
      args = vim.list_extend({ "exec", default_command }, args)
    end
    callback({
      type = "server",
      host = config.host or "127.0.0.1",
      port = assert(config.port, "ruby adapter requires `port`"),
      executable = {
        command = command,
        args = args,
        cwd = config.cwd or vim.fn.getcwd(),
        detached = true,
      },
    })
  end

  -----------------------------------------------------------------------
  -- Adapter: attach to a running rdbg instance via TCP
  -----------------------------------------------------------------------
  dap.adapters.ruby_attach = {
    type = "server",
    host = "127.0.0.1",
    port = 12345,
  }

  -----------------------------------------------------------------------
  -- Configurations
  -----------------------------------------------------------------------
  dap.configurations.ruby = {
    {
      type = "ruby_socket",
      name = "debug current file",
      request = "launch",
      localfs = true,
      command = "ruby",
      bundle = true,
      script = "${file}",
    },
    {
      type = "ruby_attach",
      name = "Attach to rdbg (port 12345)",
      request = "attach",
      bundle = true,
      localfs = true,
    },
    {
      type = "ruby_socket",
      name = "Launch pacon server",
      request = "launch",
      script = "bin/server.rb",
      bundle = true,
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
