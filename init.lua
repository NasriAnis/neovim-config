-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.options")
require("config.autocmds")
require("config.keymaps")
require("util.colorscheme").apply_saved()
