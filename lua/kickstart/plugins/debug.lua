-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go and C++, but can
-- be extended to other languages as well.

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  keys = {
    -- Basic debugging keymaps, feel free to change to your liking!
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Set Breakpoint',
    },
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: See last session result.',
    },
    -- Additional helpful debug commands
    {
      '<leader>dr',
      function()
        require('dap').repl.open()
      end,
      desc = '[D]ebug: Open [R]EPL',
    },
    {
      '<leader>dl',
      function()
        require('dap').run_last()
      end,
      desc = '[D]ebug: Run [L]ast',
    },
    {
      '<leader>dh',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = '[D]ebug: [H]over Variables',
      mode = { 'n', 'v' },
    },
    {
      '<leader>dp',
      function()
        require('dap.ui.widgets').preview()
      end,
      desc = '[D]ebug: [P]review',
      mode = { 'n', 'v' },
    },
    {
      '<leader>dt',
      function()
        require('dap').terminate()
      end,
      desc = '[D]ebug: [T]erminate',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
        'codelldb', -- C/C++ Debugger
      },
    }

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Keep UI open after program exits for debugging
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    -- Comment these out to keep UI open after program ends
    -- dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    -- dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- [[ C++ / C / Rust Configuration ]] --

    -- 1. Setup the Adapter (codelldb)
    -- This tells DAP how to talk to the debugger binary installed by Mason
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        -- COMMAND: This points to the codelldb installed by Mason
        command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
        args = { '--port', '${port}' },
        -- On windows you may need to uncomment this:
        -- detached = false,
      },
    }

    -- Helper function to find CMake executable in build directory
    local function find_cmake_executable()
      local cwd = vim.fn.getcwd()
      local build_dir = cwd .. '/build'

      -- Check if build directory exists
      if vim.fn.isdirectory(build_dir) == 0 then
        vim.notify('Build directory not found at: ' .. build_dir, vim.log.levels.ERROR)
        return vim.fn.input('Path to executable: ', cwd .. '/', 'file')
      end

      -- Try to find the executable based on your CMakeLists.txt project name
      local executable = build_dir .. '/check_cpp23'

      if vim.fn.filereadable(executable) == 1 then
        -- Check if it's actually executable
        local stat = vim.loop.fs_stat(executable)
        if stat and stat.type == 'file' then
          -- Return the absolute path
          local abs_path = vim.fn.fnamemodify(executable, ':p')
          vim.notify('Found executable: ' .. abs_path, vim.log.levels.INFO)
          return abs_path
        else
          vim.notify('File exists but may not be executable: ' .. executable, vim.log.levels.WARN)
        end
      else
        vim.notify('Executable not found at: ' .. executable, vim.log.levels.ERROR)
      end

      -- If not found, search for any executables in build directory
      vim.notify('Searching for executables in build directory...', vim.log.levels.INFO)
      local handle = io.popen('find "' .. build_dir .. '" -maxdepth 1 -type f -executable 2>/dev/null')
      if handle then
        local result = handle:read '*a'
        handle:close()
        local executables = {}
        for line in result:gmatch '[^\r\n]+' do
          -- Skip CMake internal files
          if not line:match 'CMake' and not line:match '%.cmake' then
            table.insert(executables, line)
            vim.notify('Found: ' .. line, vim.log.levels.INFO)
          end
        end
        if #executables == 1 then
          local abs_path = vim.fn.fnamemodify(executables[1], ':p')
          vim.notify('Using: ' .. abs_path, vim.log.levels.INFO)
          return abs_path
        elseif #executables > 1 then
          vim.notify('Multiple executables found, please select one', vim.log.levels.WARN)
        else
          vim.notify('No executables found in build directory', vim.log.levels.ERROR)
        end
      end

      -- If still not found, let user select manually with full path
      local input = vim.fn.input('Path to executable: ', build_dir .. '/', 'file')
      if input ~= '' then
        return vim.fn.fnamemodify(input, ':p')
      end
      return nil
    end

    -- 2. Setup the Configuration
    -- This tells DAP how to launch your specific program
    dap.configurations.cpp = {
      {
        name = 'Launch CMake Project (Debug)',
        type = 'codelldb',
        request = 'launch',
        program = function()
          local exe = find_cmake_executable()
          if not exe then
            vim.notify('No executable found!', vim.log.levels.ERROR)
            return nil
          end
          vim.notify('Launching: ' .. exe, vim.log.levels.INFO)
          return exe
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
        runInTerminal = false,
        -- Source path remapping - critical for breakpoints to work
        sourceMap = {
          ['/usr/include'] = '/usr/include',
        },
        relativePathBase = '${workspaceFolder}',
        -- Important: Wait for debugger to fully attach
        setupCommands = {
          {
            text = '-enable-pretty-printing',
            description = 'Enable pretty printing',
            ignoreFailures = false,
          },
        },
      },
      {
        name = 'Launch CMake Project (Stop at Entry)',
        type = 'codelldb',
        request = 'launch',
        program = function()
          local exe = find_cmake_executable()
          if not exe then
            vim.notify('No executable found!', vim.log.levels.ERROR)
            return nil
          end
          vim.notify('Launching: ' .. exe, vim.log.levels.INFO)
          return exe
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = true, -- This will pause at main()
        args = {},
        runInTerminal = false,
        -- Source path remapping
        sourceMap = {
          ['/usr/include'] = '/usr/include',
        },
        relativePathBase = '${workspaceFolder}',
        setupCommands = {
          {
            text = '-enable-pretty-printing',
            description = 'Enable pretty printing',
            ignoreFailures = false,
          },
        },
      },
      {
        name = 'Launch file (manual path)',
        type = 'codelldb',
        request = 'launch',
        program = function()
          local path = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
          if path ~= '' then
            local abs_path = vim.fn.fnamemodify(path, ':p')
            vim.notify('Debug target: ' .. abs_path, vim.log.levels.INFO)
            -- Verify file exists and is executable
            if vim.fn.filereadable(abs_path) == 0 then
              vim.notify('ERROR: File not readable: ' .. abs_path, vim.log.levels.ERROR)
              return nil
            end
            return abs_path
          end
          return nil
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
      },
      {
        name = 'Attach to process',
        type = 'codelldb',
        request = 'attach',
        pid = function()
          return tonumber(vim.fn.input 'PID: ')
        end,
        cwd = '${workspaceFolder}',
      },
    }

    -- Use the same config for C and Rust
    dap.configurations.c = dap.configurations.cpp
    dap.configurations.rust = dap.configurations.cpp

    -- Add visual indicators for debugging (Nerd Font compatible)
    vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = '' })
    vim.fn.sign_define('DapLogPoint', { text = '', texthl = 'DapLogPoint', linehl = '', numhl = '' })

    -- Highlight groups for better visibility
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#555530' })
    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' }) -- Red for active breakpoint
    vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#f79617' }) -- Orange for conditional
    vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#6c6c6c' }) -- Gray for rejected
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' }) -- Green for current line
    vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' }) -- Blue for log points

    -- Setup which-key groups for debug commands
    local ok, which_key = pcall(require, 'which-key')
    if ok then
      which_key.add {
        { '<leader>d', group = '[D]ebug' },
        { '<F1>', desc = 'Debug: Step Into' },
        { '<F2>', desc = 'Debug: Step Over' },
        { '<F3>', desc = 'Debug: Step Out' },
        { '<F5>', desc = 'Debug: Start/Continue' },
        { '<F7>', desc = 'Debug: Toggle UI' },
      }
    end
  end,
}
