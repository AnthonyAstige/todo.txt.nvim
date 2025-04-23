# todo.txt.nvim

A Neovim plugin to dynamically focus on todo's in your `todo.txt` file based on projects (`+Project`) and contexts (`@Context`).

## Dependencies

- [Neovim](https://neovim.io/) (0.8+) with a configured `vim.ui.select` backend (e.g., [dressing.nvim](https://github.com/stevearc/dressing.nvim) or the default TUI).
- (Optional) [which-key.nvim](https://github.com/folke/which-key.nvim) for improved keymap descriptions.

## Installation / configuration

### [Lazy.nvim](https://github.com/folke/lazy.nvim)

Place somewhere like `~/.config/nvim/lua/plugins/todo.txt.lua`:

The plugin comes with the following default configuration:

```lua
return {
  "AnthonyAstige/todo.txt.nvim",
  opts = {
    -- todo_file = "~/path/to/your/todo.txt",

    -- keymaps = {
    --   top = "<leader>t", -- Base menu key
    --   open_file = "<leader>to", -- Open the configured todo.txt file
    --   focus = "<leader>tf", -- Focus submenu key
    --   due = "<leader>tfd", -- Due date focus submenu key
    --   hyperfocustoggle = "<leader>th", -- Toggle hyperfocus mode
    --   project = "<leader>tf+", -- Focus: Project
    --   context = "<leader>tf@", -- Focus: Context
    --   unfocus = "<leader>tu", -- Unfocus / Clear all focus
    --   refresh = "<leader>tr", -- Refresh view (sort & fold)
    --   all = "<leader>tfda", -- Focus Due: All
    --   now = "<leader>tfdn", -- Focus Due: Now
    -- },

    -- startup = {
    --   focus = {
    --     date = "now",
    --     project = nil, -- Focus on todo's with no project
    --     context = "",
    --   },
    --   hyperfocus_enabled = true,
    -- }

    -- Filetypes to activate folding and commands for
    -- filetypes = { "todo", "todos", "todo.txt" },
  },
}
```

## Usage

1. Open your `todo.txt` file (or any file matching the configured `filetypes`).
2. Ensure you have a backend configured for `vim.ui.select` (like [dressing.nvim](https://github.com/stevearc/dressing.nvim) or use the default TUI).
3. Use the keymaps (or commands) to focus:
   - `<leader>to` (or `:TodoTxtOpen`): Opens the configured `todo.txt` file.
   - `<leader>tf+` (or `:TodoTxtProject`): Prompts to select a project (`+ProjectName`) to focus on.
   - `<leader>tf@` (or `:TodoTxtContext`): Prompts to select a context (`@ContextName`) to focus on.
   - `<leader>tfdn` (or `:TodoTxtNow`): Focus on tasks due now (today, past due, or no due date).
   - `<leader>tfda` (or `:TodoTxtAll`): Focus on tasks regardless of due date.
   - `<leader>tu` (or `:TodoTxtUnfocus`): Clears all current focuses (project, context, date).
   - `<leader>th` (or `:TodoTxtHyperfocus`): Toggle hyperfocus mode (shows only the current line).
   - `<leader>tr` (or `:TodoTxtRefresh`): Manually refresh the sorting and folding.
