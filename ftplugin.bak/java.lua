if not vim.g.vscode then
  local registry = require("mason-registry")
  local home = os.getenv("HOME")
  local workspace_path = home .. "/.local/share/nvim/jdtls-workspace/"
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = workspace_path .. project_name

  local get_lombok_javaagent = function()
    local lombok_dir = home .. '/.m2/repository/org/projectlombok/lombok/'
    local lombok_versions = io.popen('ls -1 "' .. lombok_dir .. '" | sort -r')
    if lombok_versions ~= nil then
      local lb_i, lb_versions = 0, {}
      for lb_version in lombok_versions:lines() do
        lb_i = lb_i + 1
        lb_versions[lb_i] = lb_version
      end
      lombok_versions:close()
      if next(lb_versions) ~= nil then
        local version_dir = string.format('%s%s/', lombok_dir, lb_versions[1])
        local grep_command = string.format('ls -1 "%s" | grep -E "^lombok-[0-9]+\\.[0-9]+\\.[0-9]+\\.jar$"', version_dir)
        local lombok_jar = io.popen(grep_command):read("*l")
        if lombok_jar then
          local full_path = version_dir .. lombok_jar
          return full_path
        end
      end
    end
    return ''
  end
  local status, jdtls = pcall(require, "jdtls")
  if not status then
    return
  end
  local extendedClientCapabilities = jdtls.extendedClientCapabilities

  local jdtls_install = registry.get_package("jdtls"):get_install_path()
  local config = {
    cmd = {
      "java",
      "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4",
      "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true",
      "-Dlog.level=ALL",
      "-Xmx1g",
      "--add-modules=ALL-SYSTEM",
      "--add-opens",
      "java.base/java.util=ALL-UNNAMED",
      "--add-opens",
      "java.base/java.lang=ALL-UNNAMED",
      "-javaagent:" .. get_lombok_javaagent(),
      "-jar",
      vim.trim(vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar")),
      "-configuration",
      jdtls_install .. "/config_mac",
      "-data",
      workspace_dir,
    },
    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),

    settings = {
      java = {
        signatureHelp = { enabled = true },
        extendedClientCapabilities = extendedClientCapabilities,
        maven = {
          downloadSources = true,
        },
        referencesCodeLens = {
          enabled = true,
        },
        references = {
          includeDecompiledSources = true,
        },
        inlayHints = {
          parameterNames = {
            enabled = "all", -- literals, all, none
          },
        },
        format = {
          enabled = false,
        },
      },
    },

    init_options = {
      bundles = {},
    },
  }
  require("jdtls").start_or_attach(config)
end
