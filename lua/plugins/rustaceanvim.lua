return {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { "rust" },
    init = function()
        vim.g.rustaceanvim = {
            tools = {
                hover_actions = {
                    auto_focus = true,
                },
            },
            server = {
                on_attach = function(client, bufnr)
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                    end
                    map("n", "<leader>ca", function()
                        vim.cmd.RustLsp("codeAction")
                    end, "Rust Code Action")
                    map("n", "K", function()
                        vim.cmd.RustLsp({ "hover", "actions" })
                    end, "Hover Actions")
                    map("n", "<leader>cR", function()
                        vim.cmd.RustLsp("runnables")
                    end, "Runnables")
                    map("n", "<leader>cE", function()
                        vim.cmd.RustLsp("expandMacro")
                    end, "Expand Macro")
                    map("n", "<leader>cp", function()
                        vim.cmd.RustLsp("parentModule")
                    end, "Parent Module")
                end,
                default_settings = {
                    ["rust-analyzer"] = {
                        cargo = { allFeatures = true },
                        checkOnSave = true,
                        check = { command = "clippy" },
                    },
                },
            },
        }
    end,
}
