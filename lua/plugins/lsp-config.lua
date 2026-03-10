return { -- LSP Configuration & Plugins
	cond = not vim.g.vscode,
	"neovim/nvim-lspconfig",
	dependencies = {
		-- Automatically install LSPs and related tools to stdpath for Neovim
		{ "mason-org/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- Useful status updates for LSP.
		-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
		{ "j-hui/fidget.nvim", opts = {} },

		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					-- Load luvit types when the `vim.uv` word is found
					{ path = "luvit-meta/library", words = { "vim%.uv" } },
				},
			},
		},
		{ "Bilal2453/luvit-meta", lazy = true },
		{
			"mfussenegger/nvim-jdtls",
			ft = "java",
		},
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				-- NOTE: Remember that Lua is a real programming language, and as such it is possible
				-- to define small helper and utility functions so you don't have to repeat yourself.
				--
				-- In this case, we create a function that lets us more easily define mappings specific
				-- for LSP related items. It sets the mode, buffer and description for us each time.
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end

				-- Jump to the definition of the word under your cursor.
				--  This is where a variable was first declared, or where a function is defined, etc.
				--  To jump back, press <C-t>.
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

				-- Find references for the word under your cursor.
				map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

				-- Jump to the implementation of the word under your cursor.
				--  Useful when your language has ways of declaring types without an actual implementation.
				map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

				-- Jump to the type of the word under your cursor.
				--  Useful when you're not sure what type a variable is and you want to see
				--  the definition of its *type*, not where it was *defined*.
				map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

				-- Fuzzy find all the symbols in your current document.
				--  Symbols are things like variables, functions, types, etc.
				map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

				-- Fuzzy find all the symbols in your current workspace.
				--  Similar to document symbols, except searches over your entire project.
				map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

				-- Rename the variable under your cursor.
				--  Most Language Servers support renaming across files, etc.
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

				-- Execute a code action, usually your cursor needs to be on top of an error
				-- or a suggestion from your LSP for this to activate.
				map("<leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<cr>", "[C]ode [A]ction")
				vim.keymap.set("v", "<leader>ca", function()
					vim.lsp.buf.code_action()
				end, { buffer = event.buf, desc = "[C]ode [A]ction" })

				-- WARN: This is not Goto Definition, this is Goto Declaration.
				--  For example, in C this would take you to the header.
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				map("<leader>e", vim.diagnostic.open_float, "Open [E]rror message in floating window")

				-- The following two autocommands are used to highlight references of the
				-- word under your cursor when your cursor rests there for a little while.
				--    See `:help CursorHold` for information about when this is executed
				--
				-- When you move your cursor, the highlights will be cleared (the second autocommand).
				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and client.supports_method(
						client,
						vim.lsp.protocol.Methods.textDocument_documentHighlight,
						event.buf
					)
				then
					local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})

					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
						end,
					})
				end

				-- The following code creates a keymap to toggle inlay hints in your
				-- code, if the language server you are using supports them
				--
				-- This may be unwanted, since they displace some of your code

				if client and client.supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint) then
					map("<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
					end, "[T]oggle Inlay [H]ints")
				end
			end,
		})

		-- LSP servers and clients are able to communicate to each other what features they support.
		--  By default, Neovim doesn't support everything that is in the LSP specification.
		--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
		--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
		local orig_capabilities = vim.lsp.protocol.make_client_capabilities()
		local capabilities = require("blink.cmp").get_lsp_capabilities(orig_capabilities)
		-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		-- Enable the following language servers
		--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
		--
		--  Add any additional override configuration in the following tables. Available keys are:
		--  - cmd (table): Override the default command used to start the server
		--  - filetypes (table): Override the default list of associated filetypes for the server
		--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
		--  - settings (table): Override the default settings passed when initializing the server.
		--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
		local servers = {
			lua_ls = {
				-- cmd = {...},
				-- filetypes = { ...},
				-- capabilities = {},
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
						-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
						-- diagnostics = { disable = { 'missing-fields' } },
					},
				},
			},
			ts_ls = {
				on_attach = function(client, _)
					-- Disable `tsserver`'s formatting capability
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false
				end,
				settings = {
					javascript = {
						format = {
							enable = false,
						},
					},
					typescript = {
						format = {
							enable = false,
						},
					},
				},
			},
		}


		-- Ensure the servers and tools above are installed
		--  To check the current status of installed tools and/or manually install
		--  other tools, you can run
		--    :Mason
		--
		--  You can press `g?` for help in this menu.
		require("mason").setup()

		-- You can add other tools here that you want Mason to install
		-- for you, so that they are available from within Neovim.
		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, { "prettierd", "jdtls", "java-debug-adapter", "java-test" })
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			ensure_installed = {},
			automatic_installation = false,
			automatic_enable = false,
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					-- This handles overriding only values explicitly passed
					-- by the server configuration above. Useful when disabling
					-- certain features of an LSP (for example, turning off formatting for tsserver)
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					vim.lsp.config(server_name, server);
					vim.lsp.enable(server_name)
				end,
				jdtls = function()
					-- Setup jdtls via autocmd to ensure proper initialization
					vim.api.nvim_create_autocmd("FileType", {
						pattern = "java",
						callback = function()
							local jdtls = require("jdtls")

							-- Paths
							local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
							local jdtls_path = mason_path .. "/jdtls"
							local java_debug_path = mason_path .. "/java-debug-adapter"
							local java_test_path = mason_path .. "/java-test"

							local launcher_jar =
								vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

							if launcher_jar == "" then
								vim.notify(
									"jdtls not found. Please install it via Mason (:Mason)",
									vim.log.levels.ERROR
								)
								return
							end

							local platform_config = jdtls_path .. "/config_linux" -- Adjust for your OS

							-- AEM-aware root detection
							local root_markers = {
								"gradlew",
								"mvnw",
								".git",
								-- "pom.xml",
								"build.gradle",
								"build.gradle.kts",
								"jpm.toml",
							}
							local root_dir = require("jdtls.setup").find_root(root_markers)
							if not root_dir then
								return
							end

							local function setup_workspace()
								local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
								local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

								-- Remove existing workspace
								-- vim.fn.system("rm -rf " .. workspace_dir)

								-- Create fresh workspace directory
								vim.fn.mkdir(workspace_dir, "p")

								return workspace_dir
							end
							local workspace_dir = setup_workspace()

							-- Debug and test bundles
							local bundles = {}
							if vim.fn.isdirectory(java_debug_path) == 1 then
								vim.list_extend(
									bundles,
									vim.split(
										vim.fn.glob(
											java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"
										),
										"\n"
									)
								)
							end
							if vim.fn.isdirectory(java_test_path) == 1 then
								vim.list_extend(
									bundles,
									vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n")
								)
							end

							-- Lombok jar
							local lombok_jar = vim.fn.expand(jdtls_path .. "/lombok.jar")

							-- Build JVM arguments with Lombok agent positioned correctly
							local jvm_args = {
								"-Declipse.application=org.eclipse.jdt.ls.core.id1",
								"-Dosgi.bundles.defaultStartLevel=4",
								"-Declipse.product=org.eclipse.jdt.ls.core.product",
								"-Dlog.protocol=true",
								"-Dlog.level=ALL",
								"-Xms1g",
								"-Xmx2g",
								"--add-modules=ALL-SYSTEM",
								"--add-opens",
								"java.base/java.util=ALL-UNNAMED",
								"--add-opens",
								"java.base/java.lang=ALL-UNNAMED",
							}

							-- Add Lombok agent BEFORE other jar arguments
							if vim.fn.filereadable(lombok_jar) == 1 then
								table.insert(jvm_args, "-javaagent:" .. lombok_jar)
							end

							local config = {
								cmd = vim.list_extend({
									"/usr/lib/jvm/java-1.21.0-openjdk-amd64/bin/java",
								}, jvm_args),

								root_dir = root_dir,

								settings = {
									java = {
										eclipse = { downloadSources = true },
										configuration = {
											updateBuildConfiguration = "automatic",
											-- Use your existing Java runtime configuration
											runtimes = {
												{
													name = "JavaSE-21",
													path = "/usr/lib/jvm/java-1.21.0-openjdk-amd64",
													default = true,
												},
											},
										},
										maven = {
											downloadSources = true,
											updateSnapshots = true, -- For AEM snapshots
										},
										implementationsCodeLens = { enabled = true },
										referencesCodeLens = { enabled = true },
										references = { includeDecompiledSources = true },
										format = { enabled = true },
										compile = {
											nullAnalysis = {
												mode = "automatic",
												-- More aggressive null analysis
												nonnull = {
													"org.jetbrains.annotations.NotNull",
													"javax.annotation.Nonnull",
													"org.springframework.lang.NonNull",
													"lombok.NonNull",
												},
												nullable = {
													"org.jetbrains.annotations.Nullable",
													"javax.annotation.Nullable",
													"org.springframework.lang.Nullable",
												},
												-- Enable secondary null analysis
												secondary = {
													enabled = true,
												},
											},
										},
										-- Enhanced completion for blink
										completion = {
											maxResults = 50,
											enabled = true,
											guessMethodArguments = true,
										},
										signatureHelp = {
											enabled = true,
											description = { enabled = true },
										},
										-- AEM-specific settings
										sources = {
											organizeImports = {
												starThreshold = 99,
												staticStarThreshold = 99,
											},
										},
										errors = {
											incompleteClasspath = "warning",
											-- Show null analysis problems as errors
											nullAnalysis = "error",
										},
										autobuild = {
											enabled = true,
										},
									},
									signatureHelp = { enabled = true },
									contentProvider = { preferred = "fernflower" },
									extendedClientCapabilities = jdtls.extendedClientCapabilities,
								},

								init_options = {
									bundles = bundles,
									extendedClientCapabilities = jdtls.extendedClientCapabilities,
								},

								capabilities = capabilities,

								-- Use your existing progress handler
								handlers = {
									["$/progress"] = function(_, result, ctx) end,
									-- Map null warnings to errors
									["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
										if result and result.diagnostics then
											result.diagnostics = vim.tbl_filter(function(diagnostic)
												if diagnostic.code == "536871895" then
													return false
												end

												return true -- Keep this diagnostic
											end, result.diagnostics)
											for _, diagnostic in ipairs(result.diagnostics) do
												if diagnostic.code == "536871364" then
													diagnostic.severity = vim.diagnostic.severity.ERROR
												end
											end
										end
										vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
									end,
								},
							}

							-- Add launcher jar and config
							vim.list_extend(config.cmd, {
								"-jar",
								launcher_jar,
								"-configuration",
								platform_config,
								"-data",
								workspace_dir,
							})

							-- Start jdtls
							jdtls.start_or_attach(config)
						end,
						group = vim.api.nvim_create_augroup("jdtls_setup", { clear = true }),
					})
				end,
			},
		})
	end,
}
