-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>xs", function()
  vim.diagnostic.open_float(nil, { border = "rounded", max_width = 80 })
end, { desc = "Show line diagnostics" })

vim.keymap.set("n", "<leader>zg", function() require("util.gh").menu() end, { desc = "gh: menu" })
vim.keymap.set("n", "<leader>zG", function() require("util.gh").help() end, { desc = "gh: help reference" })

vim.keymap.set("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

-- vim.keymap.set("n", "<leader>uc", function()
--   require("util.colorscheme").pick()
-- end, { desc = "Select colorscheme (persisted)" })
--
-- vim.api.nvim_create_user_command("Colorscheme", function()
--   require("util.colorscheme").pick()
-- end, {})
