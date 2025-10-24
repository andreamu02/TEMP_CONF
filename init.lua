---@diagnostic disable: undefined-global
-- Neovim starter config for Rust (Arch Linux + Hyprland)
-- Save as: ~/.config/nvim/init.lua
-- Uses: lazy.nvim plugin manager
-- Ensure Mason binaries are in Neovim's PATH
vim.env.PATH = vim.env.HOME .. '/.local/share/nvim/mason/bin:' .. vim.env.PATH

vim.g.mapleader = ","
vim.g.maplocalleader = ","


-- Bootstrap lazy.nvim (follows folke's recommended bootstrap)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- Basic options
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.clipboard = "unnamedplus" -- system clipboard
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = vim.fn.stdpath('data')..'/undo'
vim.o.undofile = true
-- Keymap helper
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Plugins
require('lazy').setup({
  -- Utilities
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-lua/popup.nvim' },

  -- Telescope (fuzzy finder)
  { 'nvim-telescope/telescope.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Treesitter (syntax/indent/parsing)
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  { "nvim-tree/nvim-web-devicons", opts = {} },

  -- File explorer
  { 'nvim-neo-tree/neo-tree.nvim', branch = 'v3.x', dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons', 'MunifTanjim/nui.nvim' } },

  -- Statusline
  { 'nvim-lualine/lualine.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },

  -- Git signs
  { 'lewis6991/gitsigns.nvim', dependencies = { 'nvim-lua/plenary.nvim' } },

  { 'norcalli/nvim-colorizer.lua' },

  {
    "f-person/git-blame.nvim",
    keys = { { "<leader>gb", "<cmd>GitBlameToggle<CR>", desc = "Toggle Git Blame" } },
    opts = {
      enabled = false, -- start disabled
      message_template = " <summary> • <date> • <author>",
      date_format = "%r",
      virtual_text_column = 1,
    },
    config = function(_, opts)
      -- safe setup
      local ok, gitblame = pcall(require, "gitblame")
      if ok and gitblame then
        gitblame.setup(opts)
      end
    end,
  },

  -- LSP / tooling
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },

  -- Rust: modern replacement for rust-tools (filetype plugin that auto-configures rust-analyzer)
  { 'mrcjkb/rustaceanvim' },

  { "echasnovski/mini.indentscope", version = false, event = { "BufReadPre", "BufNewFile" }, opts = {} },
  { "kosayoda/nvim-lightbulb", dependencies = { "antoinemadec/FixCursorHold.nvim" }, config = true },

  -- Sudo
  {
    "lambdalisue/vim-suda",
    init = function()
      -- Makes :w automatically use sudo if needed
      vim.g.suda_smart_edit = 1
    end,
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- safe setup: only call setup when the module is present
      local ok, fops = pcall(require, "nvim-lsp-file-operations")
      if ok and fops then
        fops.setup({
          -- optional config, see plugin README for options
        })
      end
    end,
  },

  { "s1n7ax/nvim-window-picker", config = function()
    require("window-picker").setup()
  end },

  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'L3MON4D3/LuaSnip' },
  { 'rafamadriz/friendly-snippets' },
  { 'tpope/vim-surround' },
  -- Convenience
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', cond = vim.fn.executable('make') == 1 },
  { 'nvim-telescope/telescope-file-browser.nvim', dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-telescope/telescope.nvim' } },
  -- Theme (pick one you like)
  { 'catppuccin/nvim', name = 'catppuccin' },
  { "numToStr/Comment.nvim", config = function()
    require("Comment").setup()
  end },
  {
    "nxhung2304/lastplace.nvim",
    config = function()
    require("lastplace").setup({
      -- your configuration here
    })
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },
  { "stevearc/conform.nvim",    opts = {}, event = "BufWritePre" }, -- formatting
  { "nvimtools/none-ls.nvim",  lazy = true },
})

require("mini.indentscope").setup({
  draw = {
    delay = 50,
    animation = require("mini.indentscope").gen_animation.none(),
  },
  symbol = "│",
  options = { try_as_border = true },
  -- only enable for specific filetypes if you want:
  filetype_exclude = { "help", "alpha", "neo-tree", "lazy", "packer" },
})


-- === Basic plugin setups ===
-- Treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'cpp', 'lua', 'rust', 'toml', 'json', 'bash', 'python' },
  highlight = { enable = true },
  indent = { enable = true },
}

-- Neo-tree
require("neo-tree").setup({
  filesystem = {
    hijack_netrw_behavior = "open_current",
    use_libuv_file_watcher = true,

    -- Follow the current file
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },

    -- Show hidden items
    filtered_items = {
      visible = true,   -- Show hidden files like .git, .env, etc.
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
  window = {
    position = "left",
    width = 30,
  },
})

-- Lualine
-- require('lualine').setup({ options = { theme = 'auto' } })
require('lualine').setup {
  options = {
    theme = 'catppuccin',
    icons_enabled = true
  }
}

-- Gitsigns
require('gitsigns').setup()

require('colorizer').setup(
      { "css", "scss", "html", "javascript", "typescript", "lua", "rust", "toml", "yaml", "json", "sh", "bash", "conf" }, -- highlight colors in all filetypes; change to a list for better perf (see note)
      {
        -- colorizer options
        RGB = true,        -- #RGB hex codes
        RRGGBB = true,     -- #RRGGBB hex codes
        names = true,      -- "Name" codes like "Blue"
        RRGGBBAA = true,   -- #RRGGBBAA hex codes
        rgb_fn = true,     -- CSS rgb() and rgba() functions
        hsl_fn = true,     -- CSS hsl() and hsla() functions
        css = true,        -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = true,     -- Enable all CSS *functions* (rgb_fn, hsl_fn)
      }
)

-- Telescope defaults
require('telescope').setup({
  defaults = {
    file_ignore_patterns = { 'node_modules', '.git' },
  }
})



local uv = vim.loop

local function is_file(path)
  local s = uv.fs_stat(path)
  return s and s.type == "file"
end

local function is_dir(path)
  local s = uv.fs_stat(path)
  return s and s.type == "directory"
end

-- Find a project root based on common markers. If vim.fs.find is available prefer it.
local function find_project_root(startpath)
  startpath = startpath or vim.loop.cwd()
  local markers = { "pyproject.toml", "setup.cfg", "setup.py", "Pipfile", ".git" }

  if vim.fs and vim.fs.find then
    local found = vim.fs.find(markers, { path = startpath, upward = true })
    if found and #found > 0 then
      return vim.fs.dirname(found[1])
    end
  else
    -- fallback: walk upward until we hit root
    local dir = vim.fn.fnamemodify(startpath, ":p")
    while dir and dir ~= "/" do
      for _, m in ipairs(markers) do
        if is_file(dir .. "/" .. m) or is_dir(dir .. "/" .. m) then
          return dir
        end
      end
      dir = vim.fn.fnamemodify(dir, ":h")
    end
  end

  return vim.loop.cwd()
end

-- Resolve a python interpreter path for the given project root.
-- Returns an absolute path (or "python" if all else fails).
local function find_python_in_root(root_dir)
  root_dir = root_dir or find_project_root()

  -- 1) If Neovim inherited a VIRTUAL_ENV, prefer that
  if vim.env.VIRTUAL_ENV and is_dir(vim.env.VIRTUAL_ENV) then
    local py = vim.fn.expand(vim.env.VIRTUAL_ENV .. "/bin/python")
    if is_file(py) then return py end
  end

  -- 2) Project-local venvs
  local local_candidates = { ".venv", "venv", "env" }
  for _, d in ipairs(local_candidates) do
    local candidate = root_dir .. "/" .. d .. "/bin/python"
    if is_file(candidate) then
      return candidate
    end
  end

  -- 3) Poetry (run in project dir to ensure correct env)
  if is_file(root_dir .. "/pyproject.toml") and vim.fn.executable("poetry") == 1 then
    local cmd = "cd " .. vim.fn.shellescape(root_dir) .. " && poetry env info -p 2>/dev/null"
    local out = vim.fn.systemlist(cmd)
    if out and #out > 0 and out[1] ~= "" then
      local p = out[1] .. "/bin/python"
      if is_file(p) then return p end
    end
  end

  -- 4) Pipenv
  if is_file(root_dir .. "/Pipfile") and vim.fn.executable("pipenv") == 1 then
    local cmd = "cd " .. vim.fn.shellescape(root_dir) .. " && pipenv --py 2>/dev/null"
    local out = vim.fn.systemlist(cmd)
    if out and #out > 0 and out[1] ~= "" and is_file(out[1]) then
      return out[1]
    end
  end

  -- 5) pyenv local (.python-version) — if pyenv present, attempt to use pyenv which
  if is_file(root_dir .. "/.python-version") and vim.fn.executable("pyenv") == 1 then
    local cmd = "cd " .. vim.fn.shellescape(root_dir) .. " && pyenv which python 2>/dev/null"
    local out = vim.fn.systemlist(cmd)
    if out and #out > 0 and out[1] ~= "" and is_file(out[1]) then
      return out[1]
    end
  end

  -- 6) Fallback: system python
  local py3 = vim.fn.exepath("python3")
  if py3 ~= "" then return py3 end
  local py = vim.fn.exepath("python")
  if py ~= "" then return py end

  -- last resort
  return "python"
