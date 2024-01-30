return {
    "nvim-lualine/lualine.nvim",
    cond = not vim.g.vscode,
    config = function()
        require("lualine").setup({
            options = {
                -- theme = "poimandres",
                theme = "github_dark",
            },
        })
    end,
}
