-- [[ Configure LSPs ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  local fzf = require('fzf-lua')

  nmap('<leader>n', vim.lsp.buf.rename, 'Rename')
  nmap('\\\\!', vim.lsp.buf.code_action, 'Code action')

  nmap('gd', fzf.lsp_definitions, 'Definition')
  nmap('gr', fzf.lsp_references, 'References')
  nmap('gI', fzf.lsp_implementations, 'Implementation')
  nmap('gy', fzf.lsp_typedefs, 'Type definition')
  nmap('gh', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('gH', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('gD', vim.lsp.buf.declaration, 'Declaration')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- mason-lspconfig requires mason to be set up first
require('mason').setup()

local capabilities = require('blink.cmp').get_lsp_capabilities()

-- Global defaults applied to all servers (replaces setup_handlers default function)
vim.lsp.config('*', {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Per-server settings
vim.lsp.config('clangd', {
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }, -- exclude .proto
})

vim.lsp.config('svelte', {
  filetypes = { "svelte" },
})

vim.lsp.config('tinymist', {
  filetypes = { "typ" },
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
})

vim.lsp.config('tailwindcss', {
  capabilities = {
    textDocument = {
      colorProvider = { dynamicRegistration = true },
    },
  },
})

vim.lsp.config('rust_analyzer', {
  settings = {
    ["rust-analyzer"] = {
      diagnostics = {
        enable = true,
        disabled = { "inactive-code", "unlinked-file" },
      },
    },
  },
})

-- mason-lspconfig: ensure servers installed, automatic_enable = true by default
-- which calls vim.lsp.enable() for installed servers, picking up config above
require('mason-lspconfig').setup({
  ensure_installed = { 'clangd', 'pyright', 'svelte', 'ts_ls', 'tinymist', 'lua_ls', 'gopls' },
})

vim.lsp.config('gopls', {
  cmd = { 'gopls', '-remote=auto' },
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      analyses = {
        unusedparams = true,
        shadow = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },
      directoryFilters = {
        '-**/node_modules',
        '-static',
        '-bazel-bin',
        '-bazel-out',
        '-bazel-testlogs',
      },
      buildFlags = { '-tags=launchdarkly_easyjson' },
    },
  },
})

-- Closes html tags for you
require('nvim-ts-autotag').setup({
  opts = {
    enable_close = true,
    enable_rename = true,
    enable_close_on_slash = false,
  },
  per_filetype = {
    ["html"] = {
      enable_close = false
    }
  }
})
