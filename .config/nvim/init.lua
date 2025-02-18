-- [[ Vim options ]]

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

vim.o.breakindent = true
vim.o.undofile = true

-- Autowrite when exiting buffer
vim.o.autowriteall = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Allow command-line to pop up when needed
vim.o.cmdheight = 0

-- NOTE: Leader selection must precede plugins
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Environment files
vim.g.python3_host_prog = '/usr/bin/python3'
vim.env.BASH_ENV = "~/.bash_aliases"

vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "BufWinLeave", "InsertLeave" }, {
  -- nested = true, -- for format on save
  callback = function()
    if vim.bo.filetype ~= "" and vim.bo.buftype == "" then
      vim.cmd "silent! w"
    end
  end,
  desc = "Auto Save",
})

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
      sort = { "alphanum" },
      spec = {
        -- Names
        { '<leader>G', group = 'Git' },
        { '<leader>H', group = 'Help' },
        { '<leader>G', group = 'Git',         mode = { 'v' } },
        { '<leader>',  group = 'Commands' },
        { '\\',        group = 'Diagnostics' },
        { '?',         group = 'Search' },
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
          BS = "B⌴",
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
        "<leader>F",
        function() require("yazi").yazi() end,
        desc = "Files"
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


-- [[ Keymaps (Keychains/key-chains) ]]
-- See `:help vim.keymap.set()`

-- Ignores
vim.api.nvim_del_keymap("", "gx") -- long which-key description
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '||', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', '\\\\', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })

-- Registers, marks
vim.keymap.set('n', '<leader>p', '"0p', { desc = 'Paste yank' })

-- Commands
vim.keymap.set("", ";", ":")
vim.keymap.set('n', '<leader>l', ':b#<cr>', { desc = 'Jump buffer' })
vim.keymap.set('n', '<leader>f', ':Format <cr>', { desc = 'Format' })
vim.keymap.set('n', '<leader>s', ':%s/', { desc = 'Replace' })
vim.keymap.set('n', '<leader>c', ':tabnew | r ! ', { desc = 'Cmd->tab' })
vim.keymap.set('n', '<leader><Tab>', ':tabNext <cr>', { desc = 'Next tab' })

vim.keymap.set('n', 'QQ', ':q! <cr>', { desc = 'Quit, no save' })
vim.keymap.set('n', 'qq', ':q <cr>', { desc = 'Quit' })

local function clip()
  vim.opt.clipboard = 'unnamedplus'
  vim.cmd('normal! "+y')
end

vim.keymap.set('v', '<c-c>', clip, { desc = 'Clip to system' })
vim.keymap.set('v', 'Y', clip, { desc = 'Clip to system' })


-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = require('telescope.themes').get_dropdown {
    mappings = {
      i = {
        ['J'] = "move_selection_next",
        ['K'] = "move_selection_previous",
        ['<C-j>'] = "preview_scrolling_down",
        ['<C-k>'] = "preview_scrolling_up",
        ['<Esc>'] = "close",
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

local telebuilt = require('telescope.builtin')

local function _find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()
  local current_dir = cwd
  if current_file ~= '' then
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

local function grep_git_root()
  telebuilt.live_grep {
    search_dirs = { _find_git_root() },
    prompt_title = 'Grep from Git Root',
  }
end

local function grep_buffer()
  telebuilt.current_buffer_fuzzy_find {
    previewer = false,
    prompt_title = 'Grep Buffer',
  }
end

local function grep_buffers()
  telebuilt.live_grep {
    grep_open_files = true,
    prompt_title = 'Grep Buffers',
  }
end

local function grep_files()
  telebuilt.live_grep {
    prompt_title = 'Grep Files',
  }
end

local function search_home()
  telebuilt.find_files {
    search_dirs = { "~/" },
    hidden = { true },
    prompt_title = 'Find Files from Home',
  }
end

local function search_root()
  telebuilt.find_files {
    search_dirs = { "/" },
    prompt_title = 'Find Files from Root',
  }
end

-- Config
vim.keymap.set('n', '<leader>t', telebuilt.colorscheme, { desc = 'Themes' })
vim.keymap.set('n', '<leader>h', telebuilt.builtin, { desc = 'Help' })

-- Diagnostic group
vim.keymap.set('n', '\\a', telebuilt.diagnostics, { desc = 'Diagnostics list' })

-- Leaders
vim.keymap.set('n', '<leader><space>', telebuilt.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>/', grep_files, { desc = 'Search files' })
vim.keymap.set('n', '<leader>b', telebuilt.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>r', telebuilt.oldfiles, { desc = 'Recents' })
vim.keymap.set('n', '<leader>.', telebuilt.resume, { desc = 'Last search' })

-- Search group
-- Dupes
vim.keymap.set('n', '?f', telebuilt.find_files, { desc = 'Folder' })
vim.keymap.set('n', '?b', telebuilt.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '?r', telebuilt.oldfiles, { desc = 'Recents' })
vim.keymap.set('n', '?.', telebuilt.resume, { desc = 'Last search' })
-- Dupe pairings
vim.keymap.set('n', '?F', grep_files, { desc = 'Folder 🔍' })
vim.keymap.set('n', '?B', grep_buffers, { desc = 'Buffers 🔍' })
-- Grep recent TODO
--
-- Unique
vim.keymap.set('n', '??', grep_buffer, { desc = 'Buffer 🔍' })
vim.keymap.set('n', '?h', search_home, { desc = 'Home' })
vim.keymap.set('n', '?r', search_root, { desc = 'Root' })
vim.keymap.set('n', '?g', telebuilt.git_files, { desc = 'Git' })
vim.keymap.set('n', '?G', grep_git_root, { desc = 'Git 🔍' })
vim.keymap.set('n', '?*', telebuilt.grep_string, { desc = 'Cursor 🔍' })
vim.keymap.set('n', '?d', telebuilt.diagnostics, { desc = 'Diagnostics' })


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'javascript', 'typescript', 'svelte', 'css', 'html', 'vimdoc', 'vim', 'bash' },
    auto_install = true,
    sync_install = false,
    ignore_install = {},
    modules = {},
    highlight = { enable = true },
    indent = { enable = false },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']f'] = '@function.outer',
          [']c'] = '@class.outer',
        },
        goto_next_end = {
          [']F'] = '@function.outer',
          [']C'] = '@class.outer',
        },
        goto_previous_start = {
          ['[f'] = '@function.outer',
          ['[c'] = '@class.outer',
        },
        goto_previous_end = {
          ['[F'] = '@function.outer',
          ['[C'] = '@class.outer',
        },
      },
    },
  }
