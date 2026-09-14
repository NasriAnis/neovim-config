return {
    "pwntester/octo.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "ibhagwan/fzf-lua",
    },
    config = function()
        require("octo").setup({
            picker = "fzf-lua",
        })

        local map = vim.keymap.set

        -- ============================================================
        -- z p : PR entry points (list, create, checkout, search)
        -- ============================================================
        map("n", "<leader>zpl", "<cmd>Octo pr list<CR>", { desc = "PR: List" })
        map("n", "<leader>zpc", "<cmd>Octo pr create<CR>", { desc = "PR: Create" })
        map("n", "<leader>zpo", "<cmd>Octo pr checkout<CR>", { desc = "PR: Checkout (open someone's branch)" })
        map("n", "<leader>zpd", "<cmd>Octo pr diff<CR>", { desc = "PR: Show full diff" })
        map("n", "<leader>zpb", "<cmd>Octo pr browser<CR>", { desc = "PR: Open in browser" })
        map("n", "<leader>zpy", "<cmd>Octo pr url<CR>", { desc = "PR: Copy URL" })
        map("n", "<leader>zpr", "<cmd>Octo pr ready<CR>", { desc = "PR: Mark ready for review" })
        map("n", "<leader>zpR", "<cmd>Octo pr reopen<CR>", { desc = "PR: Reopen" })

        -- ============================================================
        -- z i : Issues
        -- ============================================================
        map("n", "<leader>zil", "<cmd>Octo issue list<CR>", { desc = "Issue: List" })
        map("n", "<leader>zic", "<cmd>Octo issue create<CR>", { desc = "Issue: Create" })
        map("n", "<leader>zib", "<cmd>Octo issue browser<CR>", { desc = "Issue: Open in browser" })
        map("n", "<leader>ziC", "<cmd>Octo issue close<CR>", { desc = "Issue: Close" })
        map("n", "<leader>ziR", "<cmd>Octo issue reopen<CR>", { desc = "Issue: Reopen" })

        -- ============================================================
        -- z r : Reviewing someone else's PR (the diff/review session)
        -- ============================================================
        map("n", "<leader>zrs", "<cmd>Octo review start<CR>", { desc = "Review: Start" })
        map("n", "<leader>zru", "<cmd>Octo review resume<CR>", { desc = "Review: Resume (unfinished)" })
        map("n", "<leader>zrd", "<cmd>Octo review discard<CR>", { desc = "Review: Discard pending review" })
        map("n", "<leader>zrt", "<cmd>Octo review submit<CR>", { desc = "Review: Submit (approve/request/comment)" })
        map("n", "<leader>zrf", "<cmd>Octo review close<CR>", { desc = "Review: Close review view" })
        -- Navigating the diff while reviewing (file panel)
        map("n", "<leader>zr]", "<cmd>Octo review next_comment<CR>", { desc = "Review: Next comment" })
        map("n", "<leader>zr[", "<cmd>Octo review prev_comment<CR>", { desc = "Review: Prev comment" })

        -- ============================================================
        -- z a : Add (comments, review comments, suggestions, reactions)
        -- ============================================================
        map("n", "<leader>zac", "<cmd>Octo comment add<CR>", { desc = "Add: Comment" })
        map("n", "<leader>zax", "<cmd>Octo review comment<CR>", { desc = "Add: Review comment (inline, while reviewing)" })
        map("n", "<leader>zas", "<cmd>Octo review suggest<CR>", { desc = "Add: Suggested edit" })
        map("n", "<leader>zar", "<cmd>Octo reaction add<CR>", { desc = "Add: Reaction" })
        map("n", "<leader>zad", "<cmd>Octo comment delete<CR>", { desc = "Add: Delete comment (cursor)" })

        -- ============================================================
        -- z t : Threads (resolve conversation threads while reviewing)
        -- ============================================================
        map("n", "<leader>ztr", "<cmd>Octo thread resolve<CR>", { desc = "Thread: Resolve" })
        map("n", "<leader>ztu", "<cmd>Octo thread unresolve<CR>", { desc = "Thread: Unresolve" })

        -- ============================================================
        -- z m : Modify PR/issue metadata (labels, people, milestone, project)
        -- ============================================================
        map("n", "<leader>zml", "<cmd>Octo label add<CR>", { desc = "Modify: Add label" })
        map("n", "<leader>zmL", "<cmd>Octo label remove<CR>", { desc = "Modify: Remove label" })
        map("n", "<leader>zma", "<cmd>Octo assignee add<CR>", { desc = "Modify: Add assignee" })
        map("n", "<leader>zmA", "<cmd>Octo assignee remove<CR>", { desc = "Modify: Remove assignee" })
        map("n", "<leader>zmv", "<cmd>Octo reviewer add<CR>", { desc = "Modify: Add reviewer" })
        map("n", "<leader>zmm", "<cmd>Octo milestone add<CR>", { desc = "Modify: Set milestone" })
        map("n", "<leader>zmM", "<cmd>Octo milestone remove<CR>", { desc = "Modify: Remove milestone" })
        map("n", "<leader>zmt", "<cmd>Octo pr title<CR>", { desc = "Modify: Edit PR title" })

        -- ============================================================
        -- z d : Decisions (approve, request changes, merge, close)
        -- ============================================================
        map("n", "<leader>zdA", "<cmd>Octo review approve<CR>", { desc = "Decide: Approve" })
        map("n", "<leader>zdX", "<cmd>Octo review reject<CR>", { desc = "Decide: Request changes" })
        map("n", "<leader>zdM", "<cmd>Octo pr merge<CR>", { desc = "Decide: Merge" })
        map("n", "<leader>zdC", "<cmd>Octo pr close<CR>", { desc = "Decide: Close PR" })

        -- ============================================================
        -- z s : Search / notifications
        -- ============================================================
        map("n", "<leader>zs", "<cmd>Octo search<CR>", { desc = "Search: GitHub query" })
        map("n", "<leader>zn", "<cmd>Octo notification list<CR>", { desc = "Notifications: List" })
    end,
}
