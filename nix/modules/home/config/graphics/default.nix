{
  lib,
  config,
  nixosConfig ? null,
  pkgs,
  ...
}:
let
  cfg = config.my.roles.graphical;
  my.types = with lib; {
    font = types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          description = "Font name";
        };
        package = mkOption {
          type = types.package;
          description = "Font package";
        };
      };
    };
    monitor = types.submodule {
      options = {
        id = mkOption {
          type = types.str;
          description = "Monitor name";
        };
        position = mkOption {
          type = types.enum [
            "left"
            "right"
            "above"
            "below"
            "center"
          ];
          default = "center";
          description = "Monitor position";
        };
      };
    };
  };
in
{
  options.my = {
    roles.graphical = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = nixosConfig.my.roles.graphical.enable or false;
        description = "Enable graphical environment";
      };

      fonts = {
        monospace = lib.mkOption {
          type = my.types.font;
          default = config.my.fonts.iosevka-comfy;
          description = "Monospace font";
        };
        serif = lib.mkOption {
          type = my.types.font;
          default = config.my.fonts.noto-serif;
          description = "Serif font";
        };
        sansSerif = lib.mkOption {
          type = my.types.font;
          default = config.my.fonts.noto-sans;
          description = "Sans-serif font";
        };
        emoji = lib.mkOption {
          type = my.types.font;
          default = config.my.fonts.noto-emoji;
          description = "Emoji font";
        };
        symbols = lib.mkOption {
          type = my.types.font;
          default = config.my.fonts.nerdfont-symbols;
          description = "Symbols font";
        };
        hinting = lib.mkOption {
          type = lib.types.enum [
            "Normal"
            "Mono"
            "HorizontalLcd"
            "Light"
          ];
          default = "Normal";
          description = "Font hinting strategy";
        };

        sizes = {
          terminal = lib.mkOption {
            type = lib.types.int;
            default = 10;
            description = "Terminal font size";
          };

          terminalCell = {
            width = lib.mkOption {
              type = lib.types.float;
              default = 0.9;
              description = "Terminal cell width";
            };
            height = lib.mkOption {
              type = lib.types.float;
              default = 1.0;
              description = "Terminal cell height";
            };
          };

          applications = lib.mkOption {
            type = lib.types.int;
            default = 10;
            description = "Application font size";
          };
        };
      };
      installAllFonts = lib.mkEnableOption "Install all fonts";
      terminal = lib.mkOption {
        type = lib.types.enum [ "wezterm" ];
        default = "wezterm";
        description = "Terminal emulator";
      };

      monitors = {
        primary = lib.mkOption {
          type = my.types.monitor;
          default = {
            id = "eDP-1";
            position = "center";
          };
          description = "Primary monitor";
        };
        secondary = lib.mkOption {
          type = lib.types.nullOr my.types.monitor;
          default = null;
          description = "Secondary monitor";
        };
      };
    };

    fonts = lib.mkOption {
      type = lib.types.attrsOf my.types.font;
      description = "Fonts collection";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    my.fonts = {
      jetbrains-mono = {
        name = "JetBrains Mono";
        package = pkgs.jetbrains-mono;
      };
      iosevka-comfy = {
        name = "Iosevka Comfy";
        package = pkgs.iosevka-comfy.comfy;
      };
      luculent = {
        name = "Luculent";
        package = pkgs.luculent;
      };
      noto-serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };
      noto-sans = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      noto-emoji = {
        name = "Noto Emoji";
        package = pkgs.noto-fonts-emoji;
      };
      dina = {
        name = "Dina";
        package = pkgs.dina-font;
      };
      terminus = {
        name = "Terminus";
        package = pkgs.terminus_font;
      };
      cozette = {
        name = "Cozette";
        package = pkgs.cozette;
      };
      terminus-nerdfont = {
        name = "Terminus Nerd Font";
        package = pkgs.terminus-nerdfont;
      };
      nerdfont-symbols = {
        name = "Symbols Nerd Font Mono";
        package = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
      };
    };

    home.packages =
      [
        pkgs.wl-clipboard
        pkgs.libnotify
        pkgs.slack
        pkgs.google-chrome
      ]
      ++ (
        if cfg.installAllFonts then
          lib.attrsets.mapAttrsToList (name: font: font.package) config.my.fonts
        else
          with cfg.fonts;
          [
            monospace.package
            serif.package
            sansSerif.package
            emoji.package
            symbols.package
          ]
      );

    programs.mpv = {
      enable = pkgs.stdenv.isLinux;
      scripts = [
        pkgs.mpvScripts.sponsorblock
        pkgs.mpvScripts.thumbfast
        pkgs.mpvScripts.mpv-webm
        pkgs.mpvScripts.uosc
      ];
    };

    programs.zathura = {
      enable = true;
      options.font = cfg.fonts.monospace.name;
    };

    services.clipman.enable = true;
    services.swayosd.enable = true;
  };
}
