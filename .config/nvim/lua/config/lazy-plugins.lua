-- [[ Configure plugins with lazy ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
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

  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-sleuth',
  'tpope/vim-obsession',
  'jeetsukumaran/vim-indentwise',

  'gelguy/wilder.nvim',

  -- Allow repl behavior in nvim
  -- Commented out because it takes a long time to load
  {
    "Olical/conjure",
    ft = { "python", "fennel", "python" }, -- etc
    lazy = true,
    init = function()
      -- Conjure config [:help conjure]
      vim.g["conjure#mapping#enable_defaults"] = false
      vim.g["conjure#mapping#prefix"] = ','
      vim.g["conjure#mapping#log_vsplit"] = 'L'
      vim.g["conjure#mapping#log_toggle"] = 'l'
      vim.g["conjure#mapping#log_reset_soft"] = 'r'
      vim.g["conjure#mapping#log_reset_hard"] = 'R'
      vim.g["conjure#mapping#eval_buf"] = 'b'
      vim.g["conjure#mapping#eval_visual"] = 'v'
      vim.g["conjure#mapping#eval_motion"] = 'm'
      vim.g["conjure#mapping#eval_current_form"] = 'c'
      vim.g["conjure#mapping#eval_comment_current_form"] = 'C'
      -- Client config [:help conjure-client-python-stdio]
      vim.g["conjure#client#python#stdio#mapping#start"] = 's'
      vim.g["conjure#client#python#stdio#mapping#stop"] = 'S'
    end,
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim',       opts = {} },
      'folke/neodev.nvim',
    },
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
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
        { '<leader>G', group = 'Git' },
        { '<leader>G', group = 'Git',         mode = { 'v' } },
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
        map({ 'n', 'v' }, ']]', function()
          if vim.wo.diff then
            return ']]'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[[', function()
          if vim.wo.diff then
            return '[['
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

        map('n', '<leader>Gs', gs.stage_hunk, { desc = 'Stage hunk' })
        map('n', '<leader>Gr', gs.reset_hunk, { desc = 'Reset hunk' })
        map('n', '<leader>GS', gs.stage_buffer, { desc = 'Stage buffer' })
        map('n', '<leader>Gu', gs.undo_stage_hunk, { desc = 'Stage hunk' })
        map('n', '<leader>GR', gs.reset_buffer, { desc = 'Reset buffer' })
        map('n', '<leader>Gp', gs.preview_hunk, { desc = 'Preview hunk' })
        map('n', '<leader>Gb', function()
          gs.blame_line { full = false }
        end, { desc = 'Blame line' })
        map('n', '<leader>Gd', gs.diffthis, { desc = 'Diff against index' })
        map('n', '<leader>GD', function()
          gs.diffthis '~'
        end, { desc = 'Diff against last commit' })
        map('n', '<leader>GB', gs.toggle_current_line_blame, { desc = 'Toggle blame' })
        map('n', '<leader>Gt', gs.toggle_deleted, { desc = 'Toggle deleted' })

        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = { "nvim-lua/plenary.nvim", },
    keys = {
      { "<leader>g", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  },

  {
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      require('onedark').setup {
        style = 'dark', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
        code_style = {
          comments = 'none',
        },
        colors = {
          bg0 = '#16181e',
          fg = '#b6bcc7',
        },
      }
      vim.cmd.colorscheme 'onedark'
    end,
  },

  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
  },

  {
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  'windwp/nvim-ts-autotag',

  {
    "luckasRanarison/tailwind-tools.nvim",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- optional
      "neovim/nvim-lspconfig", -- optional
    },
    opts = {} -- your configuration
  },

  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    opts = {
      ensure_installed = { "black" },
    }

  },

  {
    "mikavilpas/yazi.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    keys = {
      {
        "<leader>L",
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
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  }

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})