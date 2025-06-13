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
    --   jot = "<leader>tj", -- Jot down a new todo
    --   focus = "<leader>tf", -- Focus submenu key
    --   due = "<leader>tfd", -- Due date focus submenu key
    --   hyperfocustoggle = "<leader>th", -- Toggle hyperfocus mode
    --   project = "<leader>tf+", -- Focus: Project
    --   context = "<leader>tf@", -- Focus: Context
    --   unfocus = "<leader>tu", -- Unfocus / Clear all focus
    --   refresh = "<leader>tr", -- Refresh view (sort & fold)
    --   all = "<leader>tfda", -- Focus Due: All
    --   now = "<leader>tfdn", -- Focus Due: Now (today/past/undated)
    --   due_only = "<leader>tfdd", -- Focus Due: Due only (today/past, excludes undated)
    --   scheduled = "<leader>tfds", -- Focus Due: Scheduled (any due date)
    --   unscheduled = "<leader>tfdu", -- Focus Due: Unscheduled (no due date)
    --   open_link = "<leader>tl", -- Open link on current line
    -- },

    -- startup = {
    --   focus = {
    --     date = "now",
    --     project = nil, -- Focus on todo's with no project
    --     context = {}, -- Optionally put a list of contexts here like { "home", "quick" }
    --   },
    --   load_focus_state = true, -- Load the focus state (date, project, context) on new Neovim sessions?
    --   hyperfocus_enabled = true,
    -- }

    -- Filetypes to activate folding and commands for
    -- filetypes = { "todo", "todos", "todo.txt" },

    -- List of file extensions considered text files for the open_link command.
    -- Files with these extensions will be opened in Neovim. Others externally.
    -- text_file_extensions = { ".txt", ".md", ... }, -- Uncomment and customize if needed
  },
}
```

## Usage

1. Open your `todo.txt` file (or any file matching the configured `filetypes`).
2. Ensure you have a backend configured for `vim.ui.select` (like [dressing.nvim](https://github.com/stevearc/dressing.nvim) or use the default TUI).
3. Use the keymaps (or commands) to manage your todos:
   - `<leader>to` (or `:TodoTxtOpen`): Opens the configured `todo.txt` file.
   - `<leader>tj` (or `:TodoTxtJot`): Prompts to quickly jot down and append a new todo item.
   - `<leader>tf+` (or `:TodoTxtProject`): Prompts to select a project (`+ProjectName`) to focus on.
   - `<leader>tf@` (or `:TodoTxtContext`): Prompts to select a context (`@ContextName`) to focus on.
   - `<leader>tfda` (or `:TodoTxtAll`): Focus on all tasks regardless of due date.
   - `<leader>tfdn` (or `:TodoTxtNow`): Focus on tasks due now (today, past due, or no due date).
   - `<leader>tfdd` (or `:TodoTxtDue`): Focus on tasks due only (today or past due, excludes undated).
   - `<leader>tfds` (or `:TodoTxtScheduled`): Focus on tasks with any due date.
   - `<leader>tfdu` (or `:TodoTxtUnscheduled`): Focus on tasks without a due date.
   - `<leader>tu` (or `:TodoTxtUnfocus`): Clears all current focuses (project, context, date).
   - `<leader>th` (or `:TodoTxtHyperfocus`): Toggle hyperfocus mode (shows only the current line).
   - `<leader>tr` (or `:TodoTxtRefresh`): Manually refresh the sorting and folding.
   - `<leader>tl` (or `:TodoTxtOpenLink`): Find and open links (URLs or file paths) on the current line. Prompts if multiple links are found. (New!)
