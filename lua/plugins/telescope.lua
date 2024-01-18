return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    cond = not vim.g.vscode,
    config = function()
        require("telescope").setup({
            defaults = {
                layout_config = {
                    width = 0.7,
                    horizontal = {
                        preview_width = 0.6,
                    },
                },
            },
            pickers = {
                buffers = {
                    ignore_current_buffer = true,
                    sort_mru = true,
                },
            },
        })
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<C-p>", builtin.find_files, {})
        vim.keymap.set("n", "<leader>/", builtin.live_grep, {})
        vim.keymap.set("n", "?", builtin.live_grep, {})
        vim.keymap.set("n", "<leader><space>", builtin.buffers, { desc = "[ ] Find existing buffers" })
    end,
}
