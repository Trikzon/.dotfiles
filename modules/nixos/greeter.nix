# Login screen: Noctalia Greeter on greetd.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Same release as the unstable noctalia shell, so `noctalia msg greeter-sync`
  # and the greeter agree on the sync format.
  greeter = pkgs.unstable.noctalia-greeter;
in
{
  # The part that matters of unstable's services.displayManager.noctalia-greeter,
  # which needs options 26.05 doesn't have.
  services.greetd = {
    enable = true;
    settings.default_session.command = lib.getExe' greeter "noctalia-greeter-session";
  };

  # A second greetd on tty2, so another user can log in while tty1 is in use.
  # The NixOS module only runs one, fixed to tty1; this mirrors its unit.
  # switch = false: greetd waits for Ctrl+Alt+F2 instead of taking the screen at boot.
  systemd.services.greetd-tty2 = {
    wantedBy = [ "graphical.target" ];
    wants = [ "systemd-user-sessions.service" ];
    after = [
      "systemd-user-sessions.service"
      "getty@tty2.service"
    ];
    conflicts = [ "getty@tty2.service" ];
    # Restarting would end the session running on tty2.
    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${lib.getExe config.services.greetd.package} --config ${
        (pkgs.formats.toml { }).generate "greetd-tty2.toml" (
          lib.recursiveUpdate config.services.greetd.settings {
            terminal = {
              vt = 2;
              switch = false;
            };
          }
        )
      }";
      Type = "idle";
      IgnoreSIGPIPE = false;
      SendSIGHUP = true;
      TimeoutStopSec = "30s";
      KeyringMode = "shared";
    };
  };
  systemd.services."autovt@tty2".enable = false;

  # State dir for greeter.toml and the synced appearance. Owned by the user
  # greetd runs the greeter as (`greeter` by default).
  systemd.tmpfiles.rules = [ "d /var/lib/noctalia-greeter 0750 greeter greeter -" ];

  # The greeter lists users through AccountsService. polkit authorizes
  # `noctalia msg greeter-sync` writing into the state dir as root.
  services.accounts-daemon.enable = true;
  security.polkit.enable = true;

  environment.systemPackages = [ greeter ];
}
