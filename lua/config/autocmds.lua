-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
--e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local autosave_grp = vim.api.nvim_create_augroup("AutoSaveOnInsertLeave", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = autosave_grp,
  pattern = "*",
  callback = function(args)
    local buf = args.buf
    -- Avoid saving special buffers (e.g. Neo-tree, terminal, prompt) or read-only files
    if vim.bo[buf].modified
      and vim.bo[buf].buftype == ""
      and vim.bo[buf].modifiable
      and not vim.bo[buf].readonly
      and vim.api.nvim_buf_get_name(buf) ~= "" then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! noautocmd write")
      end)

      -- noautocmd write skips the LSP client's BufWritePost hook,
      -- so manually send didSave to make servers like rust-analyzer
      -- (checkOnSave) refresh diagnostics
      local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
        client.notify("textDocument/didSave", params)
      end
    end
  end,
  desc = "Silently auto-save normal buffers on InsertLeave and TextChanged",
})


vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "diffview://*",
  callback = function(args)
    vim.diagnostic.enable(false, { bufnr = args.buf })
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
      vim.lsp.buf_detach_client(args.buf, client.id)
    end
  end,
})

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    local venv = vim.fn.getcwd() .. "/.venv"
    if vim.fn.isdirectory(venv) == 1 then
      vim.env.VIRTUAL_ENV = venv
      vim.env.PATH = venv .. "/bin:" .. vim.env.PATH
    end
  end,
})

-- Persist whatever colorscheme gets applied (covers <leader>uC, :colorscheme, etc.)
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    if vim.g.colors_name then
      require("util.colorscheme").save(vim.g.colors_name)
    end
  end,
})
