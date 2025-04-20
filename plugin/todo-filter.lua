-- This file ensures the plugin is loaded.
-- For users not using a plugin manager that calls setup automatically,
-- this provides a basic loading mechanism.
-- LazyVim users typically configure the plugin via the `opts` table,
-- which calls the `setup` function directly.

-- Check if setup has already been called (e.g., by LazyVim)
-- This simple check might not be foolproof in all scenarios.
if not require('lazy.core.config').is_plugin_loaded('todo-filter.nvim') then
  -- Attempt to load and setup if not managed by LazyVim or similar.
  -- Users should ideally call setup() themselves in their config.
  pcall(require, 'todo-filter')
  -- We don't call setup() here automatically to avoid potential double-loading
  -- or loading with default options when user config is intended.
  -- If not using LazyVim, users should call: require('todo-filter').setup({...})
end
