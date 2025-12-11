-- ~/.config/nvim/lua/myvim/autocmds.lua

-- Autoformat templates on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.j2", "*.jinja", "*.jinja2", "*.html.j2", "*.htmldjango", "*.jinja" },
  callback = function()
    local ok_conf, conform = pcall(require, "conform")
    if ok_conf and conform then
      local ok_fmt, _ = pcall(conform.format, { async = false })
      if ok_fmt then return end
    end
    if vim.fn.executable("djlint") == 1 then
      local view = vim.fn.winsaveview()
      local ok, _ = pcall(vim.cmd, "%!djlint -")
      if ok then vim.fn.winrestview(view) end
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py" },
  callback = function() require("conform").format({ async = false }) end,
})

-- Inline diagnostics toggle
_G.inline_diag_enabled = false

local function update_inline_diags()
  local bufnr = 0 -- buffer corrente
  if _G.inline_diag_enabled then
    vim.diagnostic.show(nil, bufnr)
  else
    vim.diagnostic.hide(nil, bufnr)
  end
end

vim.api.nvim_create_user_command("ToggleInlineDiagnostics", function()
  _G.inline_diag_enabled = not _G.inline_diag_enabled
  update_inline_diags()
  print("Inline diagnostics " .. (_G.inline_diag_enabled and "ON" or "OFF"))
end, {})

vim.api.nvim_create_autocmd({ "BufReadPost", "DiagnosticChanged" }, {
  callback = update_inline_diags,
})


-- nvim-lightbulb
vim.cmd([[
  autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()
]])

-- Highlight on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.hl.on_yank{higroup="IncSearch", timeout=200}
  augroup end
]]

