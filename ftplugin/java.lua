if vim.g.vscode then
	return
end

local jdtls = require("jdtls")

-- Paths
local mason_path = vim.fn.stdpath("data") .. "/mason/packages"
local jdtls_path = mason_path .. "/jdtls"
local java_debug_path = mason_path .. "/java-debug-adapter"
local java_test_path = mason_path .. "/java-test"

local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

if launcher_jar == "" then
	vim.notify("jdtls not found. Please install it via Mason (:Mason)", vim.log.levels.ERROR)
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
local root_dir = vim.fs.root(0, root_markers)
if not root_dir then
	return
end

-- One workspace per project root, independent of the directory nvim was started in
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. vim.fs.basename(root_dir)
vim.fn.mkdir(workspace_dir, "p")

-- Debug and test bundles
local bundles = {}
if vim.fn.isdirectory(java_debug_path) == 1 then
	vim.list_extend(
		bundles,
		vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")
	)
end
if vim.fn.isdirectory(java_test_path) == 1 then
	vim.list_extend(
		bundles,
		vim.split(vim.fn.glob(java_test_path .. "/extension/server/com.microsoft.java.test.plugin-*.jar"), "\n")
	)
end

-- Lombok jar
local lombok_jar = vim.fn.expand(jdtls_path .. "/lombok.jar")

-- Build JVM arguments with Lombok agent positioned correctly
local jvm_args = {
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
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

-- The JDK that runs jdtls and builds the projects: $JAVA_HOME (SDKMAN points it
-- at its current JDK), else the one of `java` on PATH. jdtls needs Java 21+.
local java_home = vim.env.JAVA_HOME
if not java_home or java_home == "" then
	local java = vim.fn.exepath("java")
	java_home = java ~= "" and vim.fs.dirname(vim.fs.dirname(vim.uv.fs_realpath(java))) or nil
end
if not java_home then
	vim.notify("jdtls: no JDK found, set JAVA_HOME or put java on PATH", vim.log.levels.ERROR)
	return
end

-- Major version from the JDK's release file, e.g. JAVA_VERSION="21.0.2" -> 21
local java_version
for _, line in ipairs(vim.fn.readfile(java_home .. "/release")) do
	java_version = java_version or tonumber(line:match('^JAVA_VERSION="(%d+)'))
end
if java_version and java_version < 21 then
	vim.notify(("jdtls: needs Java 21 or newer, JAVA_HOME is Java %d"):format(java_version), vim.log.levels.ERROR)
	return
end

local config = {
	cmd = vim.list_extend({ java_home .. "/bin/java" }, jvm_args),

	root_dir = root_dir,

	settings = {
		java = {
			eclipse = { downloadSources = true },
			configuration = {
				updateBuildConfiguration = "automatic",
				-- Use your existing Java runtime configuration
				runtimes = java_version and {
					{
						name = "JavaSE-" .. java_version,
						path = java_home,
						default = true,
					},
				} or nil,
			},
			maven = {
				downloadSources = true,
				updateSnapshots = true, -- For AEM snapshots
			},
			debug = {
				settings = {
					hotCodeReplace = "never",
					forceBuildBeforeLaunch = false,
				},
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
				},
			},
			-- Enhanced completion for blink
			completion = {
				maxResults = 50,
				enabled = true,
				guessMethodArguments = "insertBestGuessedArguments",
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
				incompleteClasspath = { severity = "warning" },
			},
			contentProvider = { preferred = "fernflower" },
			autobuild = {
				enabled = true,
			},
		},
	},

	init_options = {
		bundles = bundles,
		extendedClientCapabilities = jdtls.extendedClientCapabilities,
	},

	capabilities = require("blink.cmp").get_lsp_capabilities(),

	handlers = {
		-- Map null warnings to errors
		["textDocument/publishDiagnostics"] = function(err, result, ctx)
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
			vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
		end,
	},
}

config.on_attach = function(_, bufnr)
	vim.lsp.codelens.enable(true, { bufnr = bufnr })

	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Java: " .. desc })
	end
	map("n", "<leader>jo", jdtls.organize_imports, "Organize imports")
	map("n", "<leader>jv", jdtls.extract_variable, "Extract variable")
	map("x", "<leader>jv", function()
		jdtls.extract_variable({ visual = true })
	end, "Extract variable")
	map("n", "<leader>jc", jdtls.extract_constant, "Extract constant")
	map("x", "<leader>jc", function()
		jdtls.extract_constant({ visual = true })
	end, "Extract constant")
	map("x", "<leader>jm", function()
		jdtls.extract_method({ visual = true })
	end, "Extract method")
	map("n", "<leader>jt", jdtls.test_nearest_method, "Test nearest method")
	map("n", "<leader>jT", jdtls.test_class, "Test class")
end

-- Add launcher jar and config
vim.list_extend(config.cmd, {
	"-jar",
	launcher_jar,
	"-configuration",
	platform_config,
	"-data",
	workspace_dir,
})

-- Run jdtls behind Outrigger (~/dev/projects/outrigger), a proxy that adds the
-- null analysis jdtls lacks. Falls back to plain jdtls when it is not built.
local outrigger_jar = vim.fn.expand("~/dev/projects/outrigger/target/outrigger.jar")
if vim.fn.filereadable(outrigger_jar) == 1 then
	config.cmd = vim.list_extend({ java_home .. "/bin/java", "-jar", outrigger_jar, "--" }, config.cmd)
end

-- Start jdtls
jdtls.start_or_attach(config)
