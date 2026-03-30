-- [[ Configure plugins with lazy ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  'tpope/vim-sleuth',

  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      flavour = 'mocha',
      color_overrides = {
        mocha = {
          base = '#1a1a26',
          mantle = '#141420',
          crust = '#10101a',
          text = '#cdd6f4',
          subtext1 = '#bac2de',
          subtext0 = '#a6adc8',
          overlay2 = '#9399b2',
          overlay1 = '#7f849c',
          overlay0 = '#6c7086',
        },
      },
    },
    config = function(_, opts)
      require('catppuccin').setup(opts)
      vim.cmd.colorscheme('catppuccin')
    end,
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      cmdline = { view = 'cmdline' },
      presets = {
        bottom_search = true,
        long_message_to_split = true,
      },
    },
  },

  {
    'folke/neoconf.nvim',
    lazy = false,  -- must load before lspconfig
    config = true,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'arkav/lualine-lsp-progress' },
      'saghen/blink.cmp',
    },
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
    'saghen/blink.cmp',
    version = '*',
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
      keymap = {
        preset = 'default',
        ['<Tab>']   = { 'show', 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
      },
      completion = {
        menu = { auto_show = false },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },

  {
    'folke/which-key.nvim',
    opts = {
      preset = "helix",
      delay = 0,
      sort = { "manual" },
      spec = {
        -- Names
        { '<leader>f', group = 'Find' },
        { '<leader>r', group = 'gRep' },
        { '<leader>g', group = 'Git' },
        { '<leader>g', group = 'Git',         mode = { 'v' } },
        { '<leader>',  group = 'Commands' },
        { '\\',        group = 'Diagnostics' },
        { 'g',         group = 'Goto' },
        { ',',         group = 'Conjure' },
        { ']',         group = 'Treesitter->' },
        { '[',         group = '<-Treesitter' },
      },
      icons = {
        breadcrumb = "",
        separator = "",
        group = "",
        ellipsis = "",
        mappings = false,
        colors = false,
        keys = {
          Esc = "Esc",
          BS = "<==",
          Space = "⌴ ",
          Tab = "Tab",
        },
      },
    },
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']', function()
          if vim.wo.diff then
            return ']'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[', function()
          if vim.wo.diff then
            return '['
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        map('v', '<leader>hs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })

        map('n', '<leader>gs', gs.stage_hunk, { desc = 'Stage hunk' })
        map('n', '<leader>gr', gs.reset_hunk, { desc = 'Reset hunk' })
        map('n', '<leader>gS', gs.stage_buffer, { desc = 'Stage buffer' })
        map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
        map('n', '<leader>gR', gs.reset_buffer, { desc = 'Reset buffer' })
        map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview hunk' })
        map('n', '<leader>gb', function()
          gs.blame_line { full = false }
        end, { desc = 'Blame line' })
        map('n', '<leader>gd', gs.diffthis, { desc = 'Diff against index' })
        map('n', '<leader>gD', function()
          gs.diffthis '~'
        end, { desc = 'Diff against last commit' })
        map('n', '<leader>gB', gs.toggle_current_line_blame, { desc = 'Toggle blame' })
        map('n', '<leader>gt', gs.toggle_deleted, { desc = 'Toggle deleted' })

        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },


  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'catppuccin',
        icons_enabled = false,
        component_separators = '',
        section_separators = '',
      },
      sections = {
        lualine_a = { { '%l', type = 'stl' } },
        lualine_b = {},
        lualine_c = { 'diff', 'diagnostics', 'lsp_progress' },
        lualine_x = { { 'filename', path = 1 } },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },


  {
    'ibhagwan/fzf-lua',
  },

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },




  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      terminal = {},
      notifier = { enabled = true },
      lazygit = {
        win = {
          height = 0.98,
          width = 0.98,
        },
      },
    },
    keys = {
      {
        '<leader>gg',
        function() Snacks.lazygit() end,
        desc = 'LazyGit',
      },
      {
        '<leader>gl',
        function() Snacks.lazygit.log() end,
        desc = 'LazyGit log',
      },
      {
        '<leader>gf',
        function() Snacks.lazygit.log_file() end,
        desc = 'LazyGit log (current file)',
      },
    },
  },

  {
    "mikavilpas/yazi.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    keys = {
      {
        "<leader>l",
        function() require("yazi").yazi() end,
        desc = "List files (yazi)"
      },
    },
    ---@type YaziConfig
    opts = {
      open_for_directories = true,
    },
  },


  {
    'stevearc/conform.nvim',
    opts = {
      formatters_by_ft = {
        sql = { 'sql_formatter' },
      },
      formatters = {
        sql_formatter = require('config.formatters').sql_formatter,
      },
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == 'sql' then
          return { timeout_ms = 500 }
        end
      end,
    },
  },

  { import = 'plugins' },

}, {
  git = {
    filter = false,
  },
})
