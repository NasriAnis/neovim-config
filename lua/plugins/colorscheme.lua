-- return {
--   {
--     "rose-pine/neovim",
--     name = "rose-pine",
--     lazy = false,
--     priority = 1000,
--     -- opts = {
--     --   styles = {
--     --     transparency = true,
--     --   },
--     -- },
--   },
--
--   {
--     "Mofiqul/dracula.nvim",
--     lazy = false,
--     priority = 1000,
--   },
--
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = function()
--         if not require("util.colorscheme").load() then
--           vim.cmd.colorscheme("rose-pine")
--         end
--       end,
--     },
--   },
-- }
return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    -- opts = {
    --   styles = {
    --     transparency = true,
    --   },
    -- },
  },

  {
    "Mofiqul/dracula.nvim",
    lazy = false,
    priority = 1000,
  },

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  {
    "navarasu/onedark.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "darker", -- or "darker", "cool", "deep", "warm", "warmer", "light"
    },
  },

  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        if not require("util.colorscheme").load() then
          vim.cmd.colorscheme("rose-pine")
        end
      end,
    },
  },
}
