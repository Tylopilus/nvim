return {
    "luukvbaal/statuscol.nvim",
    config = function()
        local builtin = require("statuscol.builtin")
        require("statuscol").setup({
            -- configuration goes here, for example:
            relculright = true,
            segments = {
                {
                    sign = { name = { "Diagnostic" }, maxwidth = 1, auto = true },
                    click = "v:lua.ScSa",
                },
                {
                    text = {builtin.foldfunc},
                    click = "v:lua.ScFa"
                },
                { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                -- { text = { "%s" }, click = "v:lua.ScSa" },
                -- { text = { "%C" }, click = "v:lua.ScFa" },
                {
                    sign = {
                        text = { ".*" },
                        -- maxwidth = 2,
                        -- colwidth = 1,
                        -- auto = true,
                        -- wrap = true,
                    },
                    click = "v:lua.ScSa",
                },
            },
        })
    end,
}
