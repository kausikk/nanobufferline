local M = { hl_group = "Error" }

local nbl_buf, lastmark, ns_id = -1, -1, vim.api.nvim_create_namespace("_nbl")
local buffers, names, columns = {}, {}, {}

function M.setup(opts)
	M.hl_group = opts.hl_group
end

function M._change_buffer(ev)
	local ibuf = M._find_buf_in_listed(ev.buf)
	if ibuf == 0 then return end
	vim.api.nvim_buf_del_extmark(nbl_buf, ns_id, lastmark)
	local col = 2 -- First two chars are always spaces
	if ibuf > 1 then
		col = columns[ibuf - 1] + 2
	end
	lastmark = vim.api.nvim_buf_set_extmark(
		nbl_buf, ns_id, 0, col, { end_col = columns[ibuf], hl_group = M.hl_group }
	)
	local row = 1
	for _, win in ipairs(vim.fn.win_findbuf(nbl_buf)) do
		-- Required to auto scroll win so that current buffer always visible
		vim.api.nvim_win_set_cursor(win, { row, col })
	end
end

function M._list_buffer(ev)
	if vim.fn.buflisted(ev.buf) ~= 1 then
		return
	end
	M._window()
	local name = vim.api.nvim_buf_get_name(ev.buf)
	if name == "" then
		name = "  no name"
	else
		name = "  " .. vim.fn.fnamemodify(name, ":t")
	end
	local lastcol = 0
	if #columns > 0 then
		lastcol = columns[#columns]
	end
	table.insert(buffers, ev.buf)
	table.insert(names, name)
	table.insert(columns, lastcol + #name)
	vim.api.nvim_buf_set_lines(nbl_buf, 0, 1, false, { table.concat(names, "") })
	vim.bo[nbl_buf].modified = false
end

function M._unlist_buffer(ev)
	if vim.fn.buflisted(ev.buf) ~= 1 and vim.bo[ev.buf].buftype ~= "help" then
		return
	end
	M._window()
	local ibuf = M._find_buf_in_listed(ev.buf)
	if ibuf == 0 then return end
	local shift = #names[ibuf]
	for i = ibuf + 1, #columns do
		columns[i] = columns[i] - shift
	end
	table.remove(buffers, ibuf)
	table.remove(names, ibuf)
	table.remove(columns, ibuf)
	vim.api.nvim_buf_set_lines(nbl_buf, 0, 1, false, { table.concat(names, "") })
	vim.bo[nbl_buf].modified = false
end

function M._find_buf_in_listed(search_buf)
	for i, buf in ipairs(buffers) do
		if buf == search_buf then return i end
	end
	return 0
end

function M._window()
	if vim.fn.bufwinid(nbl_buf) ~= -1 then
		return
	end
	if not vim.api.nvim_buf_is_valid(nbl_buf) then
		nbl_buf = vim.api.nvim_create_buf(false, true)
		vim.bo[nbl_buf].readonly = true
	end
	-- This fails when doing :%bd or :%bw, idk how to fix, so wrap in pcall
	local res, win = pcall(vim.api.nvim_open_win, nbl_buf, false, {
		row = 0, col = 0, relative = "laststatus", height = 1,
		width = vim.o.columns - 20, style = "minimal"
	})
	if not res then
		return
	end
	vim.wo[win].winfixheight = true
	vim.wo[win].winfixbuf = true
end

return M
