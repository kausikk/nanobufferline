local M = { hl_group = "Error" }

local nbl_buf, lastmark, ns_id = -1, -1, vim.api.nvim_create_namespace("_nbl")
 -- Convenient to store this way, can bisect() buffers and concat() names
local buffers, names, columns = { -1 }, { "" }, { 0 }

function M.setup(opts)
	M.hl_group = opts.hl_group
end

function M._change_buffer(ev)
	local ibuf = vim.list.bisect(buffers, ev.buf)
	if buffers[ibuf] ~= ev.buf then return end
	vim.api.nvim_buf_del_extmark(nbl_buf, ns_id, lastmark)
	local col = columns[ibuf - 1] + 2 -- First two chars are always spaces
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
	local ibuf = vim.list.bisect(buffers, ev.buf)
	local shift = #name
	for i = ibuf, #columns do
		columns[i] = columns[i] + shift
	end
	table.insert(buffers, ibuf, ev.buf)
	table.insert(names, ibuf, name)
	table.insert(columns, ibuf, columns[ibuf - 1] + #name)
	vim.api.nvim_buf_set_lines(nbl_buf, 0, 1, false, { table.concat(names, "") })
	vim.bo[nbl_buf].modified = false
end

function M._unlist_buffer(ev)
	local ibuf = vim.list.bisect(buffers, ev.buf)
	if buffers[ibuf] ~= ev.buf then return end
	M._window()
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