end

-- Optional user command to inspect what interpreter would be used for current buffer
vim.api.nvim_create_user_command("ShowProjectPython", function(opts)
  local bufnr = tonumber(opts.args) or 0
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local start = fname ~= "" and vim.fn.fnamemodify(fname, ":p:h") or vim.loop.cwd()
  local root = find_project_root(start)
  local py = find_python_in_root(root)
  print("project root:", root)
  print("python:", py)
end, { nargs = "?" })

-- === Mason & LSP setup ===
-- Mason + mason-lspconfig
require("mason").setup()

local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
  ensure_installed = {
    -- Core languages
    "lua_ls",                 -- Lua
    "pyright",                -- Python
    "bashls",                 -- Bash / Shell
    "marksman",               -- Markdown
    "clangd",                 -- C / C++
    "ruby_lsp",               -- Ruby
    "rust_analyzer",          -- Rust

    -- Web / template
    "html",                   -- HTML
    "cssls",                  -- CSS / SCSS
    "emmet_ls",               -- Emmet (HTML/CSS snippets)
    "ts_ls",
    "intelephense",
    "texlab",

    -- Containers / DevOps
    "dockerls",                       -- Dockerfile
    "docker_compose_language_service", -- docker-compose.yml
    "docker_language_server",          -- Docker in general

    -- Embedded / hardware
    "arduino_language_server", -- Arduino
    "efm",
  },
  automatic_installation = true,
})

