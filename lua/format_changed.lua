-- Format only the lines that changed since the last commit, so reviews show
-- no formatting noise in code that was not touched.
--
-- Java is formatted by prettier with the lineRanges option of the
-- prettier-plugin-java fork (github.com/Tylopilus/prettier-java). Other
-- formatters cannot format a range, so the whole file is formatted in memory
-- and only the formatting edits that touch changed lines are applied.
local M = {}

---@alias LineRange {[1]: integer, [2]: integer} 1-based, inclusive

---@param text string
---@return string[]
local function split_lines(text)
	local lines = vim.split(text, "\n", { plain = true })
	if lines[#lines] == "" then
		table.remove(lines)
	end
	return lines
end

---@param lines string[]
local function join_lines(lines)
	return table.concat(lines, "\n") .. "\n"
end

--- Lines of the buffer that differ from the file in HEAD, or nil when the
--- file is not tracked by git (then every line is new).
---@return LineRange[]|nil
local function changed_ranges(bufnr, lines)
	local path = vim.api.nvim_buf_get_name(bufnr)
	local head = vim.system(
		{ "git", "-C", vim.fs.dirname(path), "show", "HEAD:./" .. vim.fs.basename(path) },
		{ text = true }
	)
		:wait()
	if head.code ~= 0 then
		return nil
	end

	local ranges = {}
	local old = head.stdout:gsub("\r\n", "\n")
	for _, hunk in ipairs(vim.text.diff(old, join_lines(lines), { result_type = "indices" })) do
		local start, count = hunk[3], hunk[4]
		if count > 0 then
			table.insert(ranges, { start, start + count - 1 })
		else
			-- deleted lines: the lines around the gap may need formatting
			table.insert(ranges, { math.max(start, 1), start + 1 })
		end
	end
	return ranges
end

---@param first integer
---@param last integer
---@param ranges LineRange[]
local function touches(first, last, ranges)
	for _, range in ipairs(ranges) do
		if first <= range[2] and last >= range[1] then
			return true
		end
	end
	return false
end

--- The edit blocks turning `from` into `to`: {start_a, count_a, start_b, count_b}.
--- Consecutive changed lines stay in one block; applying only part of a block
--- could break the code.
local function edit_blocks(from, to, algorithm)
	return vim.text.diff(join_lines(from), join_lines(to), { result_type = "indices", algorithm = algorithm })
end

--- Diff algorithms to try: they line up the original and the formatted text
--- differently, and a misaligned diff can pair unrelated lines.
local ALGORITHMS = { "histogram", "patience", "myers", "minimal" }

--- `original` with only the formatting blocks applied that touch `ranges`.
---@return string[]
local function merge_within(original, formatted, ranges, algorithm)
	local result = vim.deepcopy(original)
	local blocks = edit_blocks(original, formatted, algorithm)
	-- bottom-up, so earlier line numbers stay valid
	for i = #blocks, 1, -1 do
		local start_a, count_a, start_b, count_b = unpack(blocks[i])
		-- a pure insertion (count_a == 0) goes after line start_a
		local first, last = start_a, count_a == 0 and start_a + 1 or start_a + count_a - 1
		if touches(first, last, ranges) then
			local from = count_a == 0 and start_a or start_a - 1
			for _ = 1, count_a do
				table.remove(result, from + 1)
			end
			for j = count_b, 1, -1 do
				table.insert(result, from + 1, formatted[start_b + j - 1])
			end
		end
	end
	return result
end

--- Replaces the buffer's lines with `lines`, changing only what differs, as one undo step.
local function apply(bufnr, original, lines)
	local blocks = edit_blocks(original, lines)
	for i = #blocks, 1, -1 do
		local start_a, count_a, start_b, count_b = unpack(blocks[i])
		local from = count_a == 0 and start_a or start_a - 1
		if i < #blocks then
			pcall(vim.cmd.undojoin)
		end
		vim.api.nvim_buf_set_lines(
			bufnr,
			from,
			from + count_a,
			false,
			vim.list_slice(lines, start_b, start_b + count_b - 1)
		)
	end
end

local line_ranges_supported

--- Whether the prettier on PATH, with the config for this buffer's file, has
--- the lineRanges option of the prettier-plugin-java fork. Without it prettier
--- would ignore the option and format the whole file. Checked once per session.
local function prettier_supports_line_ranges(bufnr)
	if line_ranges_supported == nil then
		local script = [[
			const { execFileSync } = require("node:child_process");
			const { realpathSync } = require("node:fs");
			const path = require("node:path");
			(async () => {
				const bin = execFileSync("sh", ["-c", "command -v prettier"], { encoding: "utf8" }).trim();
				const prettier = await import(path.resolve(path.dirname(realpathSync(bin)), "..", "index.mjs"));
				const config = (await prettier.resolveConfig(process.argv[1])) ?? {};
				const { options } = await prettier.getSupportInfo({ plugins: config.plugins ?? [] });
				process.exit(options.some((option) => option.name === "lineRanges") ? 0 : 1);
			})().catch(() => process.exit(1));
		]]
		local result = vim.system({ "node", "-e", script, vim.api.nvim_buf_get_name(bufnr) }):wait()
		line_ranges_supported = result.code == 0
	end
	return line_ranges_supported
end

--- Formats the given line ranges of the buffer, or the lines changed since
--- HEAD when no ranges are given.
---@param opts? {bufnr?: integer, ranges?: LineRange[]}
function M.format(opts)
	opts = opts or {}
	local conform = require("conform")
	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	local original = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	local ranges = opts.ranges or changed_ranges(bufnr, original)
	if not ranges then
		conform.format({ bufnr = bufnr, async = true })
		return
	end
	if #ranges == 0 then
		vim.notify("No changes since HEAD to format", vim.log.levels.INFO)
		return
	end

	local formatters = vim.tbl_map(function(f)
		return f.name
	end, conform.list_formatters_to_run(bufnr))

	if
		vim.bo[bufnr].filetype == "java"
		and vim.deep_equal(formatters, { "prettier" })
		and prettier_supports_line_ranges(bufnr)
	then
		-- prettier formats exactly these lines itself (see append_args in plugins/conform.lua)
		vim.b[bufnr].prettier_line_ranges = table.concat(
			vim.tbl_map(function(range)
				return range[1] .. "-" .. range[2]
			end, ranges),
			","
		)
		conform.format({ bufnr = bufnr, async = true }, function()
			vim.b[bufnr].prettier_line_ranges = nil
		end)
		return
	end
	if #formatters == 0 then
		-- LSP formatting supports ranges itself
		for i = #ranges, 1, -1 do
			local last_line = vim.api.nvim_buf_get_lines(bufnr, ranges[i][2] - 1, ranges[i][2], false)[1] or ""
			conform.format({
				bufnr = bufnr,
				range = { start = { ranges[i][1], 0 }, ["end"] = { ranges[i][2], #last_line } },
			})
		end
		return
	end

	-- format_lines is marked private in conform; it formats text without touching the buffer
	local function format_text(lines, callback)
		conform.format_lines(formatters, lines, { bufnr = bufnr, async = true, timeout_ms = 10000 }, function(err, out)
			vim.schedule(function()
				callback(err, out)
			end)
		end)
	end

	local tick = vim.api.nvim_buf_get_changedtick(bufnr)
	format_text(original, function(err, formatted)
		if err or not formatted then
			vim.notify("Format failed: " .. (err and err.message or "no output"), vim.log.levels.ERROR)
			return
		end

		-- A correct partial format differs from the original only in formatting,
		-- so formatting it fully gives the same text as formatting the original.
		-- This rejects misaligned merges, e.g. a method that ends up duplicated.
		local function try(i)
			if i > #ALGORITHMS then
				vim.notify(
					"Can't format only the changed lines here; use <leader>F to format the whole file",
					vim.log.levels.WARN
				)
				return
			end
			local merged = merge_within(original, formatted, ranges, ALGORITHMS[i])
			if vim.deep_equal(merged, original) then
				return
			end
			format_text(merged, function(check_err, reformatted)
				if check_err or not vim.deep_equal(reformatted, formatted) then
					return try(i + 1)
				end
				if vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then
					vim.notify("Buffer changed while formatting, not applied", vim.log.levels.WARN)
					return
				end
				apply(bufnr, original, merged)
			end)
		end
		try(1)
	end)
end

return M
