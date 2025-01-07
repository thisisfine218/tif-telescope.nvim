local M = {}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)
  -- Calculate the position to center the window
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  -- Create a buffer
  local buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  -- Define window configuration
  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal", -- No borders or extra UI elements
    border = "rounded",
  }
  -- Create the floating window
  local win = vim.api.nvim_open_win(buf, true, win_config)
  return { buf = buf, win = win }
end

--- Run a jq query on the current buffer's content
--- @param query string: The jq query to run
--- @return string[]: The output of the jq command
local function run_jq(query)
  -- Get the current buffer's file path
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    file_path = "test.json"
  end

  if file_path == "" then
    print("No file detected.")
    return { "No file detected." }
  end

  -- Construct the jq command
  local cmd = string.format("jq '%s' '%s'", query, file_path)

  -- Run the command and capture the output
  local handle = io.popen(cmd)
  if handle == nil then
    print("Failed to run jq command.")
    return { "Failed to run jq command." }
  end

  local result = handle:read("*a")
  handle:close()

  return vim.split(result, "\n")
end

M.setup = function() end

M.query = function()
  local query = vim.fn.input("Enter your query: ")
  local win = create_floating_window()
  local result = run_jq(query)
  vim.api.nvim_buf_set_lines(win.buf, 0, -1, false, result)
end

return M