local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_nvim_lsp.default_capabilities()

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }

    -- Example keymaps
    vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>ca", function()
      vim.lsp.buf.code_action({ context = { diagnostics = vim.diagnostic.get(0) } })
    end, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ra", function()
      -- range-aware code action for visual selection
      vim.lsp.buf.code_action({ context = { diagnostics = vim.diagnostic.get(0) } })
    end, opts)
  end,
})


local util = require("lspconfig.util")
vim.lsp.config("pyright", {
  capabilities = capabilities,
  
})
pcall(function() vim.lsp.enable("pyright") end)


if vim.fn.executable("ruff") == 1 then
  vim.lsp.config("ruff_lsp", {
    capabilities = capabilities,
    root_dir = util.root_pattern("pyproject.toml", ".git"),
  })
  pcall(function() vim.lsp.enable("ruff_lsp") end)
end

-- conform formatting
require("conform").setup({
  formatters_by_ft = {
    python = { "ruff" , "black" }, -- conform will call the tools you have available
  },
})
-- optional: autoformat on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*.py"},
  callback = function() require("conform").format({ async = false }) end,
})

-- Default handler: when a server is available, this sets it up with your opts.
-- NOTE: rustaceanvim intentionally manages rust-analyzer. Do NOT setup rust_analyzer via lspconfig or rust-tools to avoid conflicts.
-- rustaceanvim is installed above and will automatically configure rust LSP + integration.

-- === Completion (nvim-cmp) ===
local cmp = require('cmp')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  snippet = {
    expand = function(args) luasnip.lsp_expand(args.body) end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
  }
})



-- === Keymaps (convenience) ===
map('n', '<leader>ff', "<cmd>Telescope find_files<CR>")
map('n', '<leader>fg', "<cmd>Telescope live_grep<CR>")
map('n', '<leader>fb', "<cmd>Telescope buffers<CR>")
map('n', '<leader>fh', "<cmd>Telescope help_tags<CR>")-- ======= Telescope + cmp
-- ==== Prereqs ====
-- Ensure these are installed on Arch:
-- sudo pacman -S ripgrep fd
-- Also have telescope, telescope-fzf-native (optional) and nvim-cmp installed.

-- ==== Telescope + cmp Ctrl-Space: choose files vs contents ====
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  vim.notify("Telescope not found!", vim.log.levels.WARN)
  return
end

