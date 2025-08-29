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

-- Telescope Keymaps
-- Config
vim.keymap.set('n', '<leader>t', telebuilt.colorscheme, { desc = 'Themes' })
vim.keymap.set('n', '<leader>`', telebuilt.builtin, { desc = 'Help' })

-- Diagnostic group
vim.keymap.set('n', '\\\\a', telebuilt.diagnostics, { desc = 'Diagnostics list' })

-- Leaders
vim.keymap.set('n', '<leader><space>', telebuilt.find_files, { desc = 'Files📜' })
vim.keymap.set('n', '<leader>/', grep_files, { desc = 'Files🔍' })
vim.keymap.set('n', '<leader>?', grep_buffer, { desc = 'Page🔍' })
vim.keymap.set('n', '<leader>b', telebuilt.buffers, { desc = 'Buf📜' })
vim.keymap.set('n', '<leader>B', grep_buffers, { desc = 'Buf🔍' })
vim.keymap.set('n', '<leader>r', telebuilt.git_files, { desc = 'Repo📜' })
vim.keymap.set('n', '<leader>R', grep_git_root, { desc = 'Repo🔍' })
vim.keymap.set('n', '<leader>o', telebuilt.oldfiles, { desc = 'Old📜' })
vim.keymap.set('n', '<leader>h', search_home, { desc = 'Home📜' })
vim.keymap.set('n', '<leader>\\\\', search_root, { desc = 'Root📜' })
-- Grep oldfiles, home, root?
vim.keymap.set('n', '<leader>*', telebuilt.grep_string, { desc = 'Cursor🔍' })
vim.keymap.set('n', '<leader>.', telebuilt.resume, { desc = '↩️Search' })
vim.keymap.set('n', '<leader>d', telebuilt.diagnostics, { desc = 'Diagnostics' })
