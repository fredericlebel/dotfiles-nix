{
  lib,
  config,
  ...
}: let
  cfg = config.my.features.screen;
in {
  options.my.features.screen = {
    enable = lib.mkEnableOption "screen avec intégration Zsh";
  };

  config = lib.mkIf cfg.enable {
    programs.screen = {
      enable = true;

      screenrc = ''
        startup_message off
        deflogin on
        windowlist title "Select Window"
        vbell off
        defscrollback 10000
        defnonblock 5
        term screen-256color
        deflog on
        logfile "$HOME/.screen/log/screen-%Y%m%d-%n.log"
        bind e stuff 'echo -en \\ekU@H\\e\\\\|sed -e "s/H/`hostname`/" -e "s/U/`whoami`/"'
        bind f eval "hardstatus alwaysignore"
        bind F eval "hardstatus alwayslastline"
        backtick 10 86400 86400 printf "\005{= Wk}"
        backtick 20 86400 86400 printf "\005{= WK}"
        backtick 100 86400 86400 uname -m
        backtick 101 3600 3600 hostname -i
        backtick 102 2 2 printf `ps -e | wc -l`
        hardstatus string '%20`host %10`%H %20`| ip %10`%101`%20`| arch %10`%100` %20`| load %10`%l %20`|%=%20`gnu/screen %10`%Y-%m-%d %0c:%s'
        caption always "%{= Wb}%-Lw%{= wb}%50>%n%f* %t%{-}%+Lw%<"
      '';
    };
  };
}
