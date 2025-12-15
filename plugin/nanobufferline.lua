if _G.nbl_loaded then
	return
end
_G.nbl_loaded = true

-- No lazy loading, but that's ok :)
vim.api.nvim_create_autocmd("BufEnter", { callback = require("nanobufferline")._change_buffer })
vim.api.nvim_create_autocmd("BufAdd", { callback = require("nanobufferline")._list_buffer })
vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, { callback = require("nanobufferline")._unlist_buffer })
