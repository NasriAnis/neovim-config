return {
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
        },
        cmd = "Neogit",
        opts = {
            kind = "tab",
            integrations = {
                diffview = true,
            },
        },
        keys = {
            { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit Status" },
        },
    },
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            current_line_blame = false,
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
                end

                -- Navigation
                map("n", "]c", gs.next_hunk, "Next hunk")
                map("n", "[c", gs.prev_hunk, "Prev hunk")

                -- Stage Operations
                map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                map("v", "<leader>hs", function()
                    gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Stage selected lines")
                map("n", "<leader>hS", gs.stage_buffer, "Stage whole buffer")
                map("n", "<leader>hu", gs.undo_stage_hunk, "Undo last staged hunk")

                -- Restore / Reset Operations
                map("n", "<leader>hr", gs.reset_hunk, "Restore / Reset hunk")
                map("v", "<leader>hr", function()
                    gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, "Restore selected lines")
                map("n", "<leader>hR", gs.reset_buffer, "Restore / Reset whole file")

                -- Previews & Blame
                map("n", "<leader>hp", gs.preview_hunk_inline, "Preview hunk inline")
                map("n", "<leader>hb", function()
                    gs.blame_line({ full = true })
                end, "Blame line (full info)")
            end,
        },
        config = function(_, opts)
            require("gitsigns").setup(opts)

            local function set_gitsigns_colors()
                vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#89b482" }) -- green
                vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#d8a657" }) -- yellow
                vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#ea6962" }) -- red
                vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = "#ea6962" })
                vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = "#d8a657" })
            end

            set_gitsigns_colors()

            -- reapply every time you switch colorscheme, so it never gets wiped
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = set_gitsigns_colors,
            })
        end,
    },
}
