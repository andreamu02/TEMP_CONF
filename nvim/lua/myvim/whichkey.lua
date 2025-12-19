-- lua/myvim/whichkey.lua

local ok, wk = pcall(require, "which-key")
if not ok then
  return
end

wk.setup({
  plugins = {
    marks = true,
    registers = true,
    spelling = { enabled = false },
  },
  icons = {
    breadcrumb = "»",
    separator = "➜",
    group = "+",
  },
  window = {
    border = "rounded",
  },
})

-- Nuova spec suggerita da :checkhealth
wk.add({
  { "<leader>f", group = "Find" },
  { "<leader>g", group = "Git" },
  { "<leader>l", group = "LSP" },
})
