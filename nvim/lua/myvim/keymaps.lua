-- lua/myvim/keymaps.lua

local builtin_ok, builtin = pcall(require, "telescope.builtin")
if not builtin_ok then
  builtin = nil
end

----------------------------------------------------------------------
-- Telescope: <leader>f*
----------------------------------------------------------------------

if builtin then
  vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep in project" })
  vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
  vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
  vim.keymap.set("n", "<leader>jb", builtin.jumplist, { desc = "Jumplist" })
else
  vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
  vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Grep in project" })
  vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
  vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
  vim.keymap.set("n", "<leader>jb", "<cmd>Telescope jumplist<CR>", { desc = "Jumplist" })
end

----------------------------------------------------------------------
-- Git: <leader>g*
----------------------------------------------------------------------

vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
vim.keymap.set("n", "<leader>gb", "<C-o>", { desc = "Go back" })
-- <leader>gB è in git-blame.nvim (plugins.lua)

----------------------------------------------------------------------
-- LSP "fallback" keys che non dipendono da LspAttach
-- (la maggior parte dei tasti LSP è impostata in lsp.lua, in LspAttach)
----------------------------------------------------------------------

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

----------------------------------------------------------------------
-- AST-grep helper (per ora usa live_grep, è solo un wrapper)
----------------------------------------------------------------------

local function telescope_ast_grep(_, opts)
  if not builtin then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    return
  end
  opts = opts or {}
  local picker_opts = { prompt_title = "AST-Grep" }
  return builtin.live_grep(vim.tbl_extend("force", picker_opts, opts))
end

vim.keymap.set("n", "<leader>as", function()
  telescope_ast_grep(nil, { cwd = vim.g.nvim_start_dir })
end, { desc = "AST-Grep structural search" })

----------------------------------------------------------------------
-- Comment.nvim: Ctrl+/ (normale + visual)
----------------------------------------------------------------------

vim.keymap.set("n", "<C-/>", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("v", "<C-/>", "gc", { remap = true, desc = "Toggle comment selection" })

----------------------------------------------------------------------
-- Telescope: Ctrl+Space / Alt+Space
----------------------------------------------------------------------

if builtin then
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

vim.keymap.set("n", "<leader>fe", function()
  require("telescope").extensions.file_browser.file_browser({
    path = vim.fn.expand("%:p:h"),
    select_buffer = true,
    hidden = true,
  })
end, { desc = "File browser (Telescope)" })

----------------------------------------------------------------------
-- Visual → live_grep del testo selezionato
----------------------------------------------------------------------

local function live_grep_visual()
  if not builtin then
    vim.notify("telescope.builtin not available", vim.log.levels.WARN)
    return
  end

  local saved_reg = vim.fn.getreg('"')
  local saved_type = vim.fn.getregtype('"')

  -- copia selezione in "z"
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

----------------------------------------------------------------------
-- Neo-tree toggle / smart focus
----------------------------------------------------------------------

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

vim.keymap.set("n", "`", neotree_toggle, { desc = "Neo-tree: toggle" })
vim.keymap.set("n", "~", neotree_smart_toggle, { desc = "Neo-tree: focus if open, else open" })

----------------------------------------------------------------------
-- Clipboard / paste helpers
----------------------------------------------------------------------

-- Kitty: mappa la sequenza custom per copiare in system clipboard
vim.api.nvim_set_keymap('v', '<Esc>[105;6u', '"+y', { noremap = true, silent = true })

-- Ctrl+Shift+V → incolla da system clipboard in insert e command-line
vim.keymap.set("i", "<C-S-V>", '<C-R>+', { noremap = true, silent = true, desc = "Paste from clipboard" })
vim.keymap.set("c", "<C-S-V>", '<C-R>+', { noremap = true, silent = true, desc = "Paste from clipboard" })

-- Visual + leader+p → incolla senza sovrascrivere il registro
vim.keymap.set("v", "<leader>p", '"_dP', { desc = "Paste without overwriting register" })

----------------------------------------------------------------------
-- Ctrl+Left / Ctrl+Right → word motions (section by section)
----------------------------------------------------------------------

-- Normal mode: muovi di una parola a sinistra/destra
vim.keymap.set("n", "<C-Left>", "b", { silent = true, desc = "Move left by word" })
vim.keymap.set("n", "<C-Right>", "w", { silent = true, desc = "Move right by word" })

-- Insert mode: usa <C-o> per eseguire il movimento in normal-mode
vim.keymap.set("i", "<C-Left>", "<C-o>b", { silent = true, desc = "Move left by word" })
vim.keymap.set("i", "<C-Right>", "<C-o>w", { silent = true, desc = "Move right by word" })

----------------------------------------------------------------------
-- Ctrl+Backspace → cancella parola precedente
----------------------------------------------------------------------

vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true, silent = true, desc = "Delete previous word" })
vim.keymap.set("c", "<C-BS>", "<C-w>", { noremap = true, silent = true })

----------------------------------------------------------------------
-- Undo tree: <leader>u
----------------------------------------------------------------------

vim.keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>", { desc = "Undo tree" })

----------------------------------------------------------------------
-- Markdown preview
----------------------------------------------------------------------

vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Markdown: toggle preview" })


vim.keymap.set("n", "<leader>td", "<cmd>ToggleInlineDiagnostics<CR>", { desc = "Toggle inline diagnostics" })


vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics (Trouble)" })
