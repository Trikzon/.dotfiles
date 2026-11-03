# Login screen: Noctalia Greeter on greetd.
{ lib, pkgs, ... }:
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

  # State dir for greeter.toml and the synced appearance. Owned by the user
  # greetd runs the greeter as (`greeter` by default).
  systemd.tmpfiles.rules = [ "d /var/lib/noctalia-greeter 0750 greeter greeter -" ];

  # The greeter lists users through AccountsService. polkit authorizes
  # `noctalia msg greeter-sync` writing into the state dir as root.
  services.accounts-daemon.enable = true;
  security.polkit.enable = true;

  environment.systemPackages = [ greeter ];
}
