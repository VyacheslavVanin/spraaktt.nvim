-- Plugin: spraaktt.nvim
-- Description: Speech recognition plugin for Neovim
-- Author: vaninvv

local spraaktt = require('spraaktt')

-- Initialize the plugin - starts the spraaktt process
spraaktt.setup()

-- Define the commands
vim.api.nvim_create_user_command('SpraakttStart', function()
  spraaktt.start()
end, {})

vim.api.nvim_create_user_command('SpraakttStop', function()
  spraaktt.stop()
end, {})

-- Store the module reference for later use if needed
_G.spraaktt = spraaktt