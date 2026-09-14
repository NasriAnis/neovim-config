return {
  "abecodes/tabout.nvim",
  event = "InsertEnter",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    tabkey = "<Tab>",
    backwards_tabkey = "<S-Tab>",
    act_as_tab = true,
    completion = true, -- lets tabout defer to blink.cmp when its menu is open
    ignore_beginning = true,
    tabouts = {
      { open = "'", close = "'" },
      { open = '"', close = '"' },
      { open = "`", close = "`" },
      { open = "(", close = ")" },
      { open = "[", close = "]" },
      { open = "{", close = "}" },
    },
    exclude = {},
  },
}
