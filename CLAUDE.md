# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This is a pure Lua Neovim plugin with no build system. Common development tasks:

- **Manual Testing**: Open a todo.txt file in Neovim and test plugin functionality (should be done by user)

## Architecture Overview

This plugin implements a focus-based todo.txt management system using Vim's folding mechanism rather than buffer filtering:

1. **Focus System**: Central concept where todos are filtered by:
   - Date (now = today/overdue/undated, all = everything)
   - Context (@tag) - supports multiple contexts
   - Project (+tag) - single project focus

2. **Visibility Implementation**: Uses `foldexpr` to hide non-focused items rather than modifying buffer content. This preserves file integrity while providing visual filtering.

3. **State Persistence**: Focus state (date_filter, context_pattern, project_pattern) persists across sessions via JSON file in Neovim's state directory.

4. **Module Responsibilities**:
   - `init.lua`: Plugin setup and autocmd registration
   - `focus.lua`: Core logic determining which todos are "in focus"
   - `folding.lua`: Implements foldexpr to hide out-of-focus items
   - `hyperfocus.lua`: Uses conceal to show only current line
   - `jot.lua`: Quick capture with project selection
   - `commands.lua` & `keymaps.lua`: User interface setup

5. **Key Patterns**:
   - Tags extracted dynamically from buffer content
   - UI interactions use `vim.ui.select` (works with dressing.nvim)
   - Global variables (`vim.g.*`) store current filter state
   - Modular design with clear separation of concerns