-- Telescope basic setup
telescope.setup {
  defaults = {
    prompt_prefix = "🔭 ",
    selection_caret = "❯ ",
    path_display = { "smart" },
    file_ignore_patterns = { "node_modules", ".git/", "target" },
    vimgrep_arguments = {
      "rg", "--hidden", "--no-ignore", "--smart-case",
      "--line-number", "--column", "--color", "never"
    },
    mappings = {
      i = {
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<esc>"] = require("telescope.actions").close,
      },
      n = {
        ["q"] = require("telescope.actions").close,
      },
    },
  },
}

vim.keymap.set("n", "<leader>jb", ":Telescope jumplist<CR>", { desc = "Jump back (jumplist)" })


vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gi", function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  local supports = false
  for _, client in ipairs(clients) do
    if client.supports_method("textDocument/implementation") then
      supports = true
      break
    end
  end

  if supports then
    vim.lsp.buf.implementation()
  else
    vim.notify(
      "Implementation not supported by attached server, falling back to definition",
      vim.log.levels.WARN
    )
    vim.lsp.buf.definition()
  end
end, { desc = "Go to implementation (fallback to definition)" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
vim.keymap.set("n", "gb", "<C-o>", { desc = "Go back" })  -- jump back

local builtin = require("telescope.builtin")

-- Custom function to run ast-grep and display results in Telescope
local function telescope_ast_grep(prompt_bufnr, opts)
  opts = opts or {}
  local picker_opts = {
    prompt_title = "AST-Grep",
    -- You can customize args: pattern, lang, cwd, etc
    -- Example: use selection or input
  }
  return builtin.live_grep(vim.tbl_extend("force", picker_opts, opts))
end

-- Map keys to run it
vim.keymap.set("n", "<leader>as", function()
  telescope_ast_grep(nil, { cwd = vim.g.nvim_start_dir })
end, { desc = "AST-Grep structural search" })



require("catppuccin").setup({
  flavour = "mocha", -- options: latte, frappe, macchiato, mocha
  color_overrides = {
    mocha = {
      -- pick whatever hex you like for "red"
      -- example: a soft catppuccin-style red
      red = "#f38f96",
      -- you may also override related shades if desired:
      -- rosewater = "#f5e0dc",
      -- maroon = "#caa0ac",
    },
  },

  -- Optional: set custom highlights using the resolved palette
  custom_highlights = function(colors)
    return {
      -- make errors strongly red
      Error = { fg = colors.red },
      DiagnosticError = { fg = colors.red },

      -- highlight search / LSP references with a red-ish tint
      Search = { bg = colors.red, fg = colors.text, bold = true },
      LspReferenceText = { bg = colors.red }, -- add slight alpha by appending hex alpha (if terminal supports)

      -- example: force statusline segments to use the new red
      StatusLine = { fg = colors.text, bg = colors.surface0 },
      StatusLineError = { fg = colors.red, bg = colors.surface0 },

      -- telescope/popup example
      TelescopePromptNormal = { bg = colors.surface0, fg = colors.text },
      TelescopePromptBorder = { fg = colors.red, bg = colors.surface0 },
    }
  end,

  integrations = {
    lualine = true,         -- if using lualine, it can pick the catppuccin theme
    telescope = true,
    nvimtree = true,
    cmp = true,
    gitsigns = true,
    -- add plugin integrations as needed
  },
})

vim.cmd("colorscheme catppuccin")

vim.cmd([[
  autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()
]])

vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"


-- ====== Keymaps ======
-- Toggle Neo-tree with backtick
--vim.keymap.set("n", "`", function()
  --require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
--end, { desc = "Toggle file explorer" })

-- Optional: leader+e alternative
--vim.keymap.set("n", "<leader>e", function()
  --require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
--end, { desc = "Toggle file explorer" })


-- Robust Neo-tree toggle / focus mappings
local function find_neotree_win()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local ok, ft = pcall(vim.api.nvim_buf_get_option, vim.api.nvim_win_get_buf(w), "filetype")
    if ok and ft and ft:match("neo%-tree") then
      return w
    end
  end
  return nil
end

local function safe_neotree_execute(opts)
  -- Try the canonical lua call first
  local ok, neo_cmd = pcall(require, "neo-tree.command")
  if ok and neo_cmd and type(neo_cmd.execute) == "function" then
    pcall(neo_cmd.execute, opts)
    return true
  end

  -- Some installs expose the :Neotree command instead — try that as a fallback
  if opts and opts.toggle then
    pcall(vim.cmd, "Neotree toggle")
    return true
  elseif opts and opts.reveal then
    pcall(vim.cmd, "Neotree reveal")
    return true
  end

  return false
end

-- ` (backtick): simple toggle
local function neotree_toggle()
  safe_neotree_execute({ toggle = true, dir = vim.loop.cwd() })
end

-- Shift+` (tilde ~): focus if open, otherwise open (toggle)
local function neotree_smart_toggle()
  local neo_win = find_neotree_win()
  local cur_win = vim.api.nvim_get_current_win()

  if neo_win then
    if cur_win == neo_win then
      -- Cursor is in Neo-tree → switch to first non-Neo-tree window
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if w ~= neo_win then
          vim.api.nvim_set_current_win(w)
          return
        end
      end
    else
      -- Cursor in normal buffer → focus Neo-tree
      vim.api.nvim_set_current_win(neo_win)
      return
    end
  else
    -- Neo-tree not open → open it
    safe_neotree_execute({ toggle = true, dir = vim.loop.cwd() })
  end
end

-- Map keys: keep backtick as toggle, map Shift+backtick (~) to focus-or-open
vim.keymap.set("n", "`", neotree_toggle, { noremap = true, silent = true, desc = "Neo-tree: toggle" })
vim.keymap.set("n", "~", neotree_smart_toggle, { noremap = true, silent = true, desc = "Neo-tree: focus if open, else open" })


-- Normal mode: toggle comment on the current line
vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment line" })

-- Visual mode: toggle comment on the selected lines
vim.keymap.set("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment selection" })


