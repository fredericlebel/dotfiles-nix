{
  pkgs,
  lib,
  config,
  user,
  ...
}: let
  cfg = config.my.features.dev.git;
in {
  options.my.features.dev.git = {
    enable = lib.mkEnableOption "Git avec configuration personnalisée et GPG";
  };

  config = lib.mkIf cfg.enable {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        side-by-side = true;
      };
    };

    programs.git = {
      enable = true;

      signing = {
        key = "1DC57FE723A81635B4DC1F68F2E3BDFD356FE1F8";
        signByDefault = true;
      };

      settings = {
        user = {
          name = "Frédéric Lebel";
          email = "flebel@opval.com";
        };

        core = {
          editor = "vim";
        };

        init = {
          defaultBranch = "main";
        };

        pull = {
          rebase = true;
        };

        push = {
          default = "simple";
          autoSetupRemote = true;
        };

        tag = {
          gpgSign = true;
        };

        # Credentials
        "credential \"https://github.com\"" = {
          username = "fredericlebel";
        };

        # Réécriture des URLs
        "url \"git@github.com:\"" = {
          pushInsteadOf = [
            "https://github.com/"
            "github:"
            "git://github.com/"
          ];
        };

        # Gitflow
        "gitflow \"branch\"" = {
          master = "master";
          develop = "work";
        };

        "gitflow \"prefix\"" = {
          feature = "feature/";
          release = "release/";
          hotfix = "hotfix/";
          support = "support/";
          versiontag = "";
        };
      };
    };
  };
}
