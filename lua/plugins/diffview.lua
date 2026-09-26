return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory" },
    keys = {
        { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Diffview (uncommitted)" },
        { "<leader>gV", "<cmd>DiffviewOpen main<cr>", desc = "Diffview (vs main)" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
        { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (repo)" },
        { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    },
    opts = {
        enhanced_diff_hl = true, -- better hunk highlighting, less noisy
        view = {
            default = {
                layout = "diff2_horizontal",
            },
            merge_tool = {
                layout = "diff3_horizontal",
                disable_diagnostics = true,
            },
        },
    },
}
