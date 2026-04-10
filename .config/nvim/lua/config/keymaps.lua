-- [[ Keymaps ]]
-- See `:help vim.keymap.set()`

-- Ignores
vim.api.nvim_del_keymap("", "gx") -- long which-key description
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Commands
vim.keymap.set("", ";", ":")
vim.keymap.set('c', '<c-k>', '<up>')
vim.keymap.set('c', '<c-j>', '<down>')
vim.keymap.set('n', 'QQ', ':q! <cr>', { desc = 'Quit, no save' })
vim.keymap.set('n', 'qq', ':q <cr>', { desc = 'Quit' })

local function clip()
  vim.opt.clipboard = 'unnamedplus'
  vim.cmd('normal! "+y')
end
vim.keymap.set('v', '<c-c>', clip, { desc = 'Clip to system' })
vim.keymap.set('v', 'Y', clip, { desc = 'Clip to system' })

vim.keymap.set('n', '||', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', '\\\\', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Go to next diagnostic message' })

-- Paste mappings
vim.keymap.set('n', 'p', '"0p', { desc = 'Paste yank after' })
vim.keymap.set('n', 'P', '"0P', { desc = 'Paste yank before' })
vim.keymap.set('v', 'p', '"0p', { desc = 'Paste yank after' })
vim.keymap.set('v', 'P', '"0P', { desc = 'Paste yank before' })
vim.keymap.set('n', '<C-p>', '"1p', { desc = 'Paste delete after' })
vim.keymap.set('n', '<C-P>', '"1P', { desc = 'Paste delete before' })
vim.keymap.set('v', '<C-p>', '"1p', { desc = 'Paste delete after' })
vim.keymap.set('v', '<C-P>', '"1P', { desc = 'Paste delete before' })

-- Copy +line /abs/path to clipboard (openable with: nvim $VAR)
vim.keymap.set('n', '<leader>c', function()
  local ref = '+' .. vim.fn.line('.') .. ' ' .. vim.fn.expand('%:p')
  vim.fn.setreg('+', ref)
  vim.notify(ref)
end, { desc = 'Copy file position' })

-- Leaders
vim.keymap.set('n', '<leader>s', ':%s/', { desc = 'Sub text' })
vim.keymap.set('n', '<leader>;', ':tab term ', { desc = 'Term' })
vim.keymap.set('n', '<leader><Tab>', ':tabNext <cr>', { desc = 'Next tab' })
vim.keymap.set('n', '<leader>l', ':buffer #<cr>', { desc = 'Last buffer' })
local gh_window = nil

local function format_date(git_date)
  -- Parse git date: "Thu Feb 5 11:44:43 2026 -0600"
  local month_str, day, time, year = git_date:match('(%a+)%s+(%d+)%s+([%d:]+)%s+(%d+)')

  if not month_str then return git_date end

  local yy = year:sub(-2)  -- last 2 digits of year
  return string.format('%s %02d %s', month_str, tonumber(day), yy)
end

vim.keymap.set('n', '<leader>gh', function()
  if gh_window and vim.api.nvim_win_is_valid(gh_window) then
    vim.api.nvim_win_close(gh_window, true)
    gh_window = nil
    return
  end

  local line = vim.fn.line('.')
  local file = vim.fn.expand('%')
  local cmd = string.format('git log -n 5 -p -L %d,%d:%s', line, line, file)
  local output = vim.fn.systemlist(cmd)

  -- Parse output for line content and metadata
  local current_author, current_date
  local entries = {}

  for _, l in ipairs(output) do
    if l:match('^Author:') then
      current_author = l:match('^Author:%s+(.-)%s*<')
    elseif l:match('^Date:') then
      current_date = format_date(l:match('^Date:%s+(.+)'))
    elseif l:match('^%+') and not l:match('^%+%+%+') then
      local content = l:sub(2)  -- strip leading +
      table.insert(entries, {date = current_date, content = content, author = current_author})
    end
  end

  if #entries == 0 then
    return
  end

  -- Calculate max content length for alignment
  local max_content_len = 0
  for _, entry in ipairs(entries) do
    max_content_len = math.max(max_content_len, string.len(entry.content))
  end

  -- Build display lines with proper alignment
  local history_lines = {}
  local highlight_ranges = {}  -- {line_idx, col_start, col_end, hl_group}

  for i, entry in ipairs(entries) do
    local date_col = entry.date
    local content_col = entry.content
    local author_col = entry.author

    local line = string.format('%-13s  %-' .. max_content_len .. 's  %s', date_col, content_col, author_col)

    table.insert(history_lines, line)

    -- Track highlight ranges: date (0-13), content (16 to 16+max_content_len), author (after)
    table.insert(highlight_ranges, {line_idx = #history_lines - 1, date_start = 0, date_end = 13})
    table.insert(highlight_ranges, {line_idx = #history_lines - 1, content_start = 16, content_end = 16 + max_content_len})
    table.insert(highlight_ranges, {line_idx = #history_lines - 1, author_start = 16 + max_content_len + 2, author_end = -1})

    if i < #entries then
      table.insert(history_lines, '')  -- blank line between entries
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, history_lines)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)

  -- Color code: dates, content, authors with different colors
  for _, hl in ipairs(highlight_ranges) do
    if hl.date_start then
      vim.api.nvim_buf_add_highlight(buf, -1, 'Comment', hl.line_idx, hl.date_start, hl.date_end)
    elseif hl.content_start then
      vim.api.nvim_buf_add_highlight(buf, -1, 'String', hl.line_idx, hl.content_start, hl.content_end)
    elseif hl.author_start then
      vim.api.nvim_buf_add_highlight(buf, -1, 'Identifier', hl.line_idx, hl.author_start, hl.author_end)
    end
  end

  gh_window = vim.api.nvim_open_win(buf, false, {
    relative = 'cursor',
    width = math.max(100, string.len(history_lines[1]) + 4),
    height = math.min(#history_lines + 2, 10),
    col = 0,
    row = 1,
    border = 'rounded',
    style = 'minimal',
    focusable = false,
  })

  -- Auto-close on cursor move
  vim.api.nvim_create_autocmd('CursorMoved', {
    buffer = vim.api.nvim_get_current_buf(),
    callback = function()
      if gh_window and vim.api.nvim_win_is_valid(gh_window) then
        vim.api.nvim_win_close(gh_window, true)
        gh_window = nil
      end
      return true
    end,
    once = true,
  })
end, { noremap = true, silent = true, desc = 'Show/hide line history' })

