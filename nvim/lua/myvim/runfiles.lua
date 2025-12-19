----------------------------------------------------------------------
-- Terminal / Run current file (toggleterm)
----------------------------------------------------------------------

local function run_current_file()
  local ft = vim.bo.filetype
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end

  local cmd
  if ft == "python" then
    -- Usa il python del PATH (che ora sarà quello del venv/progetto, vedi sotto)
    cmd = "python " .. vim.fn.shellescape(file)
  elseif ft == "cpp" then
    -- build in un binario affiancato al file (senza estensione) e lancia
    local output = vim.fn.expand("%:p:r")
    cmd = string.format(
      "g++ -Wall -Wextra -g %s -o %s && %s",
      vim.fn.shellescape(file),
      vim.fn.shellescape(output),
      vim.fn.shellescape(output)
    )
  elseif ft == 'c' then
    local output = vim.fn.expand("%:p:r")
    cmd = string.format(
      "gcc -Wall -Wextra -g %s -o %s && %s",
      vim.fn.shellescape(file),
      vim.fn.shellescape(output),
      vim.fn.shellescape(output)
    )
  elseif ft == "rust" then
    -- per Rust assumiamo un progetto cargo
    cmd = "cargo run --release"
  else
    vim.notify("No run command configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  cmd = vim.fn.escape(cmd, '"')
  vim.cmd('TermExec cmd="' .. cmd .. '"')
end

vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>tr", run_current_file, { desc = "Run current file/project" })
