return {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    opts = {
        vim.diagnostic.config({ virtual_lines = { only_current_line = true } });
    }
}
