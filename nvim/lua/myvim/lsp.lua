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
  automatic_installation = true,
})

local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_nvim_lsp.default_capabilities()

vim.diagnostic.config({
  float = {
    border = "rounded",
    source = "always",
    header = "Diagnostics:",
    prefix = " ",
  },
})


-- LspAttach con mappings puliti (include <leader>ca e gd -> Telescope)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local buf = ev.buf
    if vim.b[buf].lsp_keymaps_set then return end
    vim.b[buf].lsp_keymaps_set = true
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- Code action solo sulla riga corrente (per evitare roba "globale" inutile)
    -- Code actions "normali", ma escludiamo Ruff
    local function line_code_action()
      vim.lsp.buf.code_action({
        filter = function(client)
          return client.name ~= "ruff_lsp"
        end,
      })
    end

    -- Code actions SOLO di Ruff (se presente)
    local function ruff_code_action()
      vim.lsp.buf.code_action({
        filter = function(client)
          return client.name == "ruff_lsp"
        end,
      })
    end

    -- funzione condivisa per code action "range-aware"
    local function range_code_action()
      local ctx = { diagnostics = vim.diagnostic.get(0) }
      local mode = vim.fn.mode()
      if mode == "v" or mode == "V" then
        local start_pos = vim.fn.getpos("'<")
        local end_pos   = vim.fn.getpos("'>")

        vim.lsp.buf.code_action({
          range = {
            start = { line = start_pos[2] - 1, character = start_pos[3] },
            ["end"] = { line = end_pos[2] - 1, character = end_pos[3] },
          },
          context = ctx,
        })
      else
        vim.lsp.buf.code_action({ context = ctx })
      end
    end

    -- ===== GOTO / hover base =====
    map("n", "gd", "<cmd>Telescope lsp_definitions<CR>", "LSP: go to definition")
    map("n", "gD", vim.lsp.buf.declaration, "LSP: go to declaration")
    map("n", "gr", vim.lsp.buf.references, "LSP: references")
    map("n", "K", vim.lsp.buf.hover, "LSP: hover")

    -- ===== Diagnostics base =====
    map("n", "<leader>d", vim.diagnostic.open_float, "Diagnostics: line")
    map("n", "<leader>dd", vim.diagnostic.open_float, "Diagnostics: line")
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, "Diagnostics: prev")

    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, "Diagnostics: next")

    map("n", "[e", function()
      vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
    end, "Diagnostics: prev error")

    map("n", "]e", function()
      vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
    end, "Diagnostics: next error")


    -- ===== Shortcut "vecchi" =====
    map({ "n", "v" }, "<leader>ca", line_code_action, "LSP: code actions (line)")
    map({ "n", "v" }, "<leader>ra", range_code_action, "LSP: range code actions")
    map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: rename")
    map({ "n", "v" }, "<leader>cR", ruff_code_action, "LSP: Ruff code actions")

    -- ===== PAGINA LSP SUL LEADER (<leader>l...) =====
    map("n", "<leader>lr", vim.lsp.buf.rename, "LSP: rename")
    map({ "n", "v" }, "<leader>la", line_code_action, "LSP: code actions (line)")
    map({ "n", "v" }, "<leader>lA", range_code_action, "LSP: range code actions")
    map("n", "<leader>ld", vim.diagnostic.open_float, "LSP: line diagnostics")
    map("n", "<leader>lD", "<cmd>Telescope diagnostics bufnr=0<CR>", "LSP: buffer diagnostics")
    map("n", "<leader>lR", "<cmd>Telescope lsp_references<CR>", "LSP: references")
    map("n", "<leader>lg", "<cmd>Telescope lsp_definitions<CR>", "LSP: definitions")
    map("n", "<leader>li", vim.lsp.buf.implementation, "LSP: implementations")
    map("n", "<leader>lf", function()
      require("conform").format({ async = false, lsp_fallback = true })
    end, "LSP: format file")

    -- Tasti dedicati per Ruff: fix-all / organize imports
    if client and client.name == "ruff_lsp" then
      map("n", "<leader>rf", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.fixAll" }, diagnostics = {} },
          apply = true,
        })
      end, "Ruff: fix all")

      map("n", "<leader>ri", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.organizeImports" }, diagnostics = {} },
          apply = true,
        })
      end, "Ruff: organize imports")
    end
  end,
})

local util   = require("lspconfig.util")
local pyutil = require("myvim.python")

-- Pyright: usa automaticamente il python del progetto (venv/poetry/pyenv)
vim.lsp.config("pyright", {
  capabilities = capabilities,
  root_dir = util.root_pattern("pyproject.toml", "setup.cfg", "setup.py", "Pipfile", ".git"),
  on_new_config = function(new_config, root_dir)
    new_config.settings = new_config.settings or {}
    new_config.settings.python = new_config.settings.python or {}
    new_config.settings.python.pythonPath = pyutil.find_python_in_root(root_dir)
  end,
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
  cmd = { "clangd", "--background-index", "--clang-tidy" },

  root_dir = function(bufnr, on_dir)
    -- prova a trovare una root "di progetto", altrimenti usa la directory del file
    local root = vim.fs.root(bufnr, {
      "compile_commands.json",
      "compile_flags.txt",
      ".clangd",
      "CMakeLists.txt",
      "Makefile",
      ".git",
    })

    local uv = vim.uv or vim.loop
    if not root then
      local fname = vim.api.nvim_buf_get_name(bufnr)
      root = (fname ~= "" and vim.fs.dirname(fname)) or uv.cwd()
    end

    on_dir(root)
  end,
})

pcall(function() vim.lsp.enable("clangd") end)

-- conform.nvim: formatter per Python / C / C++ / Rust + template
require("conform").setup({
  formatters_by_ft = {
    python         = { "black" },
    c              = { "clang_format" },
    cpp            = { "clang_format" },
    rust           = { "rustfmt" },
    ["htmldjango"] = { "djlint" },
    ["jinja.html"] = { "djlint" },
  },
  format_on_save = {
    lsp_fallback = true,
    timeout_ms = 1000,
  },
})
