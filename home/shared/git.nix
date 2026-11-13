# Git identity and commit signing.
{ ... }: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Dion Tryban";
        email = "dion@tryban.dev";
      };
      init.defaultBranch = "main";
    };
    signing = {
      format = "openpgp";
      key = "F2EDF21F8BED59D5";
      signByDefault = true;
    };
  };
}
