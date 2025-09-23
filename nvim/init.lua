-- Neovim starter config for Rust (Arch Linux + Hyprland)
-- Save as: ~/.config/nvim/init.lua
-- Uses: lazy.nvim plugin manager
-- Ensure Mason binaries are in Neovim's PATH
vim.env.PATH = vim.env.HOME .. '/.local/share/nvim/mason/bin:' .. vim.env.PATH

vim.g.mapleader = ","
vim.g.localleader = ","

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
vim.opt.clipboard = "unnamedplus"
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

  -- LSP / tooling
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },

  -- Rust: modern replacement for rust-tools (filetype plugin that auto-configures rust-analyzer)
  { 'mrcjkb/rustaceanvim' },

  -- Sudo
  {
    "lambdalisue/vim-suda",
    init = function()
      -- Makes :w automatically use sudo if needed
      vim.g.suda_smart_edit = 1
    end,
  },


  -- Completion
  {
    "lambdalisue/vim-suda",
    config = function()
    -- Makes :w automatically use sudo if needed
    vim.g.suda_smart_edit = 1
    end,
  },
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'L3MON4D3/LuaSnip' },
  { 'rafamadriz/friendly-snippets' },
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
  }
})

-- === Basic plugin setups ===
-- Treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'cpp', 'lua', 'rust', 'toml', 'json', 'bash' },
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

-- Telescope defaults
require('telescope').setup({
  defaults = {
    file_ignore_patterns = { 'node_modules', '.git' },
  }
})

-- === Mason & LSP setup ===
-- Mason + mason-lspconfig
require("mason").setup()
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
  ensure_installed = { "lua_ls", "pyright", "bashls", "marksman" }, -- lspconfig names
  automatic_installation = false, -- set true if you want Mason to install automatically
})

local lspconfig = require("lspconfig")
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
  end,
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

local telescope = require("telescope")
local builtin = require("telescope.builtin")

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

require("catppuccin").setup({
  flavour = "mocha", -- options: latte, frappe, macchiato, mocha
  color_overrides = {
    mocha = {
      -- pick whatever hex you like for "red"
      -- example: a soft catppuccin-style red
      red = "#f38ba8",
      -- you may also override related shades if desired:
      -- rosewater = "#f5e0dc",
      -- maroon = "#eba0ac",
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

vim.o.termguicolors = true
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
local function neotree_focus_if_open_or_open()
  local w = find_neotree_win()
  if w then
    vim.api.nvim_set_current_win(w)
    return
  end
  -- not open: open it
  safe_neotree_execute({ toggle = true, dir = vim.loop.cwd() })
end

-- Map keys: keep backtick as toggle, map Shift+backtick (~) to focus-or-open
vim.keymap.set("n", "`", neotree_toggle, { noremap = true, silent = true, desc = "Neo-tree: toggle" })
vim.keymap.set("n", "~", neotree_focus_if_open_or_open, { noremap = true, silent = true, desc = "Neo-tree: focus if open, else open" })


-- Normal mode: toggle comment on current line
vim.keymap.set("n", "<C-/>", "gcc", { noremap = false, silent = true })

-- Visual mode: toggle comment on selection
vim.keymap.set("v", "<C-/>", "gc", { noremap = false, silent = true })


-- Ctrl+Space → search inside files (live_grep)
vim.keymap.set("n", "<C-Space>", function()
  builtin.live_grep()
end, { desc = "Search text in project (live_grep)" })

-- Shift+Space → search files by name (find_files)
vim.keymap.set("n", "<S-Space>", function()
  builtin.find_files({ hidden = true })
end, { desc = "Search files in project (find_files)" })

-- Optional fallback for terminals that don't send <C-Space>
vim.keymap.set("n", "<C-@>", function()
  builtin.live_grep()
end, { desc = "Search text in project (live_grep fallback)" })

-- Visual mode → grep selected text
vim.keymap.set("v", "<C-Space>", function()
  local saved_reg = vim.fn.getreg('"')
  local saved_type = vim.fn.getregtype('"')
  vim.cmd('silent! normal! "vy') -- yank visual selection
  local text = vim.fn.getreg('v')
  vim.fn.setreg('"', saved_reg, saved_type)

  if text and text ~= "" then
    builtin.live_grep({ default_text = text })
  else
    builtin.live_grep()
  end
end, { desc = "Search selected text in project" })


-- Hyprland/Wayland note: if you're using Wayland clipboard integration, ensure wl-clipboard or wayland clipboard helper is installed on Arch.

-- === Misc: autocommands ===
-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=200}
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

