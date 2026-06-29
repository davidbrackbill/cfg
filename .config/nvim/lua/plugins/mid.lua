-- mid — render ```mid (and ```mermaid) fenced bullet lists as inline graphs.
-- https://… (local checkout at ~/db/mid)

return {
  dir = '/Users/db/db/mid/plugins/nvim',
  ft = 'markdown',
  config = function()
    require('mid').setup({
      -- `mid` is on PATH (symlinked from dist/mid). To run the dev CLI instead:
      -- cmd = { 'bun', 'run', '/Users/db/db/dig/src/cli.ts' },
    })
  end,
}
