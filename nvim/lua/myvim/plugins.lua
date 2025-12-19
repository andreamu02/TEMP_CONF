-- ~/.config/nvim/lua/myvim/plugins.lua

require('lazy').setup({
  -- Utilities
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-lua/popup.nvim' },

  -- Telescope (fuzzy finder)
  { 'nvim-telescope/telescope.nvim',   dependencies = { 'nvim-lua/plenary.nvim' } },

  -- Treesitter
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
  { "nvim-tree/nvim-web-devicons",     opts = {} },

  -- File explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim'
    }
  },
  -- icons
  {
    "echasnovski/mini.icons",
    version = false,
    opts = {},
  },
  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },

  -- Git signs
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  { "lepture/vim-jinja" },
  {
    "f-person/git-blame.nvim",
    keys = { { "<leader>gB", "<cmd>GitBlameToggle<CR>", desc = "Toggle Git Blame" } },
    opts = {
      enabled = false,
      message_template = " <summary> • <date> • <author>",
      date_format = "%r",
      virtual_text_column = 1,
    },
    config = function(_, opts)
      local ok, gitblame = pcall(require, "gitblame")
      if ok and gitblame then
        gitblame.setup(opts)
      end
    end,
  },
  {
    "mbbill/undotree",
  },
  { 'norcalli/nvim-colorizer.lua' },

  -- Terminale integrato (toggleterm)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    keys = { [[<C-\>]] },
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-\>]],
        shade_terminals = true,
        direction = "float",
        float_opts = { border = "curved" },
      })
    end,
  },

  -- Debugger (nvim-dap + UI + install via mason)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        ensure_installed = { "python", "codelldb" }, -- python(debugpy) + codelldb per C++/Rust
        automatic_setup = true,                      -- usa le config predefinite
        automatic_installation = true,
        handlers = {},
      })

      dapui.setup()
      require("nvim-dap-virtual-text").setup({})

      -- Apri/chiudi automaticamente l'UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymaps base per il debugger
      local map = vim.keymap.set
      map("n", "<F5>", dap.continue, { desc = "DAP: start/continue" })
      map("n", "<F10>", dap.step_over, { desc = "DAP: step over" })
      map("n", "<F11>", dap.step_into, { desc = "DAP: step into" })
      map("n", "<F12>", dap.step_out, { desc = "DAP: step out" })
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: toggle breakpoint" })
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP: conditional breakpoint" })
      map("n", "<leader>dr", dap.repl.open, { desc = "DAP: REPL" })
      map("n", "<leader>dl", dap.run_last, { desc = "DAP: run last" })
      map("n", "<leader>du", function() dapui.toggle({}) end, { desc = "DAP: toggle UI" })
    end,
  },

  -- Helper Python: usa il python del progetto per debug (debugpy)
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local pyutil = require("myvim.python")
      local root   = pyutil.find_project_root()
      local python = pyutil.find_python_in_root(root)
      require("dap-python").setup(python)
    end,
  },

  -- LSP / tooling
  { 'neovim/nvim-lspconfig' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter" },
  },
  { "onsails/lspkind.nvim" },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },
  -- Rust
  {
    "mrcjkb/rustaceanvim",
    ft = { "rust" },
    init = function()
      local opts = {
        tools = {
          code_actions = { ui_select_fallback = true },
        },
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              checkOnSave = true,
              check = {
                command = "clippy",
              },
            },
          },
          on_attach = function(_, bufnr)
            vim.keymap.set("n", "<leader>cs", function()
              vim.cmd.RustLsp("codeAction")
            end, { buffer = bufnr, desc = "Rust: Code Actions (rust-analyzer)" })

            vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
          end,
        },
      }
      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts)
    end,
  },

  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local m = require("mini.indentscope")
      m.setup({
        draw = {
          delay = 50,
          animation = m.gen_animation.none(),
        },
        symbol = "│",
        options = { try_as_border = true },
        filetype_exclude = { "help", "alpha", "neo-tree", "lazy", "packer" },
      })
    end,
  },

  { "kosayoda/nvim-lightbulb", dependencies = { "antoinemadec/FixCursorHold.nvim" }, config = true },

  -- Sudo
  {
    "lambdalisue/vim-suda",
    init = function()
      vim.g.suda_smart_edit = 1
    end,
  },

  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local ok, fops = pcall(require, "nvim-lsp-file-operations")
      if ok and fops then
        fops.setup({})
      end
    end,
  },

  {
    "s1n7ax/nvim-window-picker",
    config = function()
      require("window-picker").setup()
    end
  },

  -- Completion
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/cmp-buffer' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'L3MON4D3/LuaSnip' },
  { 'rafamadriz/friendly-snippets' },

  { 'tpope/vim-surround' },

  -- Telescope extras
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = vim.fn.executable('make') == 1
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'nvim-telescope/telescope.nvim' }
  },

  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown({
            previewer = false,
            initial_mode = "normal",
          }),
        },
      })
      telescope.load_extension("ui-select")
    end,
  },


  -- Themes
  { 'catppuccin/nvim',        name = 'catppuccin' },

  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "nxhung2304/lastplace.nvim",
    config = function()
      require("lastplace").setup({})
    end,
  },

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        " ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
        " ████╗  ██║██║   ██║██║████╗ ████║",
        " ██╔██╗ ██║██║   ██║██║██╔████╔██║",
        " ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        " ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        " ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "              neovim",
      }

      -- Pulsanti rapidi
      dashboard.section.buttons.val = {
        dashboard.button("f", "[F]  Find file", ":Telescope find_files<CR>"),
        dashboard.button("r", "[R]  Recent files", ":Telescope oldfiles<CR>"),
        dashboard.button("g", "[G]  LazyGit", ":LazyGit<CR>"),
        dashboard.button("p", "[P]  File explorer", ":Neotree toggle<CR>"),
        dashboard.button("u", "[U]  Update plugins", ":Lazy sync<CR>"),
        dashboard.button("q", "[Q]  Quit", ":qa<CR>"),
      }

      -- Piccolo footer (puoi metterci qualunque frase)
      dashboard.section.footer.val = function()
        return "Happy hacking in Rust / Python / C++ ✨"
      end

      -- Layout un po' spostato verso il centro
      dashboard.opts.layout[1].val = 6

      alpha.setup(dashboard.opts)

      -- Niente folding nella dashboard
      vim.cmd [[
        autocmd FileType alpha setlocal nofoldenable
      ]]
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && npm install",
    config = function()
      -- NON partire da solo, lo avvii tu
      vim.g.mkdp_auto_start = 0
      -- Chiudi la preview quando chiudi il buffer
      vim.g.mkdp_auto_close = 1
      -- Stampa l’URL in basso (così puoi aprirlo a mano se serve)
      vim.g.mkdp_echo_preview_url = 1
      -- Forza il browser (Arch + Hyprland di solito: firefox)
      vim.g.mkdp_browser = "firefox"
      -- Tema scuro
      vim.g.mkdp_theme = "dark"
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
  },

  { "stevearc/conform.nvim",  event = "BufWritePre" },
  { "nvimtools/none-ls.nvim", lazy = true },
})

-- Treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'c', 'cpp', 'lua', 'rust', 'toml', 'json', 'bash', 'python', 'html', 'javascript', 'css' },
  highlight = { enable = true },
  indent = { enable = true },
}

-- Neo-tree
require("neo-tree").setup({
  filesystem = {
    hijack_netrw_behavior = "open_current",
    use_libuv_file_watcher = true,
    keep_altfile = true,
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    filtered_items = {
      visible = true,
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
require('lualine').setup {
  options = {
    theme = 'catppuccin',
    icons_enabled = true
  }
}

-- Gitsigns
require('gitsigns').setup()

-- Colorizer
require('colorizer').setup(
  {
    "css", "scss", "html", "javascript", "typescript", "lua",
    "rust", "toml", "yaml", "json", "sh", "bash", "conf",
    "jinja", "htmldjango", "jinja.html"
  },
  {
    RGB = true,
    RRGGBB = true,
    names = true,
    RRGGBBAA = true,
    rgb_fn = true,
    hsl_fn = true,
    css = true,
    css_fn = true,
  }
)

-- Telescope base setup (la versione “ricca” che avevi più sotto)
local telescope_ok, telescope = pcall(require, "telescope")
if telescope_ok then
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
  pcall(telescope.load_extension, "fzf")
  pcall(telescope.load_extension, "file_browser")
end

-- Catppuccin
require("catppuccin").setup({
  flavour = "mocha",
  color_overrides = {
    mocha = {
      red = "#f38f96",
    },
  },
  custom_highlights = function(colors)
    return {
      Error = { fg = colors.red },
      DiagnosticError = { fg = colors.red },

      Search = { bg = colors.red, fg = colors.text, bold = true },
      LspReferenceText = { bg = colors.red },

      StatusLine = { fg = colors.text, bg = colors.surface0 },
      StatusLineError = { fg = colors.red, bg = colors.surface0 },

      TelescopePromptNormal = { bg = colors.surface0, fg = colors.text },
      TelescopePromptBorder = { fg = colors.red, bg = colors.surface0 },
    }
  end,
  integrations = {
    lualine = true,
    telescope = true,
    nvimtree = true,
    cmp = true,
    gitsigns = true,
    alpha = true
  },
})

vim.cmd("colorscheme catppuccin")
do
  local palette = require("catppuccin.palettes").get_palette("mocha")

  -- popup di completion: un pelo più chiaro del fondo base
  vim.api.nvim_set_hl(0, "CmpPmenu", { bg = palette.surface0, fg = palette.text })
  vim.api.nvim_set_hl(0, "CmpPmenuBorder", { bg = palette.surface0, fg = palette.surface2 })
  vim.api.nvim_set_hl(0, "PmenuSel", { bg = palette.lavender, fg = palette.base, bold = true, underline = true })

  -- finestra documentazione: altro blocco, sempre leggibile
  vim.api.nvim_set_hl(0, "CmpDoc", { bg = palette.base, fg = palette.text })
  vim.api.nvim_set_hl(0, "CmpDocBorder", { bg = palette.base, fg = palette.surface2 })

  -- FLOAT GENERICI (diagnostica, hover, ecc.)
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = palette.surface0, fg = palette.text })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = palette.surface0, fg = palette.surface2 })

  -- Colori specifici per la diagnostica nel popup
  vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = palette.red, bg = palette.surface0 })
  vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = palette.yellow, bg = palette.surface0 })
  vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = palette.sky, bg = palette.surface0 })
  vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = palette.teal, bg = palette.surface0 })
end

-- Trasparenza
vim.cmd([[
  hi Normal guibg=NONE
  hi NormalNC guibg=NONE
  hi VertSplit guibg=NONE
]])

-- LineNr & EndOfBuffer
vim.api.nvim_set_hl(0, "LineNr", { fg = "#cccccc", bg = "NONE" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#444444", bg = "NONE" })
