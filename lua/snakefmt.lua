local M = {}

local function run(cmd, args, input)
	local result = vim.system({ cmd, unpack(args or {}) }, { stdin = input, text = true }):wait()
	return result.stdout, result.stderr, result.code
end

local function snakefmt_available()
	local _, _, code = run("snakefmt", { "--version" })
	return code == 0
end
function M.format()
	if not snakefmt_available() then
		vim.notify("snakefmt not found. Is snakefmt installed?", vim.log.levels.ERROR)
		return
	end

	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local text = table.concat(lines, "\n") .. "\n"

	-- Save cursor positions
	local cursors = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			cursors[win] = vim.api.nvim_win_get_cursor(win)
		end
	end

	local start = vim.loop.hrtime()
	local stdout, stderr, code = run("snakefmt", {}, text)

	-- ❗ If snakefmt failed, do NOT modify the buffer
	if code ~= 0 then
		vim.notify("snakefmt error:\n" .. (stderr or ""), vim.log.levels.ERROR)
		return
	end

	-- ❗ If snakefmt returned empty output, do NOT modify the buffer
	if not stdout or stdout == "" then
		vim.notify("snakefmt returned empty output — buffer left unchanged", vim.log.levels.WARN)
		return
	end

	local new_lines = vim.split(stdout, "\n", { trimempty = true })

	if #new_lines == 0 then
		vim.notify("snakefmt produced no formatted content — buffer left unchanged", vim.log.levels.WARN)
		return
	end

	-- ✔️ Now we know formatting succeeded — update buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, new_lines)

	-- Restore cursors
	for win, pos in pairs(cursors) do
		pcall(vim.api.nvim_win_set_cursor, win, pos)
	end

	local elapsed = (vim.loop.hrtime() - start) / 1e9
	vim.notify(string.format("Reformatted with snakefmt in %.4fs", elapsed))
end

function M.version()
	if not snakefmt_available() then
		vim.notify("snakefmt not found. Is snakefmt installed?", vim.log.levels.ERROR)
		return
	end

	local out = run("snakefmt", { "--version" })
	vim.notify(out)
end

return M
