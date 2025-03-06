local M = {}

-- Function to find ## headings and display them in a selection menu
M.grep_headers = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) -- Get all lines in the buffer
  local headers = {}
  local line_numbers = {}

  -- Find all lines containing "## " anywhere
  for i, line in ipairs(lines) do
    if line:match '^## ' then
      table.insert(headers, line) -- Store the header text
      table.insert(line_numbers, i) -- Store the line number
    end
  end

  -- If no headers found, notify the user
  if #headers == 0 then
    vim.notify('No main headers found!', vim.log.levels.WARN)
    return
  end

  -- Use vim.ui.select() with key mappings for space/enter and right arrow/tab
  local function select_handler(choice, idx)
    if choice then
      local selected_line = line_numbers[idx]

      -- Navigation: Enter or Space moves to the selected header
      vim.api.nvim_win_set_cursor(0, { selected_line, 0 })
    end
  end

  vim.ui.select(headers, {
    prompt = 'Select a header (→/Tab to open sub-sections, Enter/Space to jump):',
  }, select_handler)
end

-- Function to find ### subheadings within a section
M.open_subheaders = function(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local subheaders = {}
  local sub_line_numbers = {}

  for i, line in ipairs(lines) do
    if line:match '### ' then
      table.insert(subheaders, line)
      table.insert(sub_line_numbers, start_line + i - 1) -- Adjust index for buffer
    end
  end

  -- If no subheaders found, notify and return
  if #subheaders == 0 then
    vim.notify('No sub-sections found!', vim.log.levels.WARN)
    return
  end

  -- Show the second selection menu
  vim.ui.select(subheaders, {
    prompt = 'Select a sub-section (Enter/Space to jump):',
  }, function(choice, idx)
    if choice then
      vim.api.nvim_win_set_cursor(0, { sub_line_numbers[idx], 0 }) -- Move to selected subheader
    end
  end)
end

return M
