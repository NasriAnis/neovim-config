return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts.servers = opts.servers or {}

    local function has_sdkconfig()
      return vim.fn.filereadable(vim.fn.getcwd() .. "/sdkconfig") == 1
        or vim.fs.find("sdkconfig", { upward = true })[1] ~= nil
    end

    if has_sdkconfig() then
      opts.servers.clangd = require("esp32").lsp_config()
    end
    -- otherwise: leave clangd unconfigured, LazyVim's default clangd setup applies

    return opts
  end,
}