return {
    'serenevoid/kiwi.nvim',
    opts = {
        {
            name = "work",
            path = "/home/helge/dev/notes/"
        },
    },
    keys = {
        { "<leader>ww", ":lua require(\"kiwi\").open_wiki_index()<cr>", desc = "Open Wiki index" },
        { "T", ":lua require(\"kiwi\").todo.toggle()<cr>", desc = "Toggle Markdown Task" }
    },
    lazy = true
}
