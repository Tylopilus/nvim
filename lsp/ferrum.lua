return {
	cmd = {
		"java",
		"-jar",
		vim.fn.expand("~/dev/projects/ferrum/ferrum/compiler/target/ferrum-compiler-0.1.0-SNAPSHOT.jar"),
		"--lsp",
	},
	filetypes = { "ferrum" },
	root_markers = { ".git", "pom.xml" },
}
