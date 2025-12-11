-- ~/.config/nvim/lua/myvim/python.lua

local uv = vim.loop

local function is_file(path)
  local s = uv.fs_stat(path)
  return s and s.type == "file"
end

local function is_dir(path)
  local s = uv.fs_stat(path)
  return s and s.type == "directory"
end

local function find_project_root(startpath)
  startpath = startpath or vim.loop.cwd()
  local markers = { "pyproject.toml", "setup.cfg", "setup.py", "Pipfile", ".git" }

  if vim.fs and vim.fs.find then
    local found = vim.fs.find(markers, { path = startpath, upward = true })
    if found and #found > 0 then
      return vim.fs.dirname(found[1])
    end
  else
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

local function find_python_in_root(root_dir)
  root_dir = root_dir or find_project_root()

  if vim.env.VIRTUAL_ENV and is_dir(vim.env.VIRTUAL_ENV) then
    local py = vim.fn.expand(vim.env.VIRTUAL_ENV .. "/bin/python")
    if is_file(py) then return py end
  end

  local local_candidates = { ".venv", "venv", "env" }
  for _, d in ipairs(local_candidates) do
    local candidate = root_dir .. "/" .. d .. "/bin/python"
    if is_file(candidate) then
      return candidate
    end
  end

  if is_file(root_dir .. "/pyproject.toml") and vim.fn.executable("poetry") == 1 then
    local cmd = "cd " .. vim.fn.shellescape(root_dir) .. " && poetry env info -p 2>/dev/null"
    local out = vim.fn.systemlist(cmd)
    if out and #out > 0 and out[1] ~= "" then
      local p = out[1] .. "/bin/python"
      if is_file(p) then return p end
    end
  end

  if is_file(root_dir .. "/Pipfile") and vim.fn.executable("pipenv") == 1 then
    local cmd = "cd " .. vim.fn.shellescape(root_dir) .. " && pipenv --py 2>/dev/null"
    local out = vim.fn.systemlist(cmd)
    if out and #out > 0 and out[1] ~= "" and is_file(out[1]) then
      return out[1]
    end
  end

  if is_file(root_dir .. "/.python-version") and vim.fn.executable("pyenv") == 1 then
    local cmd = "cd " .. vim.fn.shellescape(root_dir) .. " && pyenv which python 2>/dev/null"
    local out = vim.fn.systemlist(cmd)
    if out and #out > 0 and out[1] ~= "" and is_file(out[1]) then
      return out[1]
    end
  end

  local py3 = vim.fn.exepath("python3")
  if py3 ~= "" then return py3 end
  local py = vim.fn.exepath("python")
  if py ~= "" then return py end

  return "python"
end

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
