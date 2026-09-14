return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    direction = "tab",
    open_mapping = [[<c-/>]],
    persist_mode = true,
    close_on_exit = false,
    start_in_insert = true,
  },
  keys = {
    {
      "<c-/>",
      function()
        require("toggleterm").toggle(1, nil, vim.fn.expand("%:p:h"), "tab")
      end,
      desc = "Toggle terminal (cwd = current file)",
      mode = { "n", "t" },
    },
  },
}
