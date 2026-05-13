return function(dap)
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

  local function runtime_dir()
    local dir = vim.fn.getenv("XDG_RUNTIME_DIR")
    if dir == vim.NIL or dir == "" then
      dir = vim.loop.os_tmpdir()
    end
    return dir
  end

  local function build_shell_command(command, args, config)
    local cmd_parts = {}
    for k, v in pairs(config.env or {}) do
      table.insert(cmd_parts, k .. "=" .. vim.fn.shellescape(v))
    end
    table.insert(cmd_parts, vim.fn.shellescape(command))
    for _, a in ipairs(args) do
      table.insert(cmd_parts, vim.fn.shellescape(a))
    end

    return table.concat(cmd_parts, " ")
  end

  local function spawn_rdbg(command, args, config)
    local shell_command = build_shell_command(command, args, config)

    local stdout = vim.loop.new_pipe(false)
    local stderr = vim.loop.new_pipe(false)

    local handle
    handle = vim.loop.spawn("bash", {
      args = { "-l", "-c", shell_command },
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
  end

  -----------------------------------------------------------------------
  -- Adapter: Ruby rdbg (requires 'debug' gem in Gemfile)
  -----------------------------------------------------------------------
  dap.adapters.ruby_socket = function(callback, config)
    local target = config.script or config.program
    assert(target, "ruby DAP launch config requires `script` or `program`")

    local sock_path = runtime_dir() .. "/rdbg-" .. vim.fn.getpid()
    os.remove(sock_path)

    local args = {
      "--command",
      "--open",
      "--stop-at-load",
      "--sock-path=" .. sock_path,
      "--",
    }
    if config.bundle then
      table.insert(args, "bundle")
      table.insert(args, "exec")
    end
    table.insert(args, config.command or "ruby")
    table.insert(args, target)
    for _, a in ipairs(config.args or {}) do
      table.insert(args, a)
    end

    spawn_rdbg("rdbg", args, config)

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
    local args = vim.deepcopy(config.args or {})

    if config.bundle then
      command = "bundle"
      args = vim.list_extend({ "exec", default_command }, args)
    end

    local rewritten_args = {}
    local inserted_sock_path = false
    local i = 1
    while i <= #args do
      local arg = args[i]

      if arg == "--port" then
        i = i + 2
      elseif vim.startswith(arg, "--port=") then
        i = i + 1
      else
        table.insert(rewritten_args, arg)
        if arg == "-O" and not inserted_sock_path then
          table.insert(rewritten_args, "--sock-path=${pipe}")
          inserted_sock_path = true
        end
        i = i + 1
      end
    end

    if not inserted_sock_path then
      table.insert(rewritten_args, 1, "--sock-path=${pipe}")
      table.insert(rewritten_args, 1, "-O")
    end

    callback({
      type = "pipe",
      pipe = "${pipe}",
      executable = {
        command = "bash",
        args = { "-l", "-c", build_shell_command(command, rewritten_args, config) },
        cwd = config.cwd or vim.fn.getcwd(),
        detached = true,
      }
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
