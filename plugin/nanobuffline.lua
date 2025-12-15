if _G.nbl_loaded then
	return
end
_G.nbl_loaded = true

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(ev) require("nanobufferline")._change_buffer(ev) end
})
vim.api.nvim_create_autocmd("BufAdd", {
	callback = function(ev) require("nanobufferline")._list_buffer(ev) end
})
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
	callback = function(ev) require("nanobufferline")._unlist_buffer(ev) end
})
