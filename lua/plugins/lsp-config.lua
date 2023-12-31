return {
    {
        "williamboman/mason.nvim",
        lazy = false,
        -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
        opts = {},
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            local on_attach = function(_, bufnr)
                -- NOTE: Remember that lua is a real programming language, and as such it is possible
                -- to define small helper and utility functions so you don't have to repeat yourself
                -- many times.
                --
                -- In this case, we create a function that lets us more easily define mappings specific
                -- for LSP related items. It sets the mode, buffer and description for us each time.
                local nmap = function(keys, func, desc)
                    if desc then
                        desc = "LSP: " .. desc
                    end

                    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
                end

                nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
                nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

                nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
                nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
                nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                -- See `:help K` for why this keymap
                nmap("K", vim.lsp.buf.hover, "Hover Documentation")

                nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
                nmap("<leader>e", vim.diagnostic.open_float, "Open [E]rror message in floating window")
            end

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
            }

            local servers = {
                lua_ls = {},
                tsserver = {},
                svelte = {},
                jsonls = {},
                tailwindcss = {},
                emmet_language_server = {},
                html = {},
            }

            local handlers = {
                -- The first entry (without a key) will be the default handler
                -- and will be called for each installed server that doesn't have
                -- a dedicated handler.
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup({
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name],
                        filetypes = (servers[server_name] or {}).filetypes,
                    })
                end,
                -- Next, you can provide targeted overrides for specific servers.
                ["cssls"] = function()
                    require("lspconfig").cssls.setup({
                        capabilities = capabilities,
                        settings = {
                            scss = {
                                lint = {
                                    idSelector = "warning",
                                    zeroUnits = "warning",
                                    duplicateProperties = "warning",
                                },
                                completion = {
                                    completePropertyWithSemicolon = true,
                                    triggerPropertyValueCompletion = true,
                                },
                            },
                        },
                        on_attach = function(client)
                            client.server_capabilities.document_formatting = false
                        end,
                    })
                end,
                ["tsserver"] = function()
                    require("lspconfig").tsserver.setup({
                        capabilities = capabilities,
                        on_attach = function(client)
                            client.server_capabilities.document_formatting = false
                        end,
                    })
                end,
                ["html"] = function()
                    require("lspconfig").html.setup({
                        capabilities = capabilities,
                        on_attach = function(client)
                            client.server_capabilities.document_formatting = false
                        end,
                    })
                end,
            }

            local mason_lspconfig = require("mason-lspconfig")
            mason_lspconfig.setup({ ensure_installed = vim.tbl_keys(servers) })
            mason_lspconfig.setup_handlers(handlers)
        end,
    },
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            --            local lspconfig = require("lspconfig")
            --            lspconfig.tsserver.setup({})
            --            lspconfig.lua_ls.setup({})
            --            lspconfig.svelte.setup({})
            --            lspconfig.tailwindcss.setup({})
            --            lspconfig.jsonls.setup({})
            --
            --            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            --            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            --            vim.keymap.set('n', 'gr', vim.lsp.buf.references, {})
            --            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
        end,
    },
}
