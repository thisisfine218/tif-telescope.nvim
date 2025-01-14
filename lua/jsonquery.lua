local M = {}
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")

local current_file = ""

local function run_jq(query)
  if current_file == "" then
    return { "No file detected." }
  end

  local cmd = string.format("jq '%s' '%s' 2>&1", query, current_file)

  local handle = io.popen(cmd)
  if handle == nil then
    return { "Failed to run jq command.", cmd }
  end

  local result = handle:read("*a")
  handle:close()

  return vim.split(result, "\n")
end

local function jq_previewer()
  return previewers.new_buffer_previewer({
    title = "JQ Query Result",
    get_buffer_by_name = function()
      return "JQ Result"
    end,
    define_preview = function(self, entry)
      local results = run_jq(entry.value)
      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, results)
      -- Set buffer filetype to JSON for syntax highlighting
      vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "json")
    end,
  })
end

function M.query()
  current_file = vim.fn.expand("%:p")
  pickers.new({}, {
    prompt_title = "JQ Query " .. current_file,
    finder = finders.new_dynamic({
      fn = function(prompt)
        -- Return the prompt itself as the entry
        if prompt and prompt ~= "" then
          return { { value = prompt, display = prompt } }
        else
          return {}
        end
      end,
      entry_maker = function(entry)
        return {
          value = entry.value,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = jq_previewer(),
    layout_config = {
      height = 0.9,
      preview_cutoff = 0,
      prompt_position = "top",
      preview_height = 0.9,
    },
    layout_strategy = "vertical",
    attach_mappings = function(prompt_bufnr, map)
      -- Open in vertical split with Ctrl+v
      map("i", "<C-v>", function()
        local selection = action_state.get_selected_entry()
        if selection then
          local results = run_jq(selection.value)
          -- Create a new buffer for the results
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, results)
          -- Set buffer filetype to JSON
          vim.api.nvim_buf_set_option(buf, "filetype", "json")
          -- Close Telescope
          actions.close(prompt_bufnr)
          -- Switch to the new buffer
          vim.cmd("vsplit")
          vim.api.nvim_set_current_buf(buf)
        end
      end)
      -- Open in horizontal split with Ctrl+s
      map("i", "<C-s>", function()
        local selection = action_state.get_selected_entry()
        if selection then
          local results = run_jq(selection.value)
          -- Create a new buffer for the results
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, results)
          -- Set buffer filetype to JSON
          vim.api.nvim_buf_set_option(buf, "filetype", "json")
          -- Close Telescope
          actions.close(prompt_bufnr)
          -- Switch to the new buffer
          vim.cmd("split")
          vim.api.nvim_set_current_buf(buf)
        end
      end)
      -- Apply the JQ query when Enter is pressed
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection then
          local results = run_jq(selection.value)
          -- Create a new buffer for the results
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, results)
          -- Set buffer filetype to JSON
          vim.api.nvim_buf_set_option(buf, "filetype", "json")
          -- Close Telescope
          actions.close(prompt_bufnr)
          -- Switch to the new buffer
          vim.api.nvim_set_current_buf(buf)
        end
      end)
      return true
    end,
  }):find()
end

function M.setup()
  -- Add any setup configuration here if needed
end

return M
