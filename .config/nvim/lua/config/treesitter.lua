-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- New nvim-treesitter API: install parsers, highlight is automatic once installed
-- Enable treesitter highlighting for all buffers immediately and on future opens
vim.api.nvim_create_autocmd('FileType', {
  callback = function() pcall(vim.treesitter.start) end,
})
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  pcall(vim.treesitter.start, buf)
end

vim.defer_fn(function()
  require('nvim-treesitter').install({
    'c', 'cpp', 'go', 'lua', 'python', 'rust',
    'javascript', 'typescript', 'svelte', 'css', 'html',
    'vimdoc', 'vim', 'bash', 'sql',
  })

  require('nvim-treesitter-textobjects').setup({
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true,
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
  })
end, 0)
