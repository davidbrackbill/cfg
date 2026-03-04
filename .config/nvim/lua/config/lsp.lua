-- [[ Configure LSPs ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  local telebuilt = require('telescope.builtin')

  nmap('<leader>n', vim.lsp.buf.rename, 'Rename')
  nmap('\\\\!', vim.lsp.buf.code_action, 'Code action')

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

-- mason-lspconfig requires mason to be set up first
require('mason').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Neodev handles neovim lua-ls (LSP) configuration, must come before lua_ls config
require('neodev').setup()

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
  ensure_installed = { 'clangd', 'pyright', 'svelte', 'ts_ls', 'tinymist', 'lua_ls' },
})

-- https://github.com/neovim/neovim/issues/30985
-- Fix by upgrading from v10.2->10.3
for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end

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
