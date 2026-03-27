-- [[ Configure fzf-lua ]]
local fzf = require('fzf-lua')

fzf.setup({
  'max-perf',
  winopts = {
    height = 0.40,
    width  = 0.60,
    row    = 0.30,
    preview = {
      hidden  = 'hidden',
      layout  = 'vertical',
      vertical = 'down:40%',
    },
  },
  keymap = {
    fzf = {
      ['esc'] = 'abort',
      ['ctrl-j'] = 'preview-down',
      ['ctrl-k'] = 'preview-up',
    },
  },
  fzf_opts = {
    ['--layout'] = 'reverse',
  },
})

local function _find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()
  local current_dir = cwd
  if current_file ~= '' then
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Config
vim.keymap.set('n', '<leader>t', fzf.colorschemes, { desc = 'Themes' })
vim.keymap.set('n', '<leader>`', fzf.builtin, { desc = 'Help' })

-- Diagnostics
vim.keymap.set('n', '\\\\a', fzf.diagnostics_workspace, { desc = 'Diagnostics list' })

-- Leaders
vim.keymap.set('n', '<leader><space>', fzf.files, { desc = 'Files' })
vim.keymap.set('n', '<leader>/', fzf.live_grep, { desc = 'Grep files' })
vim.keymap.set('n', '<leader>?', fzf.lgrep_curbuf, { desc = 'Grep buffer' })
vim.keymap.set('n', '<leader>b', fzf.buffers, { desc = 'Buffers' })
vim.keymap.set('n', '<leader>B', fzf.lines, { desc = 'Grep buffers' })
vim.keymap.set('n', '<leader>r', fzf.git_files, { desc = 'Repo files' })
vim.keymap.set('n', '<leader>R', function()
  fzf.live_grep({ cwd = _find_git_root() })
end, { desc = 'Grep repo' })
vim.keymap.set('n', '<leader>o', fzf.oldfiles, { desc = 'Old files' })
vim.keymap.set('n', '<leader>h', function()
  fzf.files({ cwd = '~/' })
end, { desc = 'Home files' })
vim.keymap.set('n', '<leader>\\\\', function()
  fzf.files({ cwd = '/' })
end, { desc = 'Root files' })
vim.keymap.set('n', '<leader>*', fzf.grep_cword, { desc = 'Grep cursor word' })
vim.keymap.set('n', '<leader>.', fzf.resume, { desc = 'Resume search' })
vim.keymap.set('n', '<leader>d', fzf.diagnostics_document, { desc = 'Diagnostics' })
