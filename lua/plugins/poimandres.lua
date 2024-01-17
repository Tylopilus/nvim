return {
    "olivercederborg/poimandres.nvim",
    cond = not vim.g.vscode,
    lazy = false,
    priority = 1000,

    config = function()
        vim.cmd.colorscheme("poimandres")
    end,
}
