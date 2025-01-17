local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local function run_cheat(query)
  -- -s: silent mode
  -- -L: follow redirects
  -- T: disable terminal capabilities reporting
  local cmd = string.format("curl -sL 'https://cht.sh/%s?T'", query:gsub(" ", "+"))
  local handle = io.popen(cmd)
  if handle == nil then
    return { "Failed to run jq command.", cmd }
  end
  local result = handle:read("*a")
  handle:close()
  return vim.split(result, "\n")
end

local function debounce(fn, ms)
  local timer = vim.uv.new_timer()
  return function(...)
    local args = { ... }
    timer:stop()
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule(function()
        fn(unpack(args))
      end)
    end)
  end
end

function M.query()
  local previewer_state = {
    bufnr = nil,
    latest_query = nil
  }

  local update_preview = debounce(function(bufnr, query)
    if query == previewer_state.latest_query then
      local results = run_cheat(query)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, results)
    end
  end, 180)

  pickers.new({}, {
    prompt_title = "Cheat.sh Query",
    finder = finders.new_dynamic({
      fn = function(prompt)
        if prompt and prompt ~= "" then
          return { { value = prompt } }
        else
          return {}
        end
      end,
      entry_maker = function(entry)
        return {
          value = entry.value,
          display = entry.value,
          ordinal = entry.value,
        }
      end,
    }),
    previewer = previewers.new_buffer_previewer({
      title = "Cheat.sh Result",
      define_preview = function(self, entry)
        previewer_state.bufnr = self.state.bufnr
        previewer_state.latest_query = entry.value
        vim.api.nvim_set_option_value("filetype", "markdown", { buf = self.state.bufnr })
        update_preview(self.state.bufnr, entry.value)
      end,
    }),
    layout_config = {
      height = 0.9,
      preview_cutoff = 0,
      prompt_position = "top",
      preview_height = 0.9,
    },
    layout_strategy = "vertical",
    attach_mappings = function(prompt_bufnr, map)
      local function open_in_split(split_cmd)
        local selection = action_state.get_selected_entry()
        if selection then
          local results = run_cheat(selection.value)
          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, results)
          vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
          actions.close(prompt_bufnr)
          vim.cmd(split_cmd)
          vim.api.nvim_set_current_buf(buf)
        end
      end

      map("i", "<C-v>", function() open_in_split("vsplit") end)
      map("i", "<C-s>", function() open_in_split("split") end)
      actions.select_default:replace(function() open_in_split("buffer") end)
      return true
    end,
  }):find()
end

return M
