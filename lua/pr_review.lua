local M = {}

M.default_base = "origin/develop"

local function run(command, args)
	return vim.fn.systemlist(vim.list_extend({ command }, args))
end

local function git(args)
	return run("git", args)
end

local function az(args)
	return run("az", args)
end

local function ref_sha(ref)
	local output = git({ "rev-parse", "--verify", ref .. "^{commit}" })
	if vim.v.shell_error ~= 0 then
		return nil
	end

	return output[1]
end

local function git_ok(args)
	git(args)
	return vim.v.shell_error == 0
end

local function ensure_ref(ref)
	if ref_sha(ref) then
		return true
	end

	local remote, branch = ref:match("^([^/]+)/(.+)$")
	if remote and branch and git_ok({ "remote", "get-url", remote }) then
		local target = "refs/remotes/" .. remote .. "/" .. branch
		git({ "fetch", remote, branch .. ":" .. target })
		if vim.v.shell_error == 0 and ref_sha(ref) then
			return true
		end
	end

	vim.notify("PRReview: git ref not found: " .. ref, vim.log.levels.ERROR)
	return false
end

local function diff_ref(base_ref, head_ref)
	if head_ref then
		return base_ref .. "..." .. head_ref
	end

	return base_ref
end

local function is_current_head(ref)
	local head_sha = ref_sha("HEAD")
	local review_sha = ref_sha(ref)
	return head_sha and review_sha and head_sha == review_sha
end

local function working_tree_clean()
	local output = git({ "status", "--porcelain" })
	if vim.v.shell_error ~= 0 then
		vim.notify("PRReview: could not inspect git status", vim.log.levels.ERROR)
		return false
	end

	if #output > 0 then
		vim.notify("PRReview: working tree is dirty; commit or stash changes before switching PRs", vim.log.levels.WARN)
		return false
	end

	return true
end

local function checkout_detached(head_ref)
	if is_current_head(head_ref) then
		return true
	end

	if not working_tree_clean() then
		return false
	end

	local output = git({ "switch", "--detach", head_ref })
	if vim.v.shell_error ~= 0 then
		output = git({ "checkout", "--detach", head_ref })
	end

	if vim.v.shell_error ~= 0 then
		vim.notify("PRReview: detached checkout failed: " .. table.concat(output, "\n"), vim.log.levels.ERROR)
		return false
	end

	return true
end

