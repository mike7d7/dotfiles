{
  vim = {
    lineNumberMode = "number";
    clipboard.enable = true;
    clipboard.registers = "unnamedplus";
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
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
        key = "<A-i>";
        mode = "t";
        silent = true;
        action = "<cmd>ToggleTerm<CR>";
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
