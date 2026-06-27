{ pkgs, ... }:
{
  vim = {
    utility = {
      multicursors.enable = true;
    };
    debugger.nvim-dap = {
      enable = true;
      ui.enable = true;
    };
    lineNumberMode = "number";
    clipboard.enable = true;
    clipboard.registers = "unnamedplus";
    theme = {
      enable = true;
      transparent = true;
    };
    extraPlugins = with pkgs.vimPlugins; {
      gruvbox-plugin = {
        package = gruvbox-nvim;
        setup = ''
            require("gruvbox").setup({
            terminal_colors = true, -- add neovim terminal colors
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
              strings = true,
              emphasis = true,
              comments = true,
              operators = false,
              folds = true,
            },
            strikethrough = true,
            invert_selection = false,
            invert_signs = false,
            invert_tabline = false,
            inverse = true, -- invert background for search, diffs, statuslines and errors
            contrast = "hard", -- can be "hard", "soft" or empty string
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = true,
          })
          vim.cmd("colorscheme gruvbox")
        '';
      };
    };
    terminal.toggleterm = {
      enable = true;
      lazygit.enable = true;
      mappings = {
        open = "<A-i>";
      };
      setupOpts = {
        start_in_insert = true;
        direction = "float";
      };
    };
    options = {
      whichwrap = "h,l";
      langmap = "fe,pr,gt,jy,lu,ui,yo,ñp,rs,sd,tf,dg,nj,ek,il,oñ,kn,FE,PR,GT,JY,LU,UI,YO,ÑP,RS,SD,TF,DG,NJ,EK,IL,OÑ,KN";
    };

    keymaps = [
      {
        key = "j";
        mode = "n";
        silent = true;
        action = "gj";
      }
      {
        key = "k";
        mode = "n";
        silent = true;
        action = "gk";
      }
      {
        key = "<C-S>";
        mode = "n";
        silent = true;
        action = ":update<CR>";
      }
      {
        key = "<leader>x";
        mode = "n";
        silent = true;
        action = ":bd<CR>";
      }
      {
        key = "<A-i>";
        mode = "t";
        silent = true;
        action = "<cmd>ToggleTerm<CR>";
      }
      {
        key = "<leader>m";
        mode = [
          "n"
          "v"
        ];
        silent = true;
        action = "<cmd>MCstart<CR>";
      }
    ];

    statusline.lualine.enable = true;
    telescope.enable = true;
    autocomplete.nvim-cmp.enable = true;

    lsp = {
      formatOnSave = true;
      mappings = {
        format = "<leader>fm";
      };
      enable = true;
    };

    languages = {
      enableFormat = true;
      enableExtraDiagnostics = true;
      enableTreesitter = true;
      enableDAP = true;

      nix = {
        enable = true;
        format = {
          enable = true;
          type = [ "nixfmt" ];
        };
      };
      rust.enable = true;
      clang.enable = true;
      bash.enable = true;
      python.enable = true;
      typst.enable = true;
      r.enable = true;
    };
    diagnostics = {
      config = {
        virtual_lines = true;
        virtual_text = true;
      };
    };
    filetree.nvimTree = {
      enable = true;
      openOnSetup = false;
      mappings = {
        toggle = "<C-n>";
      };
      setupOpts.actions.open_file.quit_on_open = true;
    };
    tabline.nvimBufferline = {
      enable = true;
      mappings = {
        cycleNext = "<C-Tab>";
        cyclePrevious = "<C-S-Tab>";
      };
    };
    autopairs.nvim-autopairs.enable = true;
  };
}