end, 0)

-- [[ Configure LSPs ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>n', vim.lsp.buf.rename, 'Rename')
  nmap('\\!', vim.lsp.buf.code_action, 'Code action')

  nmap('gd', telebuilt.lsp_definitions, 'Definition')
  nmap('gr', telebuilt.lsp_references, 'References')
  nmap('gI', telebuilt.lsp_implementations, 'Implementation')
  nmap('gy', telebuilt.lsp_type_definitions, 'Type definition')
  nmap('gh', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('gH', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('gD', vim.lsp.buf.declaration, 'Declaration')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
  clangd = { filetypes = { "c", "cpp", "objc", "objcpp", "cuda" } }, -- exclude .proto
  pyright = {},
  svelte = { filetypes = { "svelte" } },
  ts_ls = {},
  tinymist = { filetypes = { "typ" } },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

-- Null-ls pretends it's an LSP
-- Enables Python to format with "LSP" but actually using black
require("mason-null-ls").setup({
  ensure_installed = { "black" }
})
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.black,
  },
})

-- Neodev handles neovim lua-ls (LSP) configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure Wilder ]]
local wilder = require('wilder')
wilder.setup({ modes = { ':', '/', '?' } })

wilder.set_option('pipeline', {
  wilder.branch(
    wilder.cmdline_pipeline(),
    wilder.search_pipeline()
  ),
})

wilder.set_option('renderer', wilder.wildmenu_renderer({
  highlighter = wilder.basic_highlighter(),
}))


-- [[ Configure nvim-cmp completions ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
    autocomplete = false,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if not cmp.visible() then
        cmp.complete()
      elseif cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp', max_item_count = 2, priority_weight = 2 },
    { name = 'luasnip',  max_item_count = 2, priority_weight = 1 },
    { name = 'path',     max_item_count = 2, priority_weight = 1 },
  },
}


-- [[ Custom colors \ themes ]]
local WKGroups = { 'WhichKey', 'WhichKeyTitle', 'WhichKeyNormal', 'WhichKeyDesc', 'WhichKeyGroup', 'WhichKeyBorder' }
for _, group in ipairs(WKGroups) do
  -- FG: Onedark, BG: transparent
  vim.api.nvim_set_hl(0, group, { fg = "#abb2bf", bg = "NONE" })
end
