-- [[ Vim options ]]

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.o.clipboard = 'unnamedplus'

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
      spec = {
        { '<leader>f', group = 'Format' },
        { '<leader>h', group = 'Git hunks' },
        { '<leader>r', group = 'Rename' },
        { '<leader>s', group = 'Search' },
        { '<leader>h', group = 'Git hunk', mode = { 'v' } },
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
          BS = "BSpace",
          Space = "Space",
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

        map('n', '<leader>hs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })
        map('n', '<leader>ht', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>hT', gs.toggle_deleted, { desc = 'toggle git show deleted' })

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
    "mikavilpas/yazi.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    event = "VeryLazy",
    keys = {
      { "<leader>l", function() require("yazi").yazi() end, desc = "Yazi" },
      -- {
      --   -- Open in the current working directory
      --   "<leader>ff",
      --   function()
      --     require("yazi").yazi(nil, vim.fn.getcwd())
      --   end,
      --   desc = "Open the file manager in nvim's working directory" ,
      -- },
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

-- Enter command mode with ;
vim.keymap.set("", ";", ":")

-- Ignore gx (really long description in which-key)
vim.api.nvim_del_keymap("", "gx")

-- Ignore leader
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic messages
vim.keymap.set('n', '||', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', '\\\\', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })

-- Yanking, pasting stuff
vim.keymap.set('n', '<leader>p', '"0p', { desc = 'Paste from yank' })
vim.cmd 'command! Clip set clipboard=unnamedplus'

-- Moving around buffers and files
vim.keymap.set('n', '<leader>j', ':b#<cr>', { desc = 'Last buffer' })

-- Format stuff
vim.keymap.set('n', '<leader>fj', ':%!jq -n -f /dev/stdin <cr>', { desc = 'Format json in buffer' })
vim.keymap.set('n', '<leader>fp', ':!black % <cr>', { desc = 'Format python in buffer' })
vim.keymap.set('n', '<leader>ff', ':Format <cr>', { desc = ':Format' })

vim.keymap.set('n', '<leader>r', ':%s/', { desc = 'Replace' })

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
        ['J'] = "results_scrolling_up", -- Up/down is swapped from normal vim keys because using "dropdown" theme
        ['K'] = "results_scrolling_down",
        ['<C-j>'] = "preview_scrolling_down",
        ['<C-k>'] = "preview_scrolling_up",
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
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

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      search_dirs = { git_root },
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = 'Recent files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').find_files, { desc = 'Telescope' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'Search buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
local function telescope_find_from_home()
  require("telescope.builtin").find_files({
    search_dirs = { "~/" }
  })
end
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = 'Open files' })
vim.keymap.set('n', '<leader>J', require('telescope.builtin').buffers, { desc = 'Open buffers' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
-- vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', telescope_find_from_home, { desc = '[S]earch from [H]ome' })
vim.keymap.set('n', '<leader>sH', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>\\', require('telescope.builtin').diagnostics, { desc = 'Diagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>t', require('telescope.builtin').colorscheme, { desc = 'Themes' })

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'javascript', 'typescript', 'svelte', 'css', 'html', 'vimdoc', 'vim', 'bash' },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = true,
    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- List of parsers to ignore installing
    ignore_install = {},
    -- You can specify additional Treesitter modules here: -- For example: -- playground = {--enable = true,-- },
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
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
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
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<leader>a'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>A'] = '@parameter.inner',
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

  nmap('gd', require('telescope.builtin').lsp_definitions, 'Definition')
  nmap('gr', require('telescope.builtin').lsp_references, 'References')
  nmap('gI', require('telescope.builtin').lsp_implementations, 'Implementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type definition')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('gD', vim.lsp.buf.declaration, 'Declaration')

  -- Create a command `:Format` local to the LSP buffer
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
  tsserver = {},
  tinymist = { filetypes = { "typ" } },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

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
wilder.setup({modes = {':', '/', '?'}})

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
local WKGroups = {'WhichKey', 'WhichKeyTitle', 'WhichKeyNormal', 'WhichKeyDesc', 'WhichKeyGroup', 'WhichKeyBorder'}
for _, group in ipairs(WKGroups) do
  -- FG: Onedark, BG: transparent
  vim.api.nvim_set_hl(0, group, { fg = "#abb2bf", bg = "NONE" })
end
