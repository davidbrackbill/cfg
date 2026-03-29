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

-- Find files (quick access)
vim.keymap.set('n', '<leader><leader>', fzf.files, { desc = 'Find files' })

-- Find files (leader-f prefix)
vim.keymap.set('n', '<leader>ff', fzf.git_files, { desc = 'Find files (repo)' })
vim.keymap.set('n', '<leader>fc', fzf.files, { desc = 'Find files (cwd)' })
vim.keymap.set('n', '<leader>fo', fzf.oldfiles, { desc = 'Find old files' })

-- Grep (leader-r prefix)
vim.keymap.set('n', '<leader>rr', function()
  fzf.live_grep({ cwd = _find_git_root() })
end, { desc = 'Grep repo' })
vim.keymap.set('n', '<leader>rc', fzf.live_grep, { desc = 'Grep cwd' })
vim.keymap.set('n', '<leader>rb', fzf.lgrep_curbuf, { desc = 'Grep buffer' })
vim.keymap.set('n', '<leader>ro', fzf.lines, { desc = 'Grep buffers' })

-- Grep word under cursor (immediate)
vim.keymap.set('n', '*', fzf.grep_cword, { desc = 'Grep cursor word' })

-- Buffers
vim.keymap.set('n', '<leader>b', fzf.buffers, { desc = 'Buffers' })

-- Resume search (up arrow)
vim.keymap.set('n', '<Up>', fzf.resume, { desc = 'Resume search' })

-- Diagnostics
vim.keymap.set('n', '<leader>d', fzf.diagnostics_document, { desc = 'Diagnostics' })
vim.keymap.set('n', '\\\\a', fzf.diagnostics_workspace, { desc = 'Diagnostics list' })
