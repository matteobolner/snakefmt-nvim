snakefmt-nvim

Snakefmt plugin for Neovim 
This plugin was fully generated using copilot

To install with Lazy:

{
    "matteobolner/snakefmt-nvim",
    config = function()
        -- Optional: autoformat on save
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = { "Snakefile", "*.smk" },
            callback = function()
                require("snakefmt").format()
            end,
        })
    end,
}


