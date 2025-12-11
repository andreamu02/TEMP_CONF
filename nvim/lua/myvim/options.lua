-- ~/.config/nvim/lua/myvim/options.lua

vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.clipboard = "unnamedplus"
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.undodir = vim.fn.stdpath('data') .. '/undo'
vim.o.undofile = true
vim.fn.mkdir(vim.o.undodir, "p")
vim.o.mouse = "r"

vim.o.encoding = "utf-8"
vim.o.fileencoding = "utf-8"
