-- [[ Configure fzf-lua ]]
local fzf = require('fzf-lua')

fzf.setup({
  'max-perf',
  winopts = {
    height = 0.60,
    width  = 0.95,
    row    = 0.40,
    preview = {
      hidden  = 'hidden',
      layout  = 'vertical',
      vertical = 'down:50%',
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

local function _grep_oldfiles()
  local oldfiles = vim.v.oldfiles
  -- Filter to files that exist
  local valid_files = {}
  for _, f in ipairs(oldfiles) do
    if vim.fn.filereadable(f) == 1 then
      table.insert(valid_files, f)
    end
  end
  fzf.live_grep({ files = valid_files })
end

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
vim.keymap.set('n', '<leader>rf', fzf.lgrep_curbuf, { desc = 'Grep buffer' })
vim.keymap.set('n', '<leader>rb', fzf.lines, { desc = 'Grep buffers' })
vim.keymap.set('n', '<leader>ro', _grep_oldfiles, { desc = 'Grep oldfiles' })

-- Grep word under cursor (immediate)
vim.keymap.set('n', '*', fzf.grep_cword, { desc = 'Grep cursor word' })

-- Buffers
vim.keymap.set('n', '<leader>b', fzf.buffers, { desc = 'Buffers' })

-- Resume search (up arrow)
vim.keymap.set('n', '<Up>', fzf.resume, { desc = 'Resume search' })

-- Diagnostics
vim.keymap.set('n', '<leader>d', fzf.diagnostics_document, { desc = 'Diagnostics' })
vim.keymap.set('n', '\\\\a', fzf.diagnostics_workspace, { desc = 'Diagnostics list' })
