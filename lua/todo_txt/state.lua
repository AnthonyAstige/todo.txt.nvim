local M = {}
local fn, json = vim.fn, vim.fn

local path = fn.stdpath("state") .. "/todo_txt_focus.json"

local function safe_read()
  local f = io.open(path, "r")
  if not f then return nil end
  local d = f:read("*a"); f:close(); return d
end

local function safe_write(s)
  local f, err = io.open(path, "w")
  if f then f:write(s); f:close() end
end

function M.load()
  local raw = safe_read()
  if not raw or raw == "" then return end
  local ok, t = pcall(json.json_decode, raw)
  if ok and type(t) == "table" then
    vim.g.todo_txt_date_filter     = t.date_filter     or vim.g.todo_txt_date_filter
    vim.g.todo_txt_context_pattern = t.context_pattern or vim.g.todo_txt_context_pattern
    vim.g.todo_txt_project_pattern = t.project_pattern or vim.g.todo_txt_project_pattern
  end
end

function M.save()
  safe_write(json.json_encode({
    date_filter     = vim.g.todo_txt_date_filter,
    context_pattern = vim.g.todo_txt_context_pattern,
    project_pattern = vim.g.todo_txt_project_pattern,
  }))
end

return M
