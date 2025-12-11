-- ~/.config/nvim/lua/myvim/keymaps.lua

local builtin_ok, builtin = pcall(require, "telescope.builtin")

-- helper locale
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Telescope (semplici)
map('n', '<leader>ff', "<cmd>Telescope find_files<CR>")
map('n', '<leader>fg', "<cmd>Telescope live_grep<CR>")
map('n', '<leader>fb', "<cmd>Telescope buffers<CR>")
map('n', '<leader>fh', "<cmd>Telescope help_tags<CR>")

-- Jumplist
vim.keymap.set("n", "<leader>jb", ":Telescope jumplist<CR>", { desc = "Jump back (jumplist)" })

-- LSP global nav (NB: questo `gd` sovrascrive quello in LspAttach)
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
    vim.notify("Implementation not supported by attached server, falling back to definition", vim.log.levels.WARN)
    vim.lsp.buf.definition()
  end
end, { desc = "Go to implementation (fallback to definition)" })

vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Show references" })
vim.keymap.set("n", "gb", "<C-o>", { desc = "Go back" })

-- AST grep wrapper (usa live_grep)
local function telescope_ast_grep(_, opts)
  if not builtin_ok then
    vim.notify("Telescope not found!", vim.log.levels.WARN)
    return
  end
  opts = opts or {}
  local picker_opts = {
    prompt_title = "AST-Grep",
  }
  return builtin.live_grep(vim.tbl_extend("force", picker_opts, opts))
end

vim.keymap.set("n", "<leader>as", function()
  telescope_ast_grep(nil, { cwd = vim.g.nvim_start_dir })
end, { desc = "AST-Grep structural search" })

-- Comment.nvim
vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment selection" })

-- Telescope: Ctrl+Space / Alt+Space
if builtin_ok then
  vim.keymap.set("n", "<C-Space>", function()
    builtin.live_grep()
  end, { desc = "Search text in project (live_grep)" })

  vim.keymap.set("n", "<A-Space>", function()
    builtin.find_files({ hidden = true })
  end, { desc = "Search files in project (find_files)" })

  vim.keymap.set("n", "<C-@>", function()
    builtin.live_grep()
  end, { desc = "Search text in project (live_grep fallback)" })
end

-- Visual: live_grep su selezione
local function live_grep_visual()
  if not builtin_ok then
    vim.notify("telescope.builtin not available", vim.log.levels.WARN)
    return
  end

  local saved_reg = vim.fn.getreg('"')
  local saved_type = vim.fn.getregtype('"')

  pcall(vim.cmd, 'silent! normal! "zy')
  local text = vim.fn.getreg('z') or ""
  pcall(vim.fn.setreg, '"', saved_reg, saved_type)

  text = text:gsub("%s+", " "):match("^%s*(.-)%s*$") or ""

  if text ~= "" then
    builtin.live_grep({ default_text = text })
  else
    builtin.live_grep()
  end
end

vim.keymap.set({ "v", "x" }, "<C-Space>", live_grep_visual, { desc = "Search selected text in project" })
vim.keymap.set({ "v", "x" }, "<leader>gs", live_grep_visual, { desc = "Search selected text (alt mapping)" })

-- Neo-tree toggle / smart focus
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
  local ok, neo_cmd = pcall(require, "neo-tree.command")
  if ok and neo_cmd and type(neo_cmd.execute) == "function" then
    pcall(neo_cmd.execute, opts)
    return true
  end

  if opts and opts.toggle then
    pcall(vim.cmd, "Neotree toggle")
    return true
  elseif opts and opts.reveal then
    pcall(vim.cmd, "Neotree reveal")
    return true
  end
  return false
end

local function neotree_toggle()
  safe_neotree_execute({ toggle = true, dir = vim.loop.cwd() })
end

local function neotree_smart_toggle()
  local neo_win = find_neotree_win()
  local cur_win = vim.api.nvim_get_current_win()

  if neo_win then
    if cur_win == neo_win then
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if w ~= neo_win then
          vim.api.nvim_set_current_win(w)
          return
        end
      end
    else
      vim.api.nvim_set_current_win(neo_win)
      return
    end
  else
    safe_neotree_execute({ toggle = true, dir = vim.loop.cwd() })
  end
end

vim.keymap.set("n", "`", neotree_toggle, { noremap = true, silent = true, desc = "Neo-tree: toggle" })
vim.keymap.set("n", "~", neotree_smart_toggle, { noremap = true, silent = true, desc = "Neo-tree: focus if open, else open" })

-- Clipboard / paste helpers
vim.api.nvim_set_keymap('v', '<Esc>[105;6u', '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-S-V>', '<C-R>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>p', '"_dP', { desc = "Paste without overwriting register" })

vim.keymap.set("n", "<leader>td", "<cmd>ToggleInlineDiagnostics<CR>", { desc = "Toggle inline diagnostics" })

vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit" })
