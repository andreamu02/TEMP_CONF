-- lua/myvim/lsp.lua

require("mason").setup()

local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
  ensure_installed = {
    "lua_ls",
    "pyright",
    "bashls",
    "marksman",
    "clangd",
    "ruby_lsp",
    "rust_analyzer",
    "html",
    "cssls",
    "emmet_ls",
    "ts_ls",
    "intelephense",
    "texlab",
    "dockerls",
    "docker_compose_language_service",
    "docker_language_server",
    "arduino_language_server",
    "efm",
  },
  automatic_enable = true,
})

local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_nvim_lsp.default_capabilities()

-- LspAttach con mappings puliti (include <leader>ca e gd -> Telescope)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local buf = ev.buf
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end

    map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "LSP: go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "LSP: go to declaration")
    map("n", "K", vim.lsp.buf.hover, "LSP: hover")
    map("n", "gr", vim.lsp.buf.references, "LSP: references")
    map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code actions")
    map("n", "<leader>d", vim.diagnostic.open_float, "Diagnostics: line")
    map("n", "[d", vim.diagnostic.goto_prev, "Diagnostics: prev")
    map("n", "]d", vim.diagnostic.goto_next, "Diagnostics: next")
  end,
})

local util = require("lspconfig.util")

-- Pyright
vim.lsp.config("pyright", {
  capabilities = capabilities,
})
pcall(function() vim.lsp.enable("pyright") end)

-- Ruff LSP per lint / quickfix Python
if vim.fn.executable("ruff") == 1 then
  vim.lsp.config("ruff_lsp", {
    capabilities = capabilities,
    root_dir = util.root_pattern("pyproject.toml", "ruff.toml", ".git"),
    init_options = {
      settings = {
        args = {},
      },
    },
  })
  pcall(function() vim.lsp.enable("ruff_lsp") end)
end

-- clangd (C / C++)
vim.lsp.config("clangd", {
  capabilities = capabilities,
  cmd = { "clangd", "--background-index" }, -- puoi aggiungere --clang-tidy se vuoi
  root_dir = util.root_pattern("compile_commands.json", ".git"),
})
pcall(function() vim.lsp.enable("clangd") end)

-- conform.nvim: formatter per Python / C / C++ / Rust + template
require("conform").setup({
  formatters_by_ft = {
    python = { "black" },
    c      = { "clang_format" },
    cpp    = { "clang_format" },
    rust   = { "rustfmt" },
    ["htmldjango"] = { "djlint" },
    ["jinja.html"] = { "djlint" },
  },
  format_on_save = {
    lsp_fallback = true,
    timeout_ms = 1000,
  },
})

