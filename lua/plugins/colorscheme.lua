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
