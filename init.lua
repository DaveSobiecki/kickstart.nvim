vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- [[ Basic Keymaps ]]
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window movement
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

-- Custom keymaps
vim.keymap.set('n', '<Leader>;', ':NvimTreeFindFileToggle<CR>', { desc = 'Toggle File tree', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>o', ':OverseerToggle<CR>', { desc = 'Toggle Overseer', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>ro', ':OverseerRun<CR>', { desc = 'Run Overseer Task', noremap = true, silent = true })
vim.keymap.set('n', '<leader>ra', vim.lsp.buf.code_action, { desc = 'Run Code Action (QuickFix)', silent = true })

-- CMake keymaps
vim.keymap.set('n', '<Leader>cg', ':CMakeGenerate<CR>', { desc = '[C]Make [G]enerate', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>cb', ':CMakeBuild<CR>', { desc = '[C]Make [B]uild', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>cr', ':CMakeRun<CR>', { desc = '[C]Make [R]un', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>cd', ':CMakeDebug<CR>', { desc = '[C]Make [D]ebug', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>cs', ':CMakeSelectBuildType<CR>', { desc = '[C]Make [S]elect Build Type', noremap = true, silent = true })
vim.keymap.set('n', '<Leader>ct', ':CMakeSelectBuildTarget<CR>', { desc = '[C]Make Select [T]arget', noremap = true, silent = true })

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require('lazy').setup({
  'numToStr/Comment.nvim',

  {
    'NMAC427/guess-indent.nvim',
    opts = {
      filetype = {
        cpp = {
          tabstop = 2,
          softtabstop = 2,
          shiftwidth = 2,
          expandtab = true,
        },
      },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  {
    'tpope/vim-fugitive',
    lazy = true,
    cmd = { 'Git', 'Gpush', 'Gpull' },
  },

  -- Terminal plugin (required for overseer)
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      direction = 'horizontal',
      close_on_exit = true,
      shell = vim.o.shell,
    },
  },

  {
    'stevearc/overseer.nvim',
    opts = {
      strategy = {
        'toggleterm',
        direction = 'horizontal',
        autos_croll = true,
        quit_on_exit = 'success',
      },
    },
  },

  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    opts = {
      theme = 'doom',
      config = {
        header = {
          '',
          '',
          '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
          '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
          '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
          '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
          '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
          '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
          '',
          '',
        },
        center = {
          { action = 'Telescope find_files', desc = ' Find File', icon = ' ', key = 'f' },
          { action = 'ene | startinsert', desc = ' New File', icon = ' ', key = 'n' },
          { action = 'Telescope oldfiles', desc = ' Recent Files', icon = ' ', key = 'r' },
          { action = 'Telescope live_grep', desc = ' Find Text', icon = ' ', key = 't' },
          { action = 'Lazy', desc = ' Lazy', icon = ' ', key = 'l' },
          { action = 'qa', desc = ' Quit', icon = ' ', key = 'q' },
        },
        footer = function()
          local stats = require('lazy').stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
        end,
      },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>c', group = '[C]Make' },
        { '<leader>d', group = '[D]ebug' },
      },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      filters = { custom = { '^.git$' } },
      view = {
        float = {
          enable = true,
          open_win_config = function()
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            local window_w = screen_w * 0.5
            local window_h = screen_h * 0.8
            local window_w_int = math.floor(window_w)
            local window_h_int = math.floor(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
            return {
              border = 'rounded',
              relative = 'editor',
              row = center_y,
              col = center_x,
              width = window_w_int,
              height = window_h_int,
            }
          end,
        },
        width = function()
          return math.floor(vim.opt.columns:get() * 0.5)
        end,
      },
    },
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },

  -- Enhanced CMake integration with clang and ninja support
  {
    'Civitasv/cmake-tools.nvim',
    lazy = true,
    ft = { 'c', 'cpp', 'cmake' },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/overseer.nvim',
      'akinsho/toggleterm.nvim',
    },
    opts = {
      cmake_command = 'cmake',
      cmake_build_directory = 'build/${variant:buildType}',
      -- Add this section to automate symlinking for Clangd
      cmake_compile_commands_from_lsp_config = false,
      cmake_softlink_compile_commands = true, -- Automatically symlink build/Debug/compile_commands.json to root

      cmake_generate_options = {
        '-DCMAKE_EXPORT_COMPILE_COMMANDS=1',
        '-DCMAKE_C_COMPILER=clang',
        '-DCMAKE_CXX_COMPILER=clang++',
        '-G',
        'Ninja',
      },
      cmake_build_options = {},
      cmake_console_size = 10,
      cmake_console_position = 'belowright',
      cmake_show_console = 'always',
      cmake_dap_configuration = {
        name = 'cpp',
        type = 'codelldb',
        request = 'launch',
        stopOnEntry = false,
        runInTerminal = false,
        console = 'integratedTerminal',
      },
      cmake_executor = {
        name = 'toggleterm',
        opts = {
          direction = 'horizontal',
          close_on_exit = false,
          auto_scroll = true,
        },
      },
      cmake_runner = {
        name = 'toggleterm',
        opts = {
          direction = 'horizontal',
          close_on_exit = false,
          auto_scroll = true,
        },
      },
      cmake_notifications = {
        enabled = true,
        spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
        refresh_rate_ms = 100,
      },
      cmake_virtual_text_support = true,
    },
  },

  -- Improved status line for C++ development
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'auto',
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          'filename',
          {
            function()
              local c_project = vim.g.cmake_current_target or ''
              if c_project == '' then
                return ''
              end
              return '[CMake: ' .. c_project .. ']'
            end,
          },
        },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
    },
  },

  -- Better quickfix window
  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    opts = {},
  },

  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      local harpoon_extensions = require 'harpoon.extensions'
      harpoon:extend(harpoon_extensions.builtins.highlight_current_file())

      local conf = require('telescope.config').values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end
        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      vim.keymap.set('n', '<Leader>e', function()
        toggle_telescope(harpoon:list())
      end, { desc = 'Open harpoon window' })

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():add()
      end, { desc = 'Add a file to harpoon' })

      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      vim.keymap.set('n', '<leader>hp', function()
        harpoon:list():prev()
      end, { desc = 'Go to previous harpoon file' })

      vim.keymap.set('n', '<leader>hn', function()
        harpoon:list():next()
      end, { desc = 'Go to next harpoon file' })

      vim.keymap.set('n', '<leader>1', function()
        harpoon:list():select(1)
      end, { desc = 'Harpoon file 1' })

      vim.keymap.set('n', '<leader>2', function()
        harpoon:list():select(2)
      end, { desc = 'Harpoon file 2' })

      vim.keymap.set('n', '<leader>3', function()
        harpoon:list():select(3)
      end, { desc = 'Harpoon file 3' })

      vim.keymap.set('n', '<leader>4', function()
        harpoon:list():select(4)
      end, { desc = 'Harpoon file 4' })
    end,
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '✘',
            [vim.diagnostic.severity.WARN] = '▲',
            [vim.diagnostic.severity.INFO] = '●',
            [vim.diagnostic.severity.HINT] = '⚑',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        clangd = {
          mason = false,
          cmd = {
            '/usr/bin/clangd',
            '--background-index',
            '--clang-tidy',
            '--experimental-modules-support',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
          root_dir = function(fname)
            return require('lspconfig.util').root_pattern(
              'compile_commands.json',
              'compile_flags.txt',
              '.clangd',
              '.clang-tidy',
              '.clang-format',
              'CMakeLists.txt',
              '.git'
            )(fname)
          end,
          on_new_config = function(new_config, new_cwd)
            local status, cmake = pcall(require, 'cmake-tools')
            if status then
              cmake.clangd_on_new_config(new_config)
            end
          end,
        },
        glsl_analyzer = {
          filetypes = { 'glsl', 'vert', 'frag', 'geom', 'comp', 'tesc', 'tese', 'mesh', 'task', 'rgen', 'rchit', 'rmiss' },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'clang-format',
        'codelldb',
        'glsl_analyzer',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        cpp = { 'clang-format' },
        c = { 'clang-format' },
      },
    },
  },

  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = {
        preset = 'default',
      },
      appearance = {
        nerd_font_variant = 'normal',
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  -- OLD THEME
  -- {
  --   'skylarmb/torchlight.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   opts = {
  --     contrast = 'hard',
  --   },
  -- },
  --
  {
    'Oniup/ignite.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('ignite').setup()
      vim.cmd [[
            syntax enable
            colorscheme ignite
        ]]
    end,
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'cmake',
        'glsl', -- Shader support
        'hlsl', -- DirectX shaders
        'json',
        'yaml',
        'toml',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
  },

  -- GLSL/Shader support
  {
    'tikhomirov/vim-glsl',
    ft = { 'glsl', 'vert', 'frag', 'geom', 'comp', 'tesc', 'tese' },
  },

  -- Enhanced which-key for better discoverability
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = function()
      return {
        preset = 'modern',
        delay = 200,
        icons = {
          mappings = vim.g.have_nerd_font,
        },
        spec = {
          -- File operations
          { '<leader>f', desc = 'Format buffer' },
          { '<leader>;', desc = 'Toggle file tree' },
          { '<leader>e', desc = 'Harpoon telescope' },
          { '<leader>a', desc = 'Add to harpoon' },

          -- CMake group with detailed descriptions
          { '<leader>c', group = 'CMake' },
          { '<leader>cg', desc = 'Generate build files (Clang+Ninja)' },
          { '<leader>cb', desc = 'Build project' },
          { '<leader>cr', desc = 'Run executable' },
          { '<leader>cd', desc = 'Debug with codelldb' },
          { '<leader>cs', desc = 'Select build type (Debug/Release)' },
          { '<leader>ct', desc = 'Select build target' },

          -- Debug group
          { '<leader>d', group = 'Debug' },
          { '<leader>b', desc = 'Toggle breakpoint' },
          { '<leader>B', desc = 'Conditional breakpoint' },
          { '<leader>dr', desc = 'Open debug REPL' },
          { '<leader>dl', desc = 'Run last debug config' },
          { '<leader>dh', desc = 'Hover variable info', mode = { 'n', 'v' } },
          { '<leader>dp', desc = 'Preview value', mode = { 'n', 'v' } },
          { '<leader>dt', desc = 'Terminate debug session' },

          -- Search group
          { '<leader>s', group = 'Search' },
          { '<leader>sh', desc = 'Search help tags' },
          { '<leader>sk', desc = 'Search keymaps' },
          { '<leader>sf', desc = 'Search files' },
          { '<leader>ss', desc = 'Select telescope picker' },
          { '<leader>sw', desc = 'Search current word' },
          { '<leader>sg', desc = 'Live grep (search text)' },
          { '<leader>sd', desc = 'Search diagnostics' },
          { '<leader>sr', desc = 'Resume last search' },
          { '<leader>s.', desc = 'Recent files' },
          { '<leader>s/', desc = 'Search in open files' },
          { '<leader>sn', desc = 'Search Neovim config files' },
          { '<leader>/', desc = 'Fuzzy search current buffer' },
          { '<leader><leader>', desc = 'Find open buffers' },

          -- Toggle group
          { '<leader>t', group = 'Toggle' },
          { '<leader>th', desc = 'Toggle inlay hints' },

          -- Git/Hunk group
          { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
          { '<leader>hs', desc = 'Stage hunk', mode = { 'n', 'v' } },
          { '<leader>hr', desc = 'Reset hunk', mode = { 'n', 'v' } },
          { '<leader>hu', desc = 'Undo stage hunk' },
          { '<leader>hp', desc = 'Preview hunk' },
          { '<leader>hb', desc = 'Blame line' },
          { '<leader>hd', desc = 'Diff this' },
          { '<leader>hD', desc = 'Diff this ~' },

          -- Harpoon navigation
          { '<leader>1', desc = '[1] Harpoon file 1' },
          { '<leader>2', desc = '[2] Harpoon file 2' },
          { '<leader>3', desc = '[3] Harpoon file 3' },
          { '<leader>4', desc = '[4] Harpoon file 4' },
          { '<leader>hp', desc = 'Previous harpoon file' },
          { '<leader>hn', desc = 'Next harpoon file' },

          -- Overseer tasks
          { '<leader>o', desc = 'Toggle Overseer tasks' },
          { '<leader>r', desc = 'Run Overseer task' },

          -- LSP keymaps (shown when LSP is active)
          { 'grn', desc = 'LSP: Rename symbol' },
          { 'gra', desc = 'LSP: Code action', mode = { 'n', 'x' } },
          { 'grr', desc = 'LSP: References' },
          { 'gri', desc = 'LSP: Implementation' },
          { 'grd', desc = 'LSP: Definition' },
          { 'grD', desc = 'LSP: Declaration' },
          { 'grt', desc = 'LSP: Type definition' },
          { 'gO', desc = 'LSP: Document symbols' },
          { 'gW', desc = 'LSP: Workspace symbols' },

          -- Function keys
          { '<F1>', desc = 'Debug: Step Into' },
          { '<F2>', desc = 'Debug: Step Over' },
          { '<F3>', desc = 'Debug: Step Out' },
          { '<F5>', desc = 'Debug: Start/Continue' },
          { '<F6>', desc = 'Build Project' },
          { '<F7>', desc = 'Debug: Toggle UI' },

          -- Terminal
          { '<C-\\>', desc = 'Toggle Terminal' },

          -- Window navigation
          { '<C-h>', desc = 'Left window' },
          { '<C-l>', desc = 'Right window' },
          { '<C-j>', desc = 'Lower window' },
          { '<C-k>', desc = 'Upper window' },

          -- Other
          { '<C-e>', desc = 'Harpoon quick menu' },
          { '<leader>q', desc = 'Diagnostic quickfix list' },
        },
      }
    end,
  },

  -- Graphics programming helper: shader preview (optional but cool)
  {
    'sophacles/vim-processing',
    ft = { 'processing' },
  },

  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = 'CMD',
      config = 'CFG',
      event = 'EVT',
      ft = 'FT',
      init = 'INIT',
      keys = 'KEY',
      plugin = 'PLG',
      runtime = 'RUN',
      require = 'REQ',
      source = 'SRC',
      start = 'GO',
      task = 'TSK',
      lazy = 'ZZZ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