-- Ctrl+Space → search inside files (live_grep)
vim.keymap.set("n", "<C-Space>", function()
  builtin.live_grep()
end, { desc = "Search text in project (live_grep)" })

-- Shift+Space → search files by name (find_files)
vim.keymap.set("n", "<A-Space>", function()
  builtin.find_files({ hidden = true })
end, { desc = "Search files in project (find_files)" })

-- Optional fallback for terminals that don't send <C-Space>
vim.keymap.set("n", "<C-@>", function()
  builtin.live_grep()
end, { desc = "Search text in project (live_grep fallback)" })

-- Visual mode → grep selected text

local function live_grep_visual()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok or not builtin then
    vim.notify("telescope.builtin not available", vim.log.levels.WARN)
    return
  end

  -- preserve unnamed register
  local saved_reg = vim.fn.getreg('"')
  local saved_type = vim.fn.getregtype('"')

  -- yank visual selection into register z (doesn't change the buffer)
  -- use silent normal! so this runs while selection is active and doesn't echo
  pcall(vim.cmd, 'silent! normal! "zy')

  local text = vim.fn.getreg('z') or ""
  -- restore unnamed register
  pcall(vim.fn.setreg, '"', saved_reg, saved_type)

  -- normalize whitespace and join multiline selection into a single search string
  text = text:gsub("%s+", " "):match("^%s*(.-)%s*$") or ""

  if text ~= "" then
    builtin.live_grep({ default_text = text })
  else
    builtin.live_grep()
  end
end

-- map for visual mode (v) and select mode (x) as a fallback
vim.keymap.set({ "v", "x" }, "<C-Space>", live_grep_visual, { desc = "Search selected text in project" })
-- alternative mapping if your terminal doesn't send <C-Space>
vim.keymap.set({ "v", "x" }, "<leader>gs", live_grep_visual, { desc = "Search selected text (alt mapping)" })


vim.api.nvim_create_autocmd({"BufReadPost","DiagnosticChanged"}, {
  callback = function()
    if _G.inline_diag_enabled then
      vim.diagnostic.show()
    end
  end
})


-- Hyprland/Wayland note: if you're using Wayland clipboard integration, ensure wl-clipboard or wayland clipboard helper is installed on Arch.

-- === Misc: autocommands ===
-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.hl.on_yank{higroup="IncSearch", timeout=200}
  augroup end
]]

-- Map Kitty's custom escape sequence (ESC [105;6u) to yank to system clipboard in visual mode.
-- This corresponds to: vnoremap <Esc>[105;6u "+y
vim.api.nvim_set_keymap('v', '<Esc>[105;6u', '"+y', { noremap = true, silent = true })

-- Optional: make Ctrl-Shift-V paste from system clipboard in insert mode
-- (this only works if your terminal actually sends <C-S-V> to Neovim)
vim.api.nvim_set_keymap('i', '<C-S-V>', '<C-R>+', { noremap = true, silent = true })


-- Finished
print('Neovim starter config loaded — enjoy coding in Rust!')



