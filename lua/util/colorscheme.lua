local M = {}

local data_file = vim.fn.stdpath("data") .. "/colorscheme.txt"

--- Persist a colorscheme name to disk
function M.save(name)
  local f = io.open(data_file, "w")
  if f then
    f:write(name)
    f:close()
  end
end

--- Read the persisted colorscheme name, if any
function M.load()
  local f = io.open(data_file, "r")
  if f then
    local name = f:read("*all")
    f:close()
    name = name:gsub("%s+$", "")
    return name ~= "" and name or nil
  end
  return nil
end

--- Apply the saved colorscheme on startup, falling back silently if missing
function M.apply_saved()
  local name = M.load()
  if name then
    local ok = pcall(vim.cmd.colorscheme, name)
    if not ok then
      vim.notify("Saved colorscheme '" .. name .. "' not found, falling back", vim.log.levels.WARN)
    end
  end
end

return M
