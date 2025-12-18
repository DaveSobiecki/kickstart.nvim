-- debug.lua
--
-- DAP (Debug Adapter Protocol) configuration for C++ debugging
--

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
  },
  keys = {
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
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: Toggle UI',
    },
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
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'delve',
        'codelldb',
      },
    }

    -- Dap UI setup with proper UTF-8 icons
    dapui.setup {
      icons = {
        expanded = '▾',
        collapsed = '▸',
        current_frame = '→',
      },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = '◀',
          run_last = '↻',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.25 },
            { id = 'breakpoints', size = 0.25 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            { id = 'repl', size = 0.5 },
            { id = 'console', size = 0.5 },
          },
          size = 10,
          position = 'bottom',
        },
      },
    }

    -- Auto-open UI when debugging starts
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Go debugging setup
    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0,
      },
    }

    -- [[ C++ / C / Rust Configuration ]] --

    -- Setup codelldb adapter
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = vim.fn.stdpath 'data' .. '/mason/bin/codelldb',
        args = { '--port', '${port}' },
      },
    }

    -- Helper function to find CMake executable
    local function find_cmake_executable()
      local cwd = vim.fn.getcwd()

      -- Try multiple common build directory patterns
      local build_dirs = {
        cwd .. '/build',
        cwd .. '/build/Debug',
        cwd .. '/build/Release',
        cwd .. '/cmake-build-debug',
        cwd .. '/cmake-build-release',
      }

      -- First, try to get target from cmake-tools if available
      local cmake_target = vim.g.cmake_current_target
      if cmake_target and cmake_target ~= '' then
        for _, build_dir in ipairs(build_dirs) do
          local exe = build_dir .. '/' .. cmake_target
          if vim.fn.filereadable(exe) == 1 then
            local abs_path = vim.fn.fnamemodify(exe, ':p')
            vim.notify('Found CMake target: ' .. abs_path, vim.log.levels.INFO)
            return abs_path
          end
        end
      end

      -- Search for executables in all build directories
      for _, build_dir in ipairs(build_dirs) do
        if vim.fn.isdirectory(build_dir) == 1 then
          local scan = vim.loop.fs_scandir(build_dir)
          if scan then
            local executables = {}
            while true do
              local name, type = vim.loop.fs_scandir_next(scan)
              if not name then
                break
              end

              local full_path = build_dir .. '/' .. name
              if type == 'file' then
                -- Skip CMake files, libraries, and object files
                if
                  not name:match 'CMake'
                  and not name:match '%.cmake$'
                  and not name:match '%.so'
                  and not name:match '%.a$'
                  and not name:match '%.o$'
                  and not name:match '%.dylib$'
                  and not name:match '%.dll$'
                then
                  local stat = vim.loop.fs_stat(full_path)
                  if stat then
                    table.insert(executables, full_path)
                  end
                end
              end
            end

            -- If we found exactly one executable, use it
            if #executables == 1 then
              local abs_path = vim.fn.fnamemodify(executables[1], ':p')
              vim.notify('Found executable: ' .. abs_path, vim.log.levels.INFO)
              return abs_path
            elseif #executables > 1 then
              -- Let user choose from multiple executables
              vim.notify('Multiple executables found:', vim.log.levels.INFO)
              for i, exe in ipairs(executables) do
                vim.notify(i .. '. ' .. vim.fn.fnamemodify(exe, ':t'), vim.log.levels.INFO)
              end
              local choice = vim.fn.input('Select executable (1-' .. #executables .. '): ')
              local idx = tonumber(choice)
              if idx and idx >= 1 and idx <= #executables then
                return vim.fn.fnamemodify(executables[idx], ':p')
              end
            end
          end
        end
      end

      -- If nothing found, prompt user
      vim.notify('No executable found automatically', vim.log.levels.WARN)
      local input = vim.fn.input('Path to executable: ', cwd .. '/build/', 'file')
      if input ~= '' then
        return vim.fn.fnamemodify(input, ':p')
      end
      return nil
    end

    -- C++ Debug Configurations (simplified to avoid duplicates)
    dap.configurations.cpp = {
      {
        name = 'Launch CMake Project',
        type = 'codelldb',
        request = 'launch',
        program = function()
          local exe = find_cmake_executable()
          if not exe then
            vim.notify('No executable found!', vim.log.levels.ERROR)
            return nil
          end
          return exe
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = function()
          local input = vim.fn.input 'Program arguments: '
          return vim.split(input, ' ', { trimempty = true })
        end,
        runInTerminal = false,
        console = 'integratedTerminal',
        setupCommands = {
          {
            text = '-enable-pretty-printing',
            description = 'Enable pretty printing',
            ignoreFailures = false,
          },
        },
      },
      {
        name = 'Launch (Stop at Entry)',
        type = 'codelldb',
        request = 'launch',
        program = function()
          local exe = find_cmake_executable()
          if not exe then
            vim.notify('No executable found!', vim.log.levels.ERROR)
            return nil
          end
          return exe
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = true,
        args = function()
          local input = vim.fn.input 'Program arguments: '
          return vim.split(input, ' ', { trimempty = true })
        end,
        runInTerminal = false,
        console = 'integratedTerminal',
        setupCommands = {
          {
            text = '-enable-pretty-printing',
            description = 'Enable pretty printing',
            ignoreFailures = false,
          },
        },
      },
      {
        name = 'Launch (Manual Path)',
        type = 'codelldb',
        request = 'launch',
        program = function()
          local path = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
          if path ~= '' then
            local abs_path = vim.fn.fnamemodify(path, ':p')
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
        args = function()
          local input = vim.fn.input 'Program arguments: '
          return vim.split(input, ' ', { trimempty = true })
        end,
        console = 'integratedTerminal',
      },
      {
        name = 'Attach to Process',
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

    -- Visual indicators for debugging with proper UTF-8 icons
    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
    vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DapBreakpointRejected', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '→', texthl = 'DapStopped', linehl = 'DapStoppedLine', numhl = '' })
    vim.fn.sign_define('DapLogPoint', { text = '◉', texthl = 'DapLogPoint', linehl = '', numhl = '' })

    -- Highlight groups for better visibility
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#555530' })
    vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#f79617' })
    vim.api.nvim_set_hl(0, 'DapBreakpointRejected', { fg = '#6c6c6c' })
    vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#98c379' })
    vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61afef' })

    -- Quick build before debug (F6)
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'cpp', 'c', 'rust' },
      callback = function()
        vim.keymap.set('n', '<F6>', function()
          vim.notify('Building project...', vim.log.levels.INFO)
          local ok_cmake = pcall(vim.cmd, 'CMakeBuild')
          if not ok_cmake then
            vim.notify('CMakeBuild failed - trying make...', vim.log.levels.WARN)
            vim.cmd '!make -C build'
          end
        end, { buffer = true, desc = 'Build project' })
      end,
    })
  end,
}
