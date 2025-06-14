# todo.txt.nvim

A Neovim plugin to dynamically focus on todo's in your `todo.txt` file based on projects (`+Project`) and contexts (`@Context`).

## Features

- **Project and Context Filtering**: Focus on specific projects (`+Project`) or contexts (`@Context`)
- **Date-based Filtering**: View tasks by due date (current, due, scheduled, unscheduled)
- **Time Estimates**: Filter tasks by estimated time using `est:` tags
- **Hyperfocus Mode**: Show only the current line for distraction-free editing
- **Smart Sorting**: Automatically sorts by focus status, priority, estimate, then alphabetically
- **Quick Capture**: Jot down new todos with project selection
- **State Persistence**: Remember your focus settings across sessions

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
    --   estimate = "<leader>tfe", -- Estimate focus submenu key
    --   hyperfocustoggle = "<leader>th", -- Toggle hyperfocus mode
    --   project = "<leader>tf+", -- Focus: Project
    --   hide_project = "<leader>tf-", -- Hide: Project(s)
    --   context = "<leader>tf@", -- Focus: Context
    --   unfocus = "<leader>tu", -- Unfocus / Clear all focus
    --   refresh = "<leader>tr", -- Refresh view (sort & fold)
    --   all = "<leader>tfda", -- Focus Due: All
    --   current = "<leader>tfdc", -- Focus Due: Current (today/past/undated)
    --   due = "<leader>tfdd", -- Focus Due: Due (today/past, excludes undated)
    --   scheduled = "<leader>tfds", -- Focus Due: Scheduled (any due date)
    --   unscheduled = "<leader>tfdu", -- Focus Due: Unscheduled (no due date)
    --   estimate_short = "<leader>tfes", -- Focus Estimate: Short (≤15m)
    --   estimate_medium = "<leader>tfem", -- Focus Estimate: Medium (16-60m)
    --   estimate_long = "<leader>tfel", -- Focus Estimate: Long (>60m ≤4h)
    --   estimate_day = "<leader>tfed", -- Focus Estimate: Day (>4h ≤5d or d-suffix)
    --   estimate_week = "<leader>tfew", -- Focus Estimate: Week (>5d or w-suffix)
    --   estimate_has = "<leader>tfea", -- Focus Estimate: Has any estimate
    --   estimate_none = "<leader>tfen", -- Focus Estimate: Has no estimate
    --   open_link = "<leader>tl", -- Open link on current line
    -- },

    -- startup = {
    --   focus = {
    --     date = "current",
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

### Time Estimates

Add time estimates to your tasks using the `est:` tag:

- `est:15` - 15 minutes
- `est:2h` - 2 hours
- `est:3d` - 3 days  
- `est:1w` - 1 week

The plugin converts all estimates to minutes internally:
- `h` suffix: hours (multiplied by 60)
- `d` suffix: days (multiplied by 240, assuming 4 hours of productive work per day)
- `w` suffix: weeks (multiplied by 1200, assuming 5 days * 4 hours per week)

### Commands and Keymaps

1. Open your `todo.txt` file (or any file matching the configured `filetypes`).
2. Ensure you have a backend configured for `vim.ui.select` (like [dressing.nvim](https://github.com/stevearc/dressing.nvim) or use the default TUI).
3. Use the keymaps (or commands) to manage your todos:

**Basic Operations:**
   - `<leader>to` (or `:TodoTxtOpen`): Opens the configured `todo.txt` file.
   - `<leader>tj` (or `:TodoTxtJot`): Prompts to quickly jot down and append a new todo item.
   - `<leader>tu` (or `:TodoTxtUnfocus`): Clears all current focuses (project, context, date, estimate).
   - `<leader>th` (or `:TodoTxtHyperfocus`): Toggle hyperfocus mode (shows only the current line).
   - `<leader>tr` (or `:TodoTxtRefresh`): Manually refresh the sorting and folding.
   - `<leader>tl` (or `:TodoTxtOpenLink`): Find and open links (URLs or file paths) on the current line.

**Project & Context Filtering:**
   - `<leader>tf+` (or `:TodoTxtProject`): Prompts to select a project (`+ProjectName`) to focus on.
   - `<leader>tf-` (or `:TodoTxtHideProject`): Prompts to select project(s) to hide from view. Supports multiple hidden projects.
   - `<leader>tf@` (or `:TodoTxtContext`): Prompts to select a context (`@ContextName`) to focus on.

**Date-based Filtering:**
   - `<leader>tfda` (or `:TodoTxtAll`): Focus on all tasks regardless of due date.
   - `<leader>tfdc` (or `:TodoTxtCurrent`): Focus on tasks due currently (today, past due, or no due date).
   - `<leader>tfdd` (or `:TodoTxtDue`): Focus on tasks due (today or past due, excludes undated).
   - `<leader>tfds` (or `:TodoTxtScheduled`): Focus on tasks with any due date.
   - `<leader>tfdu` (or `:TodoTxtUnscheduled`): Focus on tasks without a due date.

**Estimate-based Filtering:**
   - `<leader>tfes` (or `:TodoTxtShort`): Focus on tasks with short estimates (≤15 minutes).
   - `<leader>tfem` (or `:TodoTxtMedium`): Focus on tasks with medium estimates (16-60 minutes).
   - `<leader>tfel` (or `:TodoTxtLong`): Focus on tasks with long estimates (>60 minutes, ≤4 hours).
   - `<leader>tfed` (or `:TodoTxtDays`): Focus on tasks with day-sized estimates (>4 hours, ≤5 days, or with 'd' suffix).
   - `<leader>tfew` (or `:TodoTxtWeeks`): Focus on tasks with week-sized estimates (>5 days or with 'w' suffix).
   - `<leader>tfea` (or `:TodoTxtHasEstimate`): Focus on tasks with any time estimate.
   - `<leader>tfen` (or `:TodoTxtNoEstimate`): Focus on tasks without time estimates.

### Sorting

Tasks are automatically sorted using the following priority order:

1. **Focus status**: Focused tasks appear before unfocused tasks
2. **Priority**: Tasks with priorities (A) come before (B), (B) before (C), etc.
3. **Estimate size**: Smaller estimates appear before larger ones
4. **Alphabetically**: Tasks are sorted alphabetically as a final tiebreaker

This smart sorting helps you tackle high-priority, quick tasks first while keeping your todo list organized.

### Combining Filters

Filters work together to help you find exactly what you need. For example:
- Focus on `+work` project AND tasks with short estimates (≤15m) for quick wins
- View current tasks (due today/overdue/undated) in `@home` context
- Find all unestimated tasks in a specific project to plan your time

The estimate filter combines with project, context, and date filters to give you precise control over what tasks you see.
