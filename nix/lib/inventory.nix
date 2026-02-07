{
  ix = {
    system = "x86_64-linux";
    isDarwin = false;
    deployment = {
      targetHost = "ix.opval.com";
      tags = [
        "vps"
        "cloud"
      ];
    };
  };

  caladan = {
    system = "aarch64-darwin";
    isDarwin = true;
    deployment = null;
  };
}
