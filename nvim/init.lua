-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
-- default vim opts
vim.opt.guicursor = ""
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

vim.opt.hlsearch = false

vim.opt.maxmempattern = 5000

vim.g.mapleader = ";"

local plugins = {
	telescope = {
		"nvim-telescope/telescope.nvim",
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
			vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
		end,
	},
	treesitter = {
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				sync_install = false,
				auto_install = false,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},
	lsp = {
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
				}, {
					{ name = "buffer" },
				}),
			})

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
				matching = { disallow_symbol_nonprefix_matching = false },
			})
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Set up LSP keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
					vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
					vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
					vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
					vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
					vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
					vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
					vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
					vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
					vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)

					vim.keymap.set("n", "gl", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
					vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
					vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
				end,
			})

			-- Configure LSP servers using the new vim.lsp.config API
			vim.lsp.config.gopls = {
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_markers = { "go.work", "go.mod", ".git" },
				capabilities = capabilities,
			}

			vim.lsp.config.clangd = {
				cmd = { "clangd" },
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
				root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", "configure.ac", ".git" },
				capabilities = capabilities,
			}

			vim.lsp.config.nixd = {
				cmd = { "nixd" },
				filetypes = { "nix" },
				root_markers = { "flake.nix", ".git" },
				capabilities = capabilities,
			}

			vim.lsp.config.ts_ls = {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
				root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
				capabilities = capabilities,
			}

			vim.lsp.config.pylsp = {
				cmd = { "pylsp" },
				filetypes = { "python" },
				root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
				capabilities = capabilities,
			}

			-- Enable LSP servers
			vim.lsp.enable({ "gopls", "clangd", "nixd", "ts_ls", "pylsp" })

			-- Custom command for gopls with tags
			vim.api.nvim_create_user_command("LspGoplsTags", function(info)
				-- Stop existing gopls client
				for _, client in ipairs(vim.lsp.get_clients({ name = "gopls" })) do
					vim.lsp.stop_client(client.id)
				end

				-- Update gopls config with new tags
				vim.lsp.config.gopls = vim.tbl_deep_extend("force", vim.lsp.config.gopls or {}, {
					cmd = { "gopls" },
					settings = {
						gopls = {
							env = { GOFLAGS = string.format("-tags=%s", info.args) },
						},
					},
				})

				-- Restart gopls
				vim.lsp.enable("gopls")
			end, {
				desc = "Restarts gopls with new set of tags",
				nargs = 1,
			})
		end,
	},
}

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		"fatih/vim-go",
		"tpope/vim-sensible",
		"tpope/vim-unimpaired",
		plugins.lsp,
		plugins.telescope,
		plugins.treesitter,
	},
})
