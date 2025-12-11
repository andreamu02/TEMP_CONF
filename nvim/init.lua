-- ~/.config/nvim/init.lua
---@diagnostic disable: undefined-global

-- Ensure Mason binaries are in Neovim's PATH
vim.env.PATH = vim.env.HOME .. '/.local/share/nvim/mason/bin:' .. vim.env.PATH

vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Bootstrap lazy.nvim
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

-- Carica i vari moduli
require("myvim.options")
require("myvim.plugins")
require("myvim.lsp")
require("myvim.completion")
require("myvim.keymaps")
require("myvim.autocmds")
require("myvim.python")

print('Neovim starter config loaded — enjoy coding in Rust!')