local function build_qf_list(files)
	local qf_list = {}

	for _, line in ipairs(files) do
		local fields = vim.split(line, "\t")
		local status = fields[1]
		local filename = fields[#fields]
		local text = "Changed in PR"

		if status and status:sub(1, 1) == "R" and fields[2] and fields[3] then
			text = "Renamed in PR: " .. fields[2] .. " -> " .. fields[3]
		elseif status == "A" then
			text = "Added in PR"
		elseif status == "D" then
			text = "Deleted in PR"
		elseif status == "M" then
			text = "Modified in PR"
		end

		if filename and filename ~= "" then
			table.insert(qf_list, { filename = filename, lnum = 1, text = text })
		end
	end

	return qf_list
end

local function base_branch_name(base_ref)
	if not base_ref:match("^[%w._/-]+$") then
		return nil
	end

	return base_ref:match("^[^/]+/(.+)$") or base_ref
end

local function branch_from_ref_name(ref_name)
	if not ref_name or ref_name == "" then
		return nil
	end

	return ref_name:gsub("^refs/heads/", "")
end

local function json_decode(lines)
	local text = table.concat(lines, "\n")
	if vim.json and vim.json.decode then
		return vim.json.decode(text)
	end

	return vim.fn.json_decode(text)
end

local function change_gitsigns_base(base_ref)
	local ok, gitsigns = pcall(require, "gitsigns")
	if not ok then
		vim.notify("PRReview: gitsigns.nvim is not available", vim.log.levels.WARN)
		return
	end

	gitsigns.change_base(base_ref, true)
end

function M.start(head_ref, base_ref)
	base_ref = base_ref or M.default_base
	head_ref = head_ref ~= "" and head_ref or nil

	if not ensure_ref(base_ref) then
		return
	end

	if head_ref then
		if not ensure_ref(head_ref) then
			return
		end

		if not checkout_detached(head_ref) then
			return
		end
	end

	local review_ref = diff_ref(base_ref, head_ref)
	local files = git({ "diff", "--name-status", "--find-renames", review_ref })
	if vim.v.shell_error ~= 0 then
		vim.notify("PRReview: git diff failed for " .. review_ref, vim.log.levels.ERROR)
		return
	end

	local qf_list = build_qf_list(files)
	vim.fn.setqflist(qf_list, "r")
	if #qf_list > 0 then
		vim.cmd("copen")
	else
		vim.cmd("cclose")
	end

	change_gitsigns_base(base_ref)

	print("PR review mode: " .. review_ref)
end

function M.complete(arg_lead)
	local refs = git({ "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes" })
	if vim.v.shell_error ~= 0 then
		return {}
	end

	return vim.tbl_filter(function(ref)
		return ref:find(arg_lead, 1, true) == 1 and ref ~= "origin/HEAD"
	end, refs)
end

function M.diffstat(base_ref, head_ref)
	return git({ "diff", "--stat", "--find-renames", diff_ref(base_ref or M.default_base, head_ref) })
end

function M.active_prs(opts)
	opts = opts or {}

	if vim.fn.executable("az") ~= 1 then
		vim.notify("PRReview: Azure CLI is not installed or not on PATH", vim.log.levels.ERROR)
		return {}
	end

	local base_ref = opts.base_ref or M.default_base
	local base_branch = base_branch_name(base_ref)
	local cmd = {
		"repos",
		"pr",
		"list",
		"--status",
		"active",
		"--detect",
		"true",
		"--output",
		"json",
		"--only-show-errors",
		"--top",
		tostring(opts.limit or 100),
	}

	if base_branch then
		table.insert(cmd, "--target-branch")
		table.insert(cmd, base_branch)
	end

	local output = az(cmd)
	if vim.v.shell_error ~= 0 then
		local detail = output[1] and (": " .. output[1]) or ""
		if detail:find("'repos' is misspelled", 1, true) then
			detail = detail .. " (install the Azure DevOps extension: az extension add --name azure-devops)"
		end
		vim.notify("PRReview: az repos pr list failed" .. detail, vim.log.levels.ERROR)
		return {}
	end

	local ok, prs = pcall(json_decode, output)
	if not ok then
		vim.notify("PRReview: could not parse Azure DevOps PR list output", vim.log.levels.ERROR)
		return {}
	end

	local remote = opts.remote or "origin"
	local entries = {}
	for _, pr in ipairs(prs or {}) do
		local branch = branch_from_ref_name(pr.sourceRefName)
		if branch then
			table.insert(entries, {
				ref = remote .. "/" .. branch,
				branch = branch,
				number = pr.pullRequestId,
				title = pr.title or "",
				is_draft = pr.isDraft,
				author = pr.createdBy and pr.createdBy.displayName or "",
				target = branch_from_ref_name(pr.targetRefName) or "",
				url = pr.url or "",
			})
		end
	end

	return entries
end

function M.pick(opts)
	opts = opts or {}

	local has_telescope, pickers = pcall(require, "telescope.pickers")
	if not has_telescope then
		vim.notify("PRReview: telescope.nvim is not available", vim.log.levels.ERROR)
		return
	end

	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")
	local base_ref = opts.base_ref or M.default_base

	if not ensure_ref(base_ref) then
		return
	end

	local prs = M.active_prs({
		base_ref = base_ref,
		remote = opts.remote or "origin",
		limit = opts.limit,
	})
	if #prs == 0 then
		vim.notify("PRReview: no active Azure DevOps PRs found for " .. base_ref, vim.log.levels.WARN)
		return
	end

	pickers
		.new(opts, {
			prompt_title = "PR Review (" .. base_ref .. ")",
			finder = finders.new_table({
				results = prs,
				entry_maker = function(entry)
					local number = tostring(entry.number or "?")
					local prefix = "#" .. number
					if entry.is_draft then
						prefix = prefix .. " draft"
					end

					return {
						value = entry.ref,
						display = prefix .. "  " .. entry.branch .. "  " .. entry.title,
						ordinal = number .. " " .. entry.branch .. " " .. entry.title,
						pr = entry,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			previewer = previewers.new_buffer_previewer({
				title = "Diffstat",
				define_preview = function(self, entry)
					local ref_ready = ensure_ref(entry.value)
					local lines = ref_ready and M.diffstat(base_ref, entry.value) or {}
					if vim.v.shell_error ~= 0 then
						lines = { "git diff failed for " .. diff_ref(base_ref, entry.value) }
					end

					if #lines == 0 then
						lines = { "No changes against " .. base_ref }
					elseif entry.pr then
						table.insert(lines, 1, "")
						if entry.pr.author ~= "" then
							table.insert(lines, 1, "Author: " .. entry.pr.author)
						end
						table.insert(lines, 1, "#" .. entry.pr.number .. " " .. entry.pr.title)
					end

					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
					vim.bo[self.state.bufnr].filetype = "diff"
				end,
			}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					if selection then
						M.start(selection.value, base_ref)
					end
				end)

				return true
			end,
		})
		:find()
end

return M
