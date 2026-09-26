return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}

-- lua/plugins/snack.lua (or wherever your snacks spec lives)
-- return {
--   {
--     "folke/snacks.nvim",
--     opts = {
--       explorer = { enabled = false },
--     },
--     keys = {
--       { "<leader>e", false },
--       { "<leader>E", false },
--       { "<leader>fe", false },
--       { "<leader>fE", false },
--     },
--   },
-- {
--         "nvim-tree/nvim-tree.lua",
-- dependencies = {
--     "nvim-tree/nvim-web-devicons",
-- },
--
-- config = function()
--     require("nvim-tree").setup({
--         sync_root_with_cwd = true,
--         respect_buf_cwd = false,
--         update_focused_file = {
--             enable = true,
--             update_root = { enable = false },
--         },
--         sort = {
--             sorter = "case_sensitive",
--         },
--         view = {
--             side = "left",
--             width = 30,
--             preserve_window_proportions = true,
--         },
--         actions = {
--             open_file = {
--                 quit_on_open = false, -- keep tree open after opening a file
--             },
--         },
--         renderer = {
--             group_empty = true,
--             highlight_opened_files = "all",
--             indent_width = 1,
--             icons = {
--                 show = {
--                     file = true,
--                     folder = false,      -- no folder icons
--                     folder_arrow = true, -- keep the chevron/arrow
--                     git = true,         -- optional: drop the git status glyphs too
--                 },
--                 glyphs = {
--                     folder = {
--                         arrow_closed = ">",
--                         arrow_open = "v",
--                     },
--                 },
--             },
--         },
--         filters = {
--             dotfiles = false,     -- show dotfiles
--             git_ignored = false,  -- show gitignored files/folders
--         },
--     })
--
--     vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")
-- end,
-- }
-- }
