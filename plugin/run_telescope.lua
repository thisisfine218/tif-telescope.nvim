vim.api.nvim_create_user_command("TifJq", function(opts)
  require("tif-jq").query(opts.args)
end, {
  nargs = "?", -- Allows 0 or 1 argument
})

vim.api.nvim_create_user_command("TifCheat", function()
  require("tif-cheatsh").query()
end, {})
